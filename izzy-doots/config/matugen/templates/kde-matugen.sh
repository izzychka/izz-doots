#!/bin/bash

hexrgb() {
    local h="${1#\#}"
    printf "%d,%d,%d" \
        "$((16#${h:0:2}))" \
        "$((16#${h:2:2}))" \
        "$((16#${h:4:2}))"
}

BG="{{colors.background.default.hex}}"
SURFACE="{{colors.surface.default.hex}}"
SURFACE_LOW="{{colors.surface_container_low.default.hex}}"
SURFACE_CONTAINER="{{colors.surface_container.default.hex}}"
SURFACE_HIGH="{{colors.surface_container_high.default.hex}}"

ON_SURFACE="{{colors.on_surface.default.hex}}"
ON_SURFACE_VARIANT="{{colors.on_surface_variant.default.hex}}"

PRIMARY="{{colors.primary.default.hex}}"
PRIMARY_CONTAINER="{{colors.primary_container.default.hex}}"
ON_PRIMARY_CONTAINER="{{colors.on_primary_container.default.hex}}"

SECONDARY="{{colors.secondary.default.hex}}"
TERTIARY="{{colors.tertiary.default.hex}}"

ERROR="{{colors.error.default.hex}}"
OUTLINE="{{colors.outline.default.hex}}"
OUTLINE_VARIANT="{{colors.outline_variant.default.hex}}"

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
