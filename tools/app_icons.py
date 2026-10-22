#!/usr/bin/env python3
"""Generate the app launcher icons (Android, iOS, web) from store/icon.svg.

The Play Console icon (store/icon-512.png) and the installed app icon come from
the same source. Run from the repo root after changing store/icon.svg:

    pip install cairosvg pillow
    python3 tools/app_icons.py
"""
import io
import json
import re
from pathlib import Path

import cairosvg
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SVG = (ROOT / "store" / "icon.svg").read_text()
APP = ROOT / "app"

# The SVG is a background <rect> followed by the deer artwork.
_head, _rest = SVG.split("<rect", 1)
_rect, _art = _rest.split("/>", 1)
BACKGROUND = "<rect" + _rect + "/>"
ART = _art.rsplit("</svg>", 1)[0]


def svg(background: bool, scale: float = 1.0) -> str:
    """Icon SVG, optionally without the background and with the deer scaled about the centre."""
    art = ART
    if scale != 1.0:
        art = f'<g transform="translate(256 256) scale({scale}) translate(-256 -256)">{ART}</g>'
    return _head + (BACKGROUND if background else "") + art + "</svg>"


def render(source: str, size: int, path: Path, opaque: bool = False) -> None:
    png = cairosvg.svg2png(bytestring=source.encode(), output_width=size, output_height=size)
    img = Image.open(io.BytesIO(png))
    img = img.convert("RGB") if opaque else img.convert("RGBA")
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path, optimize=True)
    print(path.relative_to(ROOT), f"{size}x{size}")


FULL = svg(background=True)
# Maskable web icons: keep the deer inside the 80% safe circle.
MASKABLE = svg(background=True, scale=0.7)
# Android adaptive icon: 108dp layers, only the central 66dp circle is always visible.
ADAPTIVE_FG = svg(background=False, scale=0.62)
ADAPTIVE_BG = _head + BACKGROUND + "</svg>"

# Android
res = APP / "android" / "app" / "src" / "main" / "res"
for density, factor in {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}.items():
    render(FULL, round(48 * factor), res / f"mipmap-{density}" / "ic_launcher.png")
    render(ADAPTIVE_FG, round(108 * factor), res / f"mipmap-{density}" / "ic_launcher_foreground.png")
    render(ADAPTIVE_BG, round(108 * factor), res / f"mipmap-{density}" / "ic_launcher_background.png")
adaptive = res / "mipmap-anydpi-v26" / "ic_launcher.xml"
adaptive.parent.mkdir(parents=True, exist_ok=True)
adaptive.write_text(
    '<?xml version="1.0" encoding="utf-8"?>\n'
    '<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">\n'
    '    <background android:drawable="@mipmap/ic_launcher_background"/>\n'
    '    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>\n'
    "</adaptive-icon>\n"
)
print(adaptive.relative_to(ROOT))

# iOS: sizes come from the asset catalog; App Store icons must not have an alpha channel.
iconset = APP / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
for image in json.loads((iconset / "Contents.json").read_text())["images"]:
    points = float(image["size"].split("x")[0])
    scale = int(image["scale"].rstrip("x"))
    render(FULL, round(points * scale), iconset / image["filename"], opaque=True)

# Web
web = APP / "web"
render(FULL, 32, web / "favicon.png")
for size in (192, 512):
    render(FULL, size, web / "icons" / f"Icon-{size}.png")
    render(MASKABLE, size, web / "icons" / f"Icon-maskable-{size}.png")
dark = re.search(r'stop-color="(#[0-9A-Fa-f]{6})"\s*/>\s*</linearGradient>', SVG).group(1)
manifest_path = web / "manifest.json"
manifest = json.loads(manifest_path.read_text())
manifest["background_color"] = manifest["theme_color"] = dark
manifest_path.write_text(json.dumps(manifest, indent=4, ensure_ascii=False) + "\n")
print(manifest_path.relative_to(ROOT), "colours", dark)
