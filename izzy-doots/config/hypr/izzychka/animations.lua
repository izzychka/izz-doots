hl.curve("softSpring", {
    type = "spring",
    mass = 1,
    stiffness = 280,
    dampening = 28,
})

hl.curve("easeOut", {
    type = "bezier",
    points = { {0.16, 1.0}, {0.30, 1.0} },
})

hl.curve("easeInOut", {
    type = "bezier",
    points = { {0.65, 0.0}, {0.35, 1.0} },
})

hl.curve("quickFade", {
    type = "bezier",
    points = { {0.25, 0.1}, {0.25, 1.0} },
})

hl.animation({ leaf = "global", enabled = true, speed = 4.0, bezier = "easeOut" })
hl.animation({ leaf = "border", enabled = true, speed = 2.5, bezier = "easeOut" })
hl.animation({ leaf = "windows", enabled = true, speed = 3.5, spring = "softSpring" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.3, spring = "softSpring", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.2, bezier = "quickFade", style = "popin 96%" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.5, bezier = "quickFade" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.0, bezier = "easeOut" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3.0, bezier = "easeOut", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 2.0, bezier = "quickFade", style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4.0, bezier = "easeInOut", style = "slidefade 18%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3.5, spring = "softSpring", style = "slidevert 18%" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 3.0, bezier = "easeOut" })
