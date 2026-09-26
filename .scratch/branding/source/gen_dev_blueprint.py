#!/usr/bin/env python3
"""Generates the dev channel's blueprint identity: app icon masters and menu bar
glyphs, plus the proof sheet used to choose one.

    python3 gen_dev_blueprint.py

Writes five app-icon masters onto Apple's macOS icon grid (same as gen_icons.py),
five menu bar glyphs with muted variants, and `icon-prototype-dev-blueprint.html`
next to this directory. After a pick, the chosen master rasterizes with
`./make-app-icon.sh app-icon-blueprint-<x>.svg AppIconDev`, and the chosen glyph
is copied over `menu-bar-glyph-dev.svg`.
"""
import json
from pathlib import Path

from gen_icons import ART, INSET, RADIUS, SMOOTH, SCALE, smoke, squircle

OUT = Path(__file__).resolve().parent
SHEET = OUT.parent / "icon-prototype-dev-blueprint.html"

PAPER = "#F2F7FE"
PAPER_L = "#FAFCFF"
GRID = "#AFCBEE"
BLUE = "#1E5CB3"
BLUE_M = "#4C88DC"
BLUE_D = "#123E80"
NAVY = "#08204A"
CAP_X, CAP_Y, CAP_W, CAP_H, CAP_R = 126, 250, 260, 196, 32


def grid_defs(uid, color=GRID, opacity=".5"):
    return f'<pattern id="grid-{uid}" width="64" height="64" patternUnits="userSpaceOnUse">' \
           f'<path d="M64 0 H0 V64" fill="none" stroke="{color}" stroke-width="2" opacity="{opacity}"/></pattern>'


def master(uid, bg, foreground, defs="", grid_color=GRID, grid_opacity=".5"):
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
<defs>
<clipPath id="art-{uid}"><path d="{squircle(ART, RADIUS, SMOOTH, INSET, INSET)}"/></clipPath>
{grid_defs(uid, grid_color, grid_opacity)}{defs}
</defs>
<g clip-path="url(#art-{uid})">
<rect x="0" y="0" width="1024" height="1024" fill="{bg}"/>
<rect x="0" y="0" width="1024" height="1024" fill="url(#grid-{uid})"/>
<g transform="translate({INSET} {INSET}) scale({SCALE})">
{foreground}
</g>
</g>
</svg>
'''


def face(color, outline_eyes=False):
    """The angry keycap face in 512-space, matching the shipped geometry."""
    brows = (f'<g fill="none" stroke="{color}" stroke-width="16" stroke-linecap="round">'
             f'<path d="M176 300 L228 320"/><path d="M336 300 L284 320"/></g>')
    if outline_eyes:
        eyes = (f'<circle cx="206" cy="346" r="14" fill="none" stroke="{color}" stroke-width="7"/>'
                f'<circle cx="306" cy="346" r="14" fill="none" stroke="{color}" stroke-width="7"/>')
    else:
        eyes = (f'<circle cx="206" cy="346" r="11" fill="{color}"/>'
                f'<circle cx="306" cy="346" r="11" fill="{color}"/>')
    mouth = f'<rect x="214" y="372" width="84" height="30" rx="10" fill="{color}"/>'
    return brows + eyes + mouth


# -- app icon masters -------------------------------------------------------
def drafting(uid):
    return master(uid, PAPER, f'''
<g stroke="{BLUE}" stroke-width="3" fill="none" opacity=".7">
<path d="M64 104 V64 H104"/><path d="M408 64 H448 V104"/>
<path d="M448 408 V448 H408"/><path d="M104 448 H64 V408"/>
</g>
<g stroke="{BLUE}" stroke-width="3" fill="none">
<path d="M126 478 H386"/><path d="M126 464 V492"/><path d="M386 464 V492"/>
</g>
{smoke(BLUE, ".8")}
<rect x="{CAP_X}" y="{CAP_Y + 22}" width="{CAP_W}" height="{CAP_H}" rx="{CAP_R}" fill="{BLUE_D}" opacity=".16"/>
<rect x="{CAP_X}" y="{CAP_Y}" width="{CAP_W}" height="{CAP_H}" rx="{CAP_R}" fill="{PAPER_L}" stroke="{BLUE}" stroke-width="8"/>
<path d="M144 428 H368" stroke="{GRID}" stroke-width="3"/>
{face(BLUE, outline_eyes=True)}''')


def drafting_inverted(uid):
    return master(uid, BLUE_D, f'''
