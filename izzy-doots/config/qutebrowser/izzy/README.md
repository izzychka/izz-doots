# Izzy qutebrowser

A quiet, terminal-style homepage inspired by your reference: original line-art desk,
Maple Mono, grouped links and a greeting. The screenshot's surrounding landscape and
window placement belong to the desktop, not the homepage. Float/resize qutebrowser
with your existing Hyprland controls if you want that framing.

## Install

On Arch: sudo pacman -S qutebrowser python-adblock
Run python3 ~/Downloads/izzy-qutebrowser-install.py without sudo, then qutebrowser.
This uses your existing Matugen configuration and seeds colours from Izzy Island.
Close qutebrowser before installing. Firefox/default-browser settings are untouched.
Run :adblock-update once inside qutebrowser to fetch the initial blocking lists.

## Keys

o: open/search; t: new tab; f: follow a link; J/K: switch tabs; d: close tab;
u: reopen closed tab; r: refresh; Escape: return to normal mode.
,h: homepage; ,b: toggle tab visibility; ,s: toggle statusbar visibility;
,d: toggle Dark Reader on the current website (stored for that origin when allowed).
Tabs appear briefly when switching. Commands and input mode reveal the statusbar.

## Matugen and websites

One new templates.izzy_qutebrowser entry generates a dark palette and runs refresh.py.
This generates UI colours, homepage CSS and a local Greasemonkey userscript using
Dark Reader 4.9.132's API. Its MIT license is included in DARKREADER-LICENSE.
The engine is bundled locally; no script CDN is contacted by visited pages.
Dark Reader is enabled on ordinary HTTP(S) sites, not on the custom start page.
The API/userscript has fewer capabilities than the Firefox extension: cross-origin
stylesheets, embedded frames, browser-internal pages and some websites may not
recolour completely. Toggle it with ,d on problematic sites.

When qutebrowser's standard process is running, the hook reloads its UI palette and
userscript definitions. New page loads use the new colours. Existing pages need r;
we do not reload every tab because that can interrupt forms, videos and work.
If running under a custom launcher/profile and automatic detection fails, run
:config-source followed by :greasemonkey-reload, then refresh the page.
The homepage picks up updated CSS when refreshed. It remains usable without scripts.

Edit ~/.config/qutebrowser/izzy/home/index.html to change links or the greeting.
Edit ~/.config/qutebrowser/izzy/style.py for browser UI preferences.
Maple Mono must already be installed (normal and NF family names are supported).
Re-running the installer backs up and replaces these managed files, including edits.
Other Matugen templates and existing qutebrowser config outside the marked block
are preserved. All overwritten files are backed up, with paths recorded in
~/.local/state/izzy-qute/backups/<timestamp>/manifest.json.

## Sources / validation

https://qutebrowser.org/doc/help/settings.html
https://qutebrowser.org/doc/help/commands.html
https://github.com/darkreader/darkreader
Dark Reader npm distribution integrity verified during packaging.
Installer and palette generation checked in an isolated temporary home.
Browser rendering is not a guarantee that every website will theme correctly.
