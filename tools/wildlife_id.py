"""Photo ID bank ("Qu'est-ce que c'est? / What is it?").

content/wildlife-id/species.json is the source of truth; photos live in content/wildlife-id/photos/.

  python3 tools/wildlife_id.py fetch               # download a photo for every huntable species lacking one
  python3 tools/wildlife_id.py candidates <id> [words]  # list free-licence Commons photos (words refine)
  python3 tools/wildlife_id.py preview <File:..> <out.jpg>  # download a candidate's thumbnail to look at it
  python3 tools/wildlife_id.py use <id> <File:..>  # replace a species' photo with a chosen Commons file
  python3 tools/wildlife_id.py build               # write the app's question bank and copy photos

Only CC0 / public domain / CC BY / CC BY-SA photos are kept; the credit shown in the app comes from
Commons metadata.
"""
import hashlib
import html
import json
import re
import shutil
import subprocess
import sys
import urllib.parse
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DIR = ROOT / "content" / "wildlife-id"
SPECIES = DIR / "species.json"
PHOTOS = DIR / "photos"
APP_BANK = ROOT / "app" / "assets" / "content" / "questions" / "wildlife-id.json"
APP_PHOTOS = ROOT / "app" / "assets" / "wildlife"
UA = {"User-Agent": "HuntExamPrep/1.0 (https://kallistesoft.ca; contact@kallistesoft.ca)"}
WIDTH = 800
FREE = re.compile(r"^(cc0|public domain|pd|cc by(-sa)? \d(\.\d)?( [a-z]+)?)$", re.I)
SCOPE = "wildlife-id"
QUESTION = {"fr": "Quel est cet animal?", "en": "What animal is this?"}


def _get(url: str, params: dict | None = None) -> bytes:
    if params:
        url += "?" + urllib.parse.urlencode(params)
    with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=60) as r:
        return r.read()


def _json(url: str, params: dict) -> dict:
    return json.loads(_get(url, {**params, "format": "json"}))


def load() -> list[dict]:
    return json.loads(SPECIES.read_text(encoding="utf-8"))


