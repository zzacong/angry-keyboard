# AngryKeyboard repo tasks.
#
# Recipes are prefixed by what they act on: site- for the Astro site in site/,
# app- for the Xcode app. Only the recipes reached for most often live here.
# Everything else is one command away:
#
#     pnpm --dir site run <script>
#
# Remaining scripts include preview, typecheck, test, lint, lint:fix, dev:bg,
# dev:stop, and dev:logs.

set shell := ["bash", "-euo", "pipefail", "-c"]

site := "site"

# List the available recipes.
default:
    just --list

# --- Site ---

# Install site dependencies.
site-install:
    pnpm --dir {{site}} install

# Run the site dev server. Extra arguments pass through to Astro, e.g. --host.
site-dev *args:
    pnpm --dir {{site}} run dev {{args}}

# Build the site for production.
site-build:
    pnpm --dir {{site}} run build

# Serve the built site locally. Extra arguments pass through, e.g. --host.
site-preview *args:
    pnpm --dir {{site}} run preview {{args}}

# Typecheck, format-check, and lint the site.
site-check:
    pnpm --dir {{site}} run check

# Format the site.
site-fmt:
    pnpm --dir {{site}} run fmt

# --- Xcode app ---

# Build the app in Debug into build/.
app-build:
    xcodebuild -scheme AngryKeyboard -configuration Debug -derivedDataPath build build

# Build the Debug app, then open it. Debug ships as the AngryKeyboardDev channel.
app-run: app-build
    open build/Build/Products/Debug/AngryKeyboardDev.app

# Run the app test suite on macOS, into the same build/ as app-build.
app-test:
    xcodebuild test -scheme AngryKeyboard -destination 'platform=macOS' -derivedDataPath build
