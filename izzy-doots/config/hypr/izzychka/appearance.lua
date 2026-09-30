local ok, colors = pcall(require, "izzychka.colors")

if not ok then
    colors = {
        primary = "rgba(89b4faff)",
        outline_variant = "rgba(45475aff)",
    }
end

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 1,
        col = {
            active_border = colors.primary,
            inactive_border = colors.outline_variant,
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 7,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 8,
            render_power = 3,
            color = 0xaa1a1a1a,
        },
        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            vibrancy = 0.17,
        },
    },
    animations = {
        enabled = true,
    },
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = false,
    },
    input = {
        kb_layout = "gb",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
            tap_to_click = true,
            tap_and_drag = true,
        },
        touchdevice = {
            output = "eDP-1",
            transform = 0,
            enabled = true,
        },
    },
    gestures = {
        workspace_swipe_touch = true,
        workspace_swipe_touch_invert = false,
        workspace_swipe_distance = 300,
        workspace_swipe_cancel_ratio = 0.30,
        workspace_swipe_min_speed_to_force = 20,
        workspace_swipe_create_new = false,
    },
    cursor = {
        hide_on_touch = true,
        inactive_timeout = 3,
    },
})
