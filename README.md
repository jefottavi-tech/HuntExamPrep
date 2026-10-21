# HuntExamPrep

Bilingual (FR/EN) practice app for Canadian hunter and firearm-licence exams: the PAL (CFSC) and Québec's ICAF first, then BC CORE, Ontario Hunter Ed and Alberta. Built with Flutter, free with ads.

> Independent study aid: not affiliated with or endorsed by the RCMP, the Canadian Firearms Program, the Government of Québec, FédéCP or any provincial agency. Questions are original practice questions written from the official manuals, not the official exam questions, and may contain errors: always check the official manual.

## Layout

```
content/
  exams.json        exam recipes: which question scopes make up each exam
  sources.json      source manual + chapter page ranges per scope
  glossary.json     official FR ↔ EN term pairs
  syllabus/         generated learning objectives per scope
  drafts/           generated questions, before review
  review.csv        human review sheet (source of truth once reviewed)
  questions/        approved questions bundled into the app
sources/            official PDFs (copyrighted, gitignored)
tools/qgen/         question generation pipeline (Python + Claude API)
  samples/          placeholder questions (ids `sample-…`) used until reviewed ones exist
app/                Flutter app (iOS, Android, web)
```

## Question scopes

Each question has one scope: `federal` (PAL, the same everywhere in Canada), `hunter-common` (shared by all provincial hunter-ed courses), or a province code (`QC`, `BC`, `ON`, `AB`, …). An exam mixes scopes, e.g. `ICAF = hunter-common + QC`. Questions about yearly regulations carry a `reviewYear` and are re-checked each season.

## Question pipeline

Setup (Python 3.10+):

```sh
python3 -m venv .venv && .venv/bin/pip install -r tools/requirements.txt
cd tools
```

Claude API credentials come from `ANTHROPIC_API_KEY` or an `ant auth login` profile.

1. Put the manual in `sources/` and fill in its chapters in `content/sources.json`.
2. `python -m qgen syllabus federal`: extract the testable facts, one call per chapter.
3. `python -m qgen generate federal`: 3 bilingual questions per fact. Correct answers are spread evenly across A–D.
4. `python -m qgen check federal`: free local checks (format, banned phrasings, near-duplicates).
5. `python -m qgen verify federal`: blind-answer check. Claude answers each question from the manual without seeing the stored answer, and any disagreement is flagged.
6. `python -m qgen export federal`: writes `content/review.csv`, flagged questions first. Set `status` to `approved` / `fix` / `rejected` and edit text directly in the sheet.
7. `python -m qgen bundle`: only `approved` rows go to `content/questions/`.

`python -m qgen all federal` runs steps 2–6. Every step is resumable: work already done is skipped.

Each chapter's PDF is sent as a prompt-cached block, so repeated calls on the same chapter are cheap. Uses `claude-opus-5-5` with server-side refusal fallback.

Tests (offline, no API calls): `../.venv/bin/python -m pytest tests`

## Photo ID quiz ("Qu'est-ce que c'est? / What is it?")

`content/wildlife-id/species.json` holds one card per species (names, 3 same-family look-alikes, how to recognise it,
where it lives, protected look-alike warning, fact-sheet link). Photos in `content/wildlife-id/photos/` come from
Wikimedia Commons under CC0 / public domain / CC BY / CC BY-SA; the app shows each photo's author and licence.
`tools/wildlife_id.py` fetches photos (`fetch`, `candidates`, `preview`, `use`) and builds the bank (`build`).

## App

```sh
tools/sync_app_content.sh     # copy exams + question banks into app/assets (approved ones override samples)
                              # and build the photo ID bank (tools/wildlife_id.py build)
cd app
flutter test                  # unit, content and widget tests
flutter run -d chrome         # or an Android device / iOS simulator
```

- **Practice:** explanation after every answer.
- **Mock exam:** timed, no feedback until the end, pass/fail against the exam's pass mark.
- **Review:** questions you missed, until you answer each correctly twice.
- Per-exam readiness, daily streak, FR/EN switch. French is the default unless the device is in English.
- While sample questions are bundled, the home screen shows a "not reviewed" warning.
- Ads go through `AdService` (currently a no-op): an interstitial between a finished test and its results, never mid-question.

**Rule:** questions are written in original wording from the manuals' facts. Never copy official exam questions or manual text.
