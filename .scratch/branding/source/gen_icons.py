#!/usr/bin/env python3
"""Generates the AngryKeyboard app-icon masters.

Writes the 1024 SVG masters onto Apple's macOS icon grid: a 1024 canvas with an
824 art box centered at (100,100), corner radius 185.4, continuous corners.
macOS does not mask app icons, so the squircle has to be in the artwork.

    python3 gen_icons.py

The SVGs it writes are the source of truth. `make-app-icon.sh` turns one of them
into the shipped AppIcon set.
"""
import math
from pathlib import Path

OUT = Path(__file__).resolve().parent

INK, CREAM, RED, DEEP, BONE = "#141210", "#EDE4CE", "#CE2B1E", "#8E1A12", "#E6DCC3"
ART, INSET, RADIUS, SMOOTH = 824, 100, 185.4, 0.7
SCALE = ART / 512.0


def squircle(side, radius, smoothing, x=0.0, y=0.0):
    """Apple-style rounded square: a 90*(1-s) degree arc per corner, flanked by
    cubics that carry curvature into the straight edges."""
    r, s = radius, smoothing
    p = (1 + s) * r
    arc_measure = 90 * (1 - s)
    arc = math.sin(math.radians(arc_measure / 2)) * r * math.sqrt(2)
    alpha = (90 - arc_measure) / 2
    beta = 45 * s
    c = r * math.tan(math.radians(alpha / 2)) * math.cos(math.radians(beta))
    d = c * math.tan(math.radians(beta))
    b = (p - arc - c - d) / 3
    a = 2 * b
    n = lambda v: f"{v:.4f}"
    return " ".join([
        f"M {n(x + side - p)} {n(y)}",
        f"c {n(a)} 0 {n(a + b)} 0 {n(a + b + c)} {n(d)}",
        f"a {n(r)} {n(r)} 0 0 1 {n(arc)} {n(arc)}",
        f"c {n(d)} {n(c)} {n(d)} {n(b + c)} {n(d)} {n(a + b + c)}",
        f"L {n(x + side)} {n(y + side - p)}",
        f"c 0 {n(a)} 0 {n(a + b)} {n(-d)} {n(a + b + c)}",
        f"a {n(r)} {n(r)} 0 0 1 {n(-arc)} {n(arc)}",
        f"c {n(-c)} {n(d)} {n(-(b + c))} {n(d)} {n(-(a + b + c))} {n(d)}",
        f"L {n(x + p)} {n(y + side)}",
        f"c {n(-a)} 0 {n(-(a + b))} 0 {n(-(a + b + c))} {n(-d)}",
        f"a {n(r)} {n(r)} 0 0 1 {n(-arc)} {n(-arc)}",
        f"c {n(-d)} {n(-c)} {n(-d)} {n(-(b + c))} {n(-d)} {n(-(a + b + c))}",
        f"L {n(x)} {n(y + p)}",
        f"c 0 {n(-a)} 0 {n(-(a + b))} {n(d)} {n(-(a + b + c))}",
        f"a {n(r)} {n(r)} 0 0 1 {n(arc)} {n(-arc)}",
        f"c {n(c)} {n(-d)} {n(b + c)} {n(-d)} {n(a + b + c)} {n(-d)}",
        "Z",
    ])


def smoke(color, opacity):
    return f"""<g fill="none" stroke="{color}" stroke-linecap="round" opacity="{opacity}">
<path d="M256 258 C 232 212, 288 194, 262 148 S 226 76, 258 32" stroke-width="24"/>
<path d="M206 256 C 190 222, 224 208, 208 176 S 188 126, 204 100" stroke-width="13" opacity=".6"/>
<path d="M308 258 C 322 226, 292 210, 306 180 S 324 136, 310 110" stroke-width="13" opacity=".6"/>
</g>"""


def face(fill, tooth):
    teeth = f'<path d="M232 374 v26 M256 374 v26 M280 374 v26" stroke="{tooth}" stroke-width="5"/>'
    return f"""<g stroke="{fill}" stroke-width="18" stroke-linecap="round">
<path d="M176 300 L228 320"/><path d="M336 300 L284 320"/></g>
<circle cx="206" cy="346" r="12" fill="{fill}"/><circle cx="306" cy="346" r="12" fill="{fill}"/>
<rect x="214" y="372" width="84" height="30" rx="10" fill="{fill}"/>
{teeth}"""


def master(bg, foreground, defs=""):
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
<defs>
<clipPath id="art"><path d="{squircle(ART, RADIUS, SMOOTH, INSET, INSET)}"/></clipPath>{defs}
</defs>
<g clip-path="url(#art)">
<rect x="0" y="0" width="1024" height="1024" fill="{bg}"/>
<g transform="translate({INSET} {INSET}) scale({SCALE})">
{foreground}
</g>
</g>
</svg>
"""


# M, "Blackout" — ships.
blackout = master("#17140F", f"""<circle cx="256" cy="256" r="202" fill="none" stroke="{RED}" stroke-opacity=".3" stroke-width="12"/>
{smoke(BONE, ".9")}
<rect x="126" y="250" width="260" height="196" rx="32" fill="{RED}"/>
<rect x="126" y="250" width="260" height="196" rx="32" fill="none" stroke="#FFFFFF" stroke-opacity=".18" stroke-width="3"/>
{face(CREAM, RED)}""")

# L, "Kraft Kit" — alternate.
kraft_defs = f"""
<linearGradient id="lTop" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#F0523A"/><stop offset="1" stop-color="{RED}"/></linearGradient>"""
kraft = master(BONE, f"""{smoke(INK, ".85")}
<rect x="126" y="278" width="260" height="196" rx="32" fill="{DEEP}"/>
<rect x="126" y="250" width="260" height="196" rx="32" fill="url(#lTop)"/>
<rect x="126" y="250" width="260" height="196" rx="32" fill="none" stroke="#FFFFFF" stroke-opacity=".22" stroke-width="3"/>
{face(INK, RED)}""", defs=kraft_defs)

# K, "Flat Red" — alternate.
flat_red = master(RED, f"""{smoke(INK, ".85")}
<rect x="126" y="270" width="260" height="196" rx="32" fill="{INK}" opacity=".26"/>
<rect x="126" y="250" width="260" height="196" rx="32" fill="{CREAM}"/>
{face(INK, CREAM)}""")

def main():
    for name, svg in [
        ("app-icon-blackout.svg", blackout),
        ("app-icon-kraft-kit.svg", kraft),
        ("app-icon-flat-red.svg", flat_red),
    ]:
        (OUT / name).write_text(svg)
    print("wrote", ", ".join(sorted(p.name for p in OUT.glob("app-icon-*.svg"))))


if __name__ == "__main__":
    main()