<g stroke="{PAPER_L}" stroke-width="3" fill="none" opacity=".8">
<path d="M64 104 V64 H104"/><path d="M408 64 H448 V104"/>
<path d="M448 408 V448 H408"/><path d="M104 448 H64 V408"/>
</g>
<g stroke="{PAPER_L}" stroke-width="3" fill="none">
<path d="M126 478 H386"/><path d="M126 464 V492"/><path d="M386 464 V492"/>
</g>
{smoke(PAPER_L, ".9")}
<rect x="{CAP_X}" y="{CAP_Y + 22}" width="{CAP_W}" height="{CAP_H}" rx="{CAP_R}" fill="#08204A" opacity=".8"/>
<rect x="{CAP_X}" y="{CAP_Y}" width="{CAP_W}" height="{CAP_H}" rx="{CAP_R}" fill="#1A4A8F" stroke="{PAPER_L}" stroke-width="8"/>
<path d="M144 428 H368" stroke="#7FA8DF" stroke-width="3"/>
{face(PAPER_L)}''', grid_color="#7FA8DF", grid_opacity=".45")


def solid(uid):
    return master(uid, PAPER, f'''
<rect x="{CAP_X}" y="{CAP_Y + 22}" width="{CAP_W}" height="{CAP_H}" rx="{CAP_R}" fill="{NAVY}"/>
<rect x="{CAP_X}" y="{CAP_Y}" width="{CAP_W}" height="{CAP_H}" rx="{CAP_R}" fill="{BLUE}"/>
<rect x="{CAP_X}" y="{CAP_Y}" width="{CAP_W}" height="9" rx="4" fill="{BLUE_M}" opacity=".65"/>
{face(PAPER_L)}''')


def cyanotype(uid):
    return master(uid, BLUE_D, f'''
<rect x="{CAP_X}" y="{CAP_Y + 22}" width="{CAP_W}" height="{CAP_H}" rx="{CAP_R}" fill="#08204A" opacity=".8"/>
<rect x="{CAP_X}" y="{CAP_Y}" width="{CAP_W}" height="{CAP_H}" rx="{CAP_R}" fill="#16407E" stroke="{PAPER_L}" stroke-width="8"/>
{face(PAPER_L)}''', grid_color="#7FA8DF", grid_opacity=".45")


def target(uid):
    return master(uid, PAPER, f'''
<g fill="none" stroke="{BLUE}">
<circle cx="256" cy="256" r="170" stroke-width="4" opacity=".85"/>
<circle cx="256" cy="256" r="120" stroke-width="3" opacity=".5"/>
<circle cx="256" cy="256" r="72" stroke-width="3" opacity=".3"/>
</g>
<g stroke="{GRID}" stroke-width="3" stroke-dasharray="14 12">
<path d="M46 256 H466"/><path d="M256 46 V466"/>
</g>
<g stroke="{BLUE}" stroke-width="3">
<path d="M256 78 V98"/><path d="M256 414 V434"/><path d="M78 256 H98"/><path d="M414 256 H434"/>
</g>
<g transform="translate(0 -92)">{face(BLUE)}</g>''')


def hatch(uid):
    defs = (f'<pattern id="hatch-{uid}" width="18" height="18" patternUnits="userSpaceOnUse" patternTransform="rotate(45)">'
            f'<line x1="0" y1="0" x2="0" y2="18" stroke="{BLUE_M}" stroke-width="4" opacity=".55"/></pattern>')
    return master(uid, PAPER, f'''
<rect x="{CAP_X}" y="{CAP_Y + 22}" width="{CAP_W}" height="{CAP_H}" rx="{CAP_R}" fill="{BLUE_D}" opacity=".18"/>
<rect x="{CAP_X}" y="{CAP_Y}" width="{CAP_W}" height="{CAP_H}" rx="{CAP_R}" fill="url(#hatch-{uid})" stroke="{BLUE}" stroke-width="8"/>
{face(BLUE_D)}''', defs=defs)


APP_ICONS = [
    ("a", "A", "Drafting", "Outlined keycap on graph paper, smoke rising and a dimension line beneath.", drafting("a")),
    ("b", "B", "Solid", "Blueprint-blue keycap with a white knockout face. The loudest of the set.", solid("b")),
    ("c", "C", "Cyanotype", "Deep-blue tile, white linework and grid. The negative of a blueprint.", cyanotype("c")),
    ("d", "D", "Target", "Crosshair and rings with the angry face at centre. No keycap at all.", target("d")),
    ("e", "E", "Hatched", "Graph-paper keycap filled with blue hatching, outlined and stamped with the face.", hatch("e")),
]

# The pick was A. This is A plus its inverted colorway for the final colour call.
A_INVERTED = (
    "a-inverted", "A&#8242;", "Drafting, inverted",
    "The same composition on a deep-blue tile with white linework, like C.",
    drafting_inverted("a-inverted"),
)
FINALIST_ICONS = [APP_ICONS[0], A_INVERTED]

# -- menu bar glyphs --------------------------------------------------------
def glyph_angry_key():
    return f'''<rect x="5" y="6" width="14" height="15" rx="3.4"/>
