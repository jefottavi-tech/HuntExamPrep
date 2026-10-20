#!/bin/sh
# Copy exam recipes and question banks into the Flutter app's assets.
# Approved questions (content/questions/) win; otherwise the sample bank is used.
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/app/assets/content"
mkdir -p "$DEST/questions"
rm -f "$DEST/questions/"*.json
cp "$ROOT/content/exams.json" "$DEST/exams.json"
for f in "$ROOT"/content/samples/*.json "$ROOT"/content/questions/*.json; do
  [ -f "$f" ] && cp "$f" "$DEST/questions/"
done
ls "$DEST/questions"
