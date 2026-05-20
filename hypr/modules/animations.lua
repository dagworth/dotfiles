hl.curve("clean_spring", { type = "spring", mass = 1.0, stiffness = 140, dampening = 24 })
hl.curve("fade_curve", { type = "bezier", points = { { 0.25, 1.0 }, { 0.25, 1.0 } } })

hl.animation { leaf = "windows", enabled = true, speed = 2, spring = "clean_spring" }
hl.animation { leaf = "workspaces", enabled = true, speed = 2, spring = "clean_spring", style = "slide" }
hl.animation { leaf = "fade", enabled = true, speed = 1, bezier = "fade_curve" }