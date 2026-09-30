#!/bin/bash

hexrgb() {
    local h="${1#\#}"
    printf "%d,%d,%d" \
        "$((16#${h:0:2}))" \
        "$((16#${h:2:2}))" \
        "$((16#${h:4:2}))"
}

BG="#1e1e2e"
SURFACE="#1e1e2e"
SURFACE_LOW="#181825"
SURFACE_CONTAINER="#313244"
SURFACE_HIGH="#45475a"

ON_SURFACE="#cdd6f4"
ON_SURFACE_VARIANT="#bac2de"

PRIMARY="#cba6f7"
PRIMARY_CONTAINER="#585b70"
ON_PRIMARY_CONTAINER="#b4befe"

SECONDARY="#89b4fa"
TERTIARY="#f5c2e7"

ERROR="#f38ba8"
OUTLINE="#7f849c"
OUTLINE_VARIANT="#585b70"

mkdir -p "$HOME/.local/share/color-schemes"

cat > "$HOME/.local/share/color-schemes/Matugen.colors" <<EOF
[General]
Name=Matugen
ColorScheme=Matugen
shadeSortColumn=true

[KDE]
contrast=4

[Colors:Window]
BackgroundNormal=$(hexrgb "$BG")
ForegroundNormal=$(hexrgb "$ON_SURFACE")
DecorationFocus=$(hexrgb "$PRIMARY")
DecorationHover=$(hexrgb "$PRIMARY")

[Colors:View]
BackgroundNormal=$(hexrgb "$BG")
BackgroundAlternate=$(hexrgb "$SURFACE_LOW")
ForegroundNormal=$(hexrgb "$ON_SURFACE")
ForegroundInactive=$(hexrgb "$ON_SURFACE_VARIANT")
ForegroundLink=$(hexrgb "$PRIMARY")
ForegroundVisited=$(hexrgb "$TERTIARY")
ForegroundActive=$(hexrgb "$PRIMARY")
ForegroundNegative=$(hexrgb "$ERROR")
ForegroundNeutral=$(hexrgb "$SECONDARY")
ForegroundPositive=$(hexrgb "$TERTIARY")
DecorationFocus=$(hexrgb "$PRIMARY")
DecorationHover=$(hexrgb "$PRIMARY")

[Colors:Button]
BackgroundNormal=$(hexrgb "$SURFACE_CONTAINER")
BackgroundAlternate=$(hexrgb "$SURFACE_HIGH")
ForegroundNormal=$(hexrgb "$ON_SURFACE")
ForegroundInactive=$(hexrgb "$ON_SURFACE_VARIANT")
DecorationFocus=$(hexrgb "$PRIMARY")
DecorationHover=$(hexrgb "$PRIMARY")

[Colors:Selection]
BackgroundNormal=$(hexrgb "$PRIMARY_CONTAINER")
ForegroundNormal=$(hexrgb "$ON_PRIMARY_CONTAINER")
DecorationFocus=$(hexrgb "$PRIMARY")
DecorationHover=$(hexrgb "$PRIMARY")

[Colors:Tooltip]
BackgroundNormal=$(hexrgb "$SURFACE_HIGH")
ForegroundNormal=$(hexrgb "$ON_SURFACE")

[Colors:Header]
BackgroundNormal=$(hexrgb "$SURFACE_LOW")
BackgroundAlternate=$(hexrgb "$SURFACE_CONTAINER")
ForegroundNormal=$(hexrgb "$ON_SURFACE")
ForegroundInactive=$(hexrgb "$ON_SURFACE_VARIANT")
DecorationFocus=$(hexrgb "$PRIMARY")
DecorationHover=$(hexrgb "$PRIMARY")

[Colors:Complementary]
BackgroundNormal=$(hexrgb "$SURFACE_CONTAINER")
ForegroundNormal=$(hexrgb "$ON_SURFACE")
DecorationFocus=$(hexrgb "$PRIMARY")
DecorationHover=$(hexrgb "$PRIMARY")

[WM]
activeBackground=$(hexrgb "$SURFACE_CONTAINER")
activeForeground=$(hexrgb "$ON_SURFACE")
inactiveBackground=$(hexrgb "$SURFACE_LOW")
inactiveForeground=$(hexrgb "$ON_SURFACE_VARIANT")
EOF

plasma-apply-colorscheme BreezeDark
plasma-apply-colorscheme Matugen