<g fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round">
<path d="M8 10.6 L11.6 12.4"/><path d="M16 10.6 L12.4 12.4"/>
<path d="M9 17 Q12 14.7 15 17"/></g>'''


def glyph_bolt_key():
    return f'''<rect x="5" y="6" width="14" height="15" rx="3.2"/>
<path d="M13.1 7.6 L9.2 13.1 H11.9 L10.9 18.4 L14.9 12.4 H12.1 Z" fill="currentColor" stroke="none"/>'''


def glyph_fuming_key():
    return f'''<rect x="4.6" y="9" width="14.8" height="12.4" rx="3.2"/>
<g fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round">
<path d="M9.2 6.2 C 7.2 4.8, 9.4 3.4, 7.8 1.8"/>
<path d="M14.8 6.2 C 12.8 4.8, 15 3.4, 13.4 1.8"/></g>'''


def glyph_face_badge():
    return f'''<circle cx="12" cy="12" r="9.2"/>
<g fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round">
<path d="M7.6 9.8 L10.4 11"/><path d="M16.4 9.8 L13.6 11"/>
<path d="M9.2 16.8 Q12 15.2 14.8 16.8"/></g>
<circle cx="9.4" cy="13.2" r=".95" fill="currentColor"/>
<circle cx="14.6" cy="13.2" r=".95" fill="currentColor"/>'''


def glyph_cracked_key():
    return f'''<rect x="5" y="6" width="14" height="15" rx="3.4"/>