def save(species: list[dict]) -> None:
    SPECIES.write_text(json.dumps(species, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def _wikidata_image(latin: str) -> str | None:
    """Main image (P18) of the taxon whose scientific name (P225) is `latin`."""
    q = f'SELECT ?img WHERE {{ ?t wdt:P225 "{latin}"; wdt:P18 ?img }} LIMIT 1'
    rows = _json("https://query.wikidata.org/sparql", {"query": q})["results"]["bindings"]
    if not rows:
        return None
    return "File:" + urllib.parse.unquote(rows[0]["img"]["value"].rsplit("/", 1)[1])


def _info(title: str) -> dict | None:
    """Thumbnail URL and licence/credit of a Commons file, or None if not freely licensed."""
    pages = _json("https://commons.wikimedia.org/w/api.php", {
        "action": "query", "titles": title, "prop": "imageinfo",
        "iiprop": "url|extmetadata|mime", "iiurlwidth": WIDTH,
    })["query"]["pages"]
    page = next(iter(pages.values()))
    if "imageinfo" not in page:
        return None
    ii = page["imageinfo"][0]
    meta = ii.get("extmetadata", {})
    lic = meta.get("LicenseShortName", {}).get("value", "").strip()
    if ii.get("mime") not in ("image/jpeg", "image/png") or not FREE.match(lic):
        return None
    artist = re.sub(r"<[^>]+>", "", html.unescape(meta.get("Artist", {}).get("value", ""))).strip()
    return {
        "title": page["title"], "thumb": ii["thumburl"], "page": ii["descriptionurl"],
        "author": " ".join(artist.split()) or "Unknown", "license": lic,
    }


def _download(sp: dict, info: dict) -> None:
    PHOTOS.mkdir(parents=True, exist_ok=True)
    name = f"{sp['id']}.jpg"
    (PHOTOS / name).write_bytes(_get(info["thumb"]))
    sp["photo"] = {"file": name, "author": info["author"], "license": info["license"],
                   "page": info["page"], "commons": info["title"]}


def fetch() -> None:
    species = load()
    for sp in species:
        if not sp["huntable"] or (sp.get("photo") and (PHOTOS / sp["photo"]["file"]).exists()):
            continue
        title = _wikidata_image(sp["latin"])
        info = _info(title) if title else None
        if info is None:
            print(f"  {sp['id']}: no free main image, pick one with `candidates`")
            continue
        _download(sp, info)
        save(species)
        print(f"  {sp['id']}: {info['title']} ({info['license']})")


def candidates(sid: str, *extra: str) -> None:
    """Extra words refine the search, e.g. `candidates mallard male` or `candidates gray-wolf Yellowstone`."""
    limit = 12
    sp = next(s for s in load() if s["id"] == sid)
    res = _json("https://commons.wikimedia.org/w/api.php", {
        "action": "query", "list": "search", "srnamespace": 6, "srlimit": 40,
        "srsearch": f'"{sp["latin"]}" {" ".join(extra)} filetype:bitmap'.replace("  ", " "),
    })["query"]["search"]
    shown = 0
    for r in res:
        info = _info(r["title"])
        if info:
            print(f"  {info['title']}  [{info['license']}]  {info['author'][:40]}")
            shown += 1
            if shown >= limit:
                break


def use(sid: str, title: str) -> None:
    species = load()
    sp = next(s for s in species if s["id"] == sid)
    info = _info(title if title.startswith("File:") else "File:" + title)
    if info is None:
        sys.exit(f"{title}: not found or not freely licensed")
    _download(sp, info)
    save(species)
    print(f"  {sid}: {info['title']} ({info['license']})")


def preview(title: str, out: str) -> None:
    info = _info(title if title.startswith("File:") else "File:" + title)
    if info is None:
        sys.exit(f"{title}: not found or not freely licensed")
    Path(out).write_bytes(_get(info["thumb"]))
    print(f"  {out}: {info['title']} [{info['license']}] {info['author'][:40]}")


def _place(choices: list[str], qid: str) -> int:
    """Correct choice is first; move it to a position derived from the id (as qgen.generate does)."""
    target = int(hashlib.sha1(qid.encode()).hexdigest(), 16) % 4
    choices.insert(target, choices.pop(0))
    return target


def build() -> None:
    species = load()
    by_id = {s["id"]: s for s in species}
    errors, questions = [], []
    for sp in species:
        if not sp["huntable"]:
            continue
        sid, photo = sp["id"], sp.get("photo")
        looks = sp.get("lookalikes", [])[:3]
        if not photo or not (PHOTOS / photo["file"]).exists():
            errors.append(f"{sid}: no photo")
            continue
        if not photo.get("author") or not FREE.match(photo.get("license", "")):
            errors.append(f"{sid}: photo credit or licence missing")
        if len(looks) < 3 or any(l not in by_id for l in looks):
            errors.append(f"{sid}: needs 3 known look-alikes, has {looks}")
            continue
        if any(by_id[l]["group"] != sp["group"] for l in looks):
            errors.append(f"{sid}: look-alike outside group {sp['group']}")
        if not all(sp.get(k, {}).get(l) for k in ("name", "identify", "habitat") for l in ("fr", "en")):
            errors.append(f"{sid}: name/identify/habitat missing")
            continue
        qid = f"id-{sid}"
        order = [sid, *looks]
        answer = _place(order, qid)
        q = {
            "id": qid, "scope": SCOPE, "chapter": sp["group"], "objectiveId": qid, "reviewYear": None,
            "answerIndex": answer, "sourceRef": "", "sourceUrl": sp.get("sourceUrl") or None,
            # Neutral file name, so the answer can't be read from the asset URL.
            "image": f"assets/wildlife/{hashlib.sha1(sid.encode()).hexdigest()[:12]}.jpg",
            "imageCredit": {k: photo[k] for k in ("author", "license", "page")},
        }
        for lang in ("fr", "en"):
            names = [by_id[s]["name"][lang] for s in order]
            if len({n.lower() for n in names}) != 4:
                errors.append(f"{sid}: repeated choice names in {lang}")
            q[lang] = {"q": QUESTION[lang], "choices": names, "explanation": sp["identify"][lang],
                       "habitat": sp["habitat"][lang]}
            if sp.get("confuse", {}).get(lang):
                q[lang]["confuse"] = sp["confuse"][lang]
        questions.append(q)
    if errors:
        sys.exit("wildlife-id build failed:\n  " + "\n  ".join(errors))
    APP_BANK.parent.mkdir(parents=True, exist_ok=True)
    APP_BANK.write_text(json.dumps(questions, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if APP_PHOTOS.exists():
        shutil.rmtree(APP_PHOTOS)
    APP_PHOTOS.mkdir(parents=True)
    sips = shutil.which("sips")  # macOS: 640 px, quality 70 (~75 KB each) keeps the app light
    for q in questions:
        src, dest = PHOTOS / f"{q['id'].removeprefix('id-')}.jpg", APP_PHOTOS / Path(q["image"]).name
        if sips:
            subprocess.run([sips, "-Z", "640", "-s", "format", "jpeg", "-s", "formatOptions", "70", str(src),
                            "--out", str(dest)], check=True, capture_output=True)
        else:
            shutil.copy2(src, dest)
    print(f"  wildlife-id: {len(questions)} questions, photos copied to {APP_PHOTOS.relative_to(ROOT)}")


if __name__ == "__main__":
    cmd, *args = sys.argv[1:] or ["help"]
    {"fetch": fetch, "candidates": candidates, "preview": preview, "use": use, "build": build}.get(cmd, lambda *_: print(__doc__))(*args)