<path d="M5 12.2 L8 10.6 L11 13.1 L14 10.6 L17 12.2" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>'''


GLYPHS = [
    ("1", "1", "Angry key", "Single keycap with a scowling face. Square where production is wide.", glyph_angry_key()),
    ("2", "2", "Bolt key", "Keycap struck by a lightning bolt. The boldest mark at 18 px.", glyph_bolt_key()),
    ("3", "3", "Fuming key", "Keycap with two smoke curls rising. Grows upward instead of a side burst.", glyph_fuming_key()),
    ("4", "4", "Face badge", "A scowling face in a ring, no keyboard. Different silhouette entirely.", glyph_face_badge()),
    ("5", "5", "Cracked key", "Keycap split by a jagged crack. Anger as a fracture.", glyph_cracked_key()),
]

# -- write the masters ------------------------------------------------------
for slug, _, _, _, svg in APP_ICONS + [A_INVERTED]:
    (OUT / f"app-icon-blueprint-{slug}.svg").write_text(svg)

for slug, _, _, _, body in GLYPHS:
    inked = body.replace("currentColor", "#000000")
    (OUT / f"menu-bar-glyph-dev-{slug}.svg").write_text(
        f'<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" '
        f'fill="none" stroke="#000000" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">\n{inked}\n</svg>\n'
    )
    (OUT / f"menu-bar-glyph-dev-{slug}-muted.svg").write_text(
        f'<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">\n'
        f'<defs><mask id="gap"><rect width="24" height="24" fill="#ffffff"/>'
        f'<path d="M3.4 3.4 20.6 20.6" stroke="#000000" stroke-width="4.6" stroke-linecap="round"/></mask></defs>\n'
        f'<g mask="url(#gap)" fill="none" stroke="#000000" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">\n{inked}\n</g>\n'
        f'<path d="M3.4 3.4 20.6 20.6" stroke="#000000" stroke-width="2.2" stroke-linecap="round"/>\n</svg>\n'
    )

# -- proof sheets -----------------------------------------------------------
def entries(icons, glyphs_):
    app_entries = [
        {"id": f"app-{s}", "tag": tag, "name": name, "blurb": blurb, "svg": svg}
        for s, tag, name, blurb, svg in icons
    ]
    glyph_entries = [
        {"id": f"glyph-{s}", "tag": tag, "name": name, "blurb": blurb, "body": body}
        for s, tag, name, blurb, body in glyphs_
    ]
    return app_entries, glyph_entries

CSS = r"""
  :root {
    --paper: #eef4fc;
    --paper-2: #e0eaf8;
    --ink: #0a1f42;
    --blue: #1e5cb3;
    --blue-m: #4c88dc;
    --blue-d: #123e80;
    --grey: #5b6f8c;
    --stencil: "Futura", "Avenir Next Condensed", "Helvetica Neue", sans-serif;
    --ui: -apple-system, BlinkMacSystemFont, "SF Pro Text", "Helvetica Neue", Arial, sans-serif;
    --mono: "SF Mono", ui-monospace, Menlo, "Courier New", monospace;
  }
  * { box-sizing: border-box; }
  html, body { margin: 0; }
  body {
    background: var(--blue-d); color: var(--ink); font: 15px/1.55 var(--ui);
    -webkit-font-smoothing: antialiased; padding: 34px 20px 130px;
  }
  .sheet {
    position: relative; max-width: 1120px; margin: 0 auto;
    background: var(--paper);
    background-image: linear-gradient(rgba(30,92,179,.10) 1px, transparent 1px),
                      linear-gradient(90deg, rgba(30,92,179,.10) 1px, transparent 1px);
    background-size: 28px 28px;
    border: 2px solid var(--ink); box-shadow: 10px 10px 0 rgba(0,0,0,.5);
  }
  .band { display: flex; align-items: flex-end; gap: 22px; background: var(--blue-d); color: var(--paper); padding: 22px 26px 18px; }
  .wordmark { font-family: var(--stencil); text-transform: uppercase; font-weight: 800; font-size: 42px; line-height: .95; letter-spacing: .02em; }
  .wordmark em { font-style: normal; color: var(--blue-m); }
  .band-sub { font-family: var(--mono); font-size: 12px; letter-spacing: .14em; text-transform: uppercase; color: #b9cdea; padding-bottom: 6px; }
  .stamp {
    margin-left: auto; text-align: center; border: 3px solid var(--paper); color: var(--paper);
    transform: rotate(-4deg); padding: 8px 14px 7px; font-family: var(--stencil); text-transform: uppercase; line-height: 1;
  }
  .stamp b { display: block; font-size: 24px; letter-spacing: .03em; }
  .stamp span { display: block; font-family: var(--mono); font-size: 9.5px; letter-spacing: .13em; margin-top: 4px; }

  .specstrip {
    display: flex; flex-wrap: wrap; gap: 8px 26px; border-bottom: 2px solid var(--ink); padding: 11px 26px;
    font-family: var(--mono); font-size: 12px; letter-spacing: .05em; text-transform: uppercase; color: var(--grey);
    background: var(--paper-2);
  }
  .specstrip b { color: var(--ink); }

  .pinned {
    display: flex; align-items: center; gap: 16px; flex-wrap: wrap;
    padding: 16px 26px; border-bottom: 2px dashed rgba(10,31,66,.4);
  }
  .pinned .tag {
    font-family: var(--stencil); text-transform: uppercase; font-weight: 700; font-size: 17px; letter-spacing: .03em;
    background: var(--blue-d); color: var(--paper); padding: 5px 10px 4px;
  }
  .pinned .chip { display: inline-flex; align-items: center; gap: 8px; font-family: var(--mono); font-size: 11px; text-transform: uppercase; color: var(--grey); }
  .pinned .chip .cell { width: 34px; height: 34px; display: grid; place-items: center; }
  .pinned .chip svg { display: block; width: 100%; height: 100%; }

  .tray { padding: 26px; }
  .tray-head { display: flex; align-items: baseline; gap: 14px; flex-wrap: wrap; margin-bottom: 4px; }
  .tray-head h2 { font-family: var(--stencil); text-transform: uppercase; font-weight: 800; font-size: 25px; letter-spacing: .02em; margin: 0; }
  .tray-head .caliber { font-family: var(--mono); font-size: 12px; letter-spacing: .09em; text-transform: uppercase; color: var(--blue); border: 2px solid var(--blue); padding: 2px 7px; }
  .tray-note { color: var(--grey); margin: 6px 0 20px; max-width: 78ch; }

  .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 20px; }
  .grid.glyphs { grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); }

  .box { background: #fff; border: 2px solid var(--ink); box-shadow: 5px 5px 0 var(--ink); padding: 14px; position: relative; }
  .box:focus-within, .box.is-focus { outline: 3px solid var(--blue); outline-offset: 3px; }
  .callsign { position: absolute; top: -2px; left: -2px; background: var(--blue-d); color: var(--paper); font-family: var(--stencil); font-weight: 800; font-size: 21px; line-height: 1; padding: 5px 11px 4px; }
  .box-head { display: flex; justify-content: flex-end; margin-bottom: 4px; }
  .copy { appearance: none; cursor: pointer; font-family: var(--mono); font-size: 10.5px; letter-spacing: .09em; text-transform: uppercase; background: transparent; color: var(--ink); border: 2px solid var(--ink); padding: 4px 8px; }
  .copy:hover { background: var(--ink); color: var(--paper); }
  .tile { width: 188px; height: 188px; margin: 8px auto 14px; display: block; }
  .tile svg { width: 100%; height: 100%; display: block; }
  .box h3 { font-family: var(--stencil); text-transform: uppercase; font-weight: 700; font-size: 20px; letter-spacing: .02em; margin: 0 0 3px; }
  .box p { margin: 0; font-size: 13px; color: #44536b; }

  .ladder { display: flex; align-items: flex-end; gap: 16px; margin-top: 14px; padding-top: 12px; border-top: 2px dotted rgba(10,31,66,.3); }
  .ladder figure { margin: 0; text-align: center; font-family: var(--mono); font-size: 10px; color: var(--grey); }
  .ladder .g { display: block; margin: 0 auto 6px; }
  .ladder .g svg { display: block; width: 100%; height: 100%; }
  .g128 { width: 70px; height: 70px; }
  .g64  { width: 48px; height: 48px; }
  .g32  { width: 32px; height: 32px; }
  .g16  { width: 18px; height: 18px; }

  .rail { display: flex; align-items: center; gap: 20px; height: 40px; padding: 0 14px; border: 2px solid var(--ink); margin: 6px 0; }
  .rail.light { background: #f4f4f4; color: #111; }
  .rail.dark  { background: #1b1b1e; color: #f2f2f2; }
  .rail .cell { display: grid; place-items: center; width: 24px; height: 24px; }
  .rail .cell svg { display: block; width: 18px; height: 18px; }
  .rail .cell.big svg { width: 36px; height: 36px; }
  .rail .cell.big { width: 42px; height: 42px; }
  .rail .cap { font-family: var(--mono); font-size: 10px; letter-spacing: .08em; text-transform: uppercase; opacity: .7; }
  .rail .spacer { flex: 1; }

  .notes { margin: 0 26px 26px; padding: 20px 22px; border: 3px solid var(--blue); }
  .notes h3 { font-family: var(--stencil); text-transform: uppercase; font-weight: 800; font-size: 18px; letter-spacing: .03em; margin: 0 0 10px; color: var(--blue); }
  .notes ul { margin: 0; padding-left: 20px; }
  .notes li { margin: 6px 0; }
  .notes code { font-family: var(--mono); font-size: 12.5px; background: rgba(30,92,179,.1); padding: 1px 5px; }

  .ranger { position: fixed; left: 50%; bottom: 20px; transform: translateX(-50%); display: flex; align-items: center; gap: 4px; z-index: 40; background: var(--blue-d); color: var(--paper); border: 2px solid var(--paper); box-shadow: 6px 6px 0 rgba(0,0,0,.5); padding: 6px; }
  .ranger button { appearance: none; border: 0; background: transparent; color: var(--paper); width: 34px; height: 34px; cursor: pointer; font-size: 16px; display: grid; place-items: center; }
  .ranger button:hover { background: rgba(238,244,252,.16); }
  .ranger .label { min-width: 250px; text-align: center; padding: 0 8px; }
  .ranger .label b { font-family: var(--stencil); text-transform: uppercase; font-weight: 800; font-size: 17px; letter-spacing: .03em; color: var(--blue-m); }
  .ranger .label small { display: block; font-family: var(--mono); font-size: 10px; letter-spacing: .09em; color: #b9cdea; }
"""

JS = r"""
const $ = (s) => document.querySelector(s);

function muted(body, uid) {
  return `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">
  <defs><mask id="gap${uid}"><rect width="24" height="24" fill="#fff"/>
  <path d="M3.4 3.4 20.6 20.6" stroke="#000" stroke-width="4.6" stroke-linecap="round"/></mask></defs>
  <g mask="url(#gap${uid})">${body}</g>
  <path d="M3.4 3.4 20.6 20.6" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/></svg>`;
}

function glyph(body) {
  return `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">${body}</svg>`;
}

function ladder(svg) {
  const sizes = [["g128", 128], ["g64", 64], ["g32", 32], ["g16", 16]];
  return `<div class="ladder">${sizes.map(([cls, px]) =>
    `<figure><span class="g ${cls}">${svg}</span><figcaption>${px}</figcaption></figure>`).join("")}</div>`;
}

APP_ICONS.forEach((icon) => {
  const box = document.createElement("div");
  box.className = "box";
  box.dataset.id = icon.id;
  box.innerHTML = `
    <span class="callsign">${icon.tag}</span>
    <div class="box-head"><button class="copy" data-copy="${icon.id}">Copy SVG</button></div>
    <div class="tile">${icon.svg}</div>
    <h3>${icon.name}</h3>
    <p>${icon.blurb}</p>
    ${ladder(icon.svg)}`;
  $("#appGrid").appendChild(box);
});

GLYPHS.forEach((g) => {
  const box = document.createElement("div");
  box.className = "box";
  box.dataset.id = g.id;
  const normal = glyph(g.body);
  const off = muted(g.body, g.tag);
  box.innerHTML = `
    <span class="callsign">${g.tag}</span>
    <div class="box-head"><button class="copy" data-copy="${g.id}">Copy SVG</button></div>
    <div class="rail light"><span class="cell">${normal}</span><span class="cell big">${normal}</span><span class="spacer"></span><span class="cap">light</span></div>
    <div class="rail dark"><span class="cell">${normal}</span><span class="cell big">${normal}</span><span class="spacer"></span><span class="cap">dark</span></div>
    <div class="rail light"><span class="cell">${off}</span><span class="cell big">${off}</span><span class="spacer"></span><span class="cap">muted</span></div>
    <h3>${g.name}</h3>
    <p>${g.blurb}</p>`;
  $("#glyphGrid").appendChild(box);
});

function copyText(text) {
  if (navigator.clipboard && window.isSecureContext) {
    navigator.clipboard.writeText(text).catch(() => legacyCopy(text));
  } else { legacyCopy(text); }
}
function legacyCopy(text) {
  const ta = document.createElement("textarea");
  ta.value = text; ta.style.position = "fixed"; ta.style.opacity = "0";
  document.body.appendChild(ta); ta.select();
  try { document.execCommand("copy"); } catch (_) {}
  ta.remove();
}

const ALL = APP_ICONS.map((x) => ({ id: x.id, tag: x.tag, name: x.name, kind: "icon" }))
  .concat(GLYPHS.map((x) => ({ id: x.id, tag: x.tag, name: x.name, kind: "glyph" })));

function hashParam(name) {
  const m = location.hash.match(new RegExp(name + "=([0-9]+)"));
  return m ? parseInt(m[1], 10) : null;
}
let idx = Math.max(0, Math.min(ALL.length - 1, hashParam("i") ?? 0));

function focusItem(scroll) {
  document.querySelectorAll(".box.is-focus").forEach((b) => b.classList.remove("is-focus"));
  const item = ALL[idx];
  const box = document.querySelector(`.box[data-id="${item.id}"]`);
  if (box) { box.classList.add("is-focus"); if (scroll) box.scrollIntoView({ behavior: "smooth", block: "center" }); }
  $("#rLabel").innerHTML = `<b>${item.kind === "icon" ? "Icon" : "Glyph"} ${item.tag}</b> ${item.name}` +
    `<small>${idx + 1} / ${ALL.length} \u00b7 ${PICK_HINT}</small>`;
  history.replaceState(null, "", `#i=${idx}`);
}
$("#prev").onclick = () => { idx = (idx - 1 + ALL.length) % ALL.length; focusItem(true); };
$("#next").onclick = () => { idx = (idx + 1) % ALL.length; focusItem(true); };
document.addEventListener("keydown", (e) => {
  const t = e.target;
  if (t && t.closest("input, textarea, [contenteditable]")) return;
  if (e.key === "ArrowLeft") { e.preventDefault(); $("#prev").click(); }
  if (e.key === "ArrowRight") { e.preventDefault(); $("#next").click(); }
});
document.addEventListener("click", (e) => {
  const copy = e.target.closest("[data-copy]");
  if (copy) {
    const id = copy.dataset.copy;
    const src = APP_ICONS.find((x) => x.id === id);
    copyText(src ? src.svg : glyph((GLYPHS.find((x) => x.id === id) || {}).body));
    copy.textContent = "Copied";
    setTimeout(() => (copy.textContent = "Copy SVG"), 1100);
    return;
  }
  const box = e.target.closest(".box");
  if (box) { const i = ALL.findIndex((x) => x.id === box.dataset.id); if (i >= 0) { idx = i; focusItem(false); } }
});
focusItem(false);
"""

PRODUCTION_ICON = (OUT / "app-icon-blackout.svg").read_text()
PRODUCTION_GLYPH = (OUT / "menu-bar-glyph.svg").read_text()
SHEET_REFINED = OUT.parent / "icon-prototype-dev-blueprint-refined.html"


def glyph_markup(body):
    return ('<svg viewBox="0 0 24 24" fill="none" stroke="#000000" stroke-width="1.7" '
            'stroke-linecap="round" stroke-linejoin="round">' + body + '</svg>')


def render_sheet(path, app_entries, glyph_entries, meta):
    html = (
        "<!doctype html>\n"
        "<!--\n"
        + meta["comment"]
        + "-->\n"
        '<html lang="en">\n<head>\n<meta charset="utf-8">\n'
        '<meta name="viewport" content="width=device-width, initial-scale=1">\n'
        + f"<title>{meta['title']}</title>\n"
        + f"<style>{CSS}</style>\n</head>\n<body>\n"
        '<div class="sheet">\n'
        '  <header class="band">\n'
        '    <div class="wordmark">ANGRY<em>KEYBOARD</em></div>\n'
        + f'    <div class="band-sub">{meta["subtitle"]}</div>\n'
        + f'    <div class="stamp"><b>{meta["stamp_top"]}</b><span>{meta["stamp_sub"]}</span></div>\n'
        "  </header>\n"
        '  <div class="specstrip">\n'
        + "".join(f"    <span>{s}</span>\n" for s in meta["spec"])
        + "  </div>\n"
        '  <div class="pinned">\n'
        + meta["pinned"]
        + "  </div>\n"
        '  <section class="tray">\n'
        + f'    <div class="tray-head"><h2>App icon</h2><span class="caliber">{meta["app_caliber"]}</span></div>\n'
        + f'    <p class="tray-note">{meta["app_note"]}</p>\n'
        '    <div class="grid" id="appGrid"></div>\n'
        "  </section>\n"
        '  <section class="tray">\n'
        '    <div class="tray-head"><h2>Menu bar glyph</h2><span class="caliber">Shape, not colour</span></div>\n'
        + f'    <p class="tray-note">{meta["glyph_note"]}</p>\n'
        '    <div class="grid glyphs" id="glyphGrid"></div>\n'
        "  </section>\n"
        '  <div class="notes">\n'
        + f'    <h3>{meta["notes_head"]}</h3>\n'
        "    <ul>\n"
        + "".join(f"      <li>{li}</li>\n" for li in meta["notes"])
        + "    </ul>\n"
        "  </div>\n"
        "</div>\n"
        '<div class="ranger" id="ranger">\n'
        '  <button id="prev" title="Previous (left arrow)" aria-label="Previous">&larr;</button>\n'
        '  <div class="label" id="rLabel"></div>\n'
        '  <button id="next" title="Next (right arrow)" aria-label="Next">&rarr;</button>\n'
        "</div>\n"
        "<script>\n"
        "const APP_ICONS = " + json.dumps(app_entries) + ";\n"
        "const GLYPHS = " + json.dumps(glyph_entries) + ";\n"
        "const PICK_HINT = " + json.dumps(meta["pick_hint"]) + ";\n"
        + JS +
        "</script>\n</body>\n</html>\n"
    )
    path.write_text(html)


CANDIDATE_PINNED = (
    '    <span class="tag">Production rides along</span>\n'
    f'    <span class="chip"><span class="cell" style="width:34px;height:34px">{PRODUCTION_ICON}</span> AppIcon</span>\n'
    f'    <span class="chip"><span class="cell">{PRODUCTION_GLYPH}</span> MenuBarGlyph</span>\n'
    '    <span class="chip">Neither changes. Dev only.</span>\n'
)

render_sheet(
    SHEET,
    *entries(APP_ICONS, GLYPHS),
    meta={
        "comment": (
            "  PROTOTYPE (dev blueprint) - throwaway, not production.\n"
            "  Question: which white-and-blue app icon and menu bar glyph give the dev\n"
            "  channel its own identity?\n\n"
            "  Five app icons (A-E) on Apple's icon grid, five menu bar glyphs (1-5) with\n"
            "  muted variants, each shown in light and dark menu bars. Flip with the\n"
            "  ranger bar or the left/right arrow keys.\n\n"
            "  Run: open .scratch/branding/icon-prototype-dev-blueprint.html\n"
        ),
        "title": "AngryKeyboard - dev blueprint identity",
        "subtitle": "Dev channel proof sheet<br>Blueprint identity",
        "stamp_top": "DEV",
        "stamp_sub": "WHITE + BLUE",
        "spec": [
            "<b>5</b> app icons",
            "<b>5</b> menu bar glyphs",
            "production <b>unchanged</b>",
            "cycle <b>&larr; &rarr;</b>",
        ],
        "pinned": CANDIDATE_PINNED,
        "app_caliber": "White and blue",
        "app_note": (
            "Five directions, all on Apple&rsquo;s macOS icon grid. Compare the 32 and 16 px "
            "rungs: the face and any dimension marks have to survive there. The chosen "
            "master rasterizes into <code>AppIconDev.appiconset</code> for the Debug channel only."
        ),
        "glyph_note": (
            "The status item is a template image, so macOS recolours it and the blueprint "
            "palette cannot show. Only the shape carries the identity. These all differ from "
            "production&rsquo;s keyboard-and-burst silhouette. Muted is the same shape struck "
            "through, matching production&rsquo;s convention."
        ),
        "notes_head": "After the pick",
        "notes": [
            "The chosen master rasterizes with <code>./make-app-icon.sh app-icon-blueprint-&lt;x&gt;.svg AppIconDev</code>, and Debug already points at <code>AppIconDev</code>.",
            "The chosen glyph gets its own imageset, with a muted variant, and <code>Config/Debug.xcconfig</code> names it. Production&rsquo;s keys and artwork stay as they are.",
            "Tell me the app icon letter and the glyph number. For example, &ldquo;icon C, glyph 3&rdquo;.",
        ],
        "pick_hint": "pick one of each",
    },
)

REFINED_PINNED = (
    '    <span class="tag">Glyph 3 pinned</span>\n'
    f'    <span class="chip"><span class="cell">{glyph_markup(GLYPHS[2][4])}</span> MenuBarGlyphDev</span>\n'
    '    <span class="chip">Production&rsquo;s icon and glyph are untouched.</span>\n'
)

render_sheet(
    SHEET_REFINED,
    *entries(FINALIST_ICONS, [GLYPHS[2]]),
    meta={
        "comment": (
            "  PROTOTYPE (dev blueprint refinement) - throwaway, not production.\n"
            "  Question: white or inverted for app icon A?\n\n"
            "  A keeps its dimension line and gains the rising smoke. The inverted colourway\n"
            "  puts the same composition on a deep-blue tile with white linework. Glyph 3 is\n"
            "  pinned. Flip with the ranger bar or the left/right arrow keys.\n\n"
            "  Run: open .scratch/branding/icon-prototype-dev-blueprint-refined.html\n"
        ),
        "title": "AngryKeyboard - dev blueprint refinement",
        "subtitle": "Dev channel refinement<br>A, two colourways",
        "stamp_top": "PICK ONE",
        "stamp_sub": "COLOURWAY",
        "spec": [
            "<b>2</b> colourways",
            "glyph <b>3</b> pinned",
            "production <b>unchanged</b>",
            "cycle <b>&larr; &rarr;</b>",
        ],
        "pinned": REFINED_PINNED,
        "app_caliber": "White or blue",
        "app_note": (
            "Your pick was A. Both colourways carry the dimension line and the smoke from "
            "production, drawn in the blueprint palette. The inverted tile matches C&rsquo;s "
            "negative. Check the 32 and 16 px rungs before choosing."
        ),
        "glyph_note": (
            "Glyph 3, the fuming key, is pinned. It grows upward with two smoke curls, "
            "unlike production&rsquo;s keyboard and side burst. Shown in light, dark, and muted."
        ),
        "notes_head": "Next",
        "notes": [
            "Tell me which colourway, white or inverted.",
            "Then it rasterizes into <code>AppIconDev</code>, and glyph 3 ships as its own imageset with a muted variant.",
            "Production&rsquo;s icon and glyph stay as they are.",
        ],
        "pick_hint": "pick a colourway",
    },
)

print("wrote app icons:", ", ".join(f"app-icon-blueprint-{s}.svg" for s, *_ in APP_ICONS + [A_INVERTED]))
print("wrote glyphs:", ", ".join(f"menu-bar-glyph-dev-{s}.svg" for s, *_ in GLYPHS))
print("wrote", SHEET.relative_to(OUT.parent.parent.parent))
print("wrote", SHEET_REFINED.relative_to(OUT.parent.parent.parent))
