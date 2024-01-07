local wezterm = require 'wezterm';
local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback({ "JetBrains Mono", "Apple Color Emoji" })
config.font_size = 14.0
config.initial_cols = 120
config.initial_rows = 30
--config.window_background_opacity = 0.8
--config.color_scheme = "Mirage"
config.color_scheme = "Catppuccin Mocha"
config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 10000
config.tab_bar_at_bottom = true
config.use_cap_height_to_scale_fallback_fonts = true
config.adjust_window_size_when_changing_font_size = false
config.custom_block_glyphs = true
config.keys = {
    { key = 'PageUp',   mods = 'SUPER', action = wezterm.action.ScrollByPage(-0.5) },
    { key = 'PageDown', mods = 'SUPER', action = wezterm.action.ScrollByPage(0.5) },
    {
    -- This will create a new split and run your default program inside it
        key = "Enter",
        mods = "CTRL|SHIFT",
        action = wezterm.action { SplitVertical = { domain = "CurrentPaneDomain" } }
    },
    {
        key = "%",
        mods = "CTRL|SHIFT",
        action = wezterm.action { SplitHorizontal = { domain = "CurrentPaneDomain" } }
    },
    { key = "Z", mods = "CTRL|SHIFT", action = "TogglePaneZoomState" },
    {
        key = "Q",
        mods = "CTRL|SHIFT",
        action = wezterm.action.QuickSelectArgs {
            label = 'open url',
            patterns = {
                'https?://\\S+',
            },
            action = wezterm.action_callback(function(window, pane)
                local url = window:get_selection_text_for_pane(pane)
                wezterm.log_info('opening: ' .. url)
                wezterm.open_with(url)
            end),
        },
    },
    {
        key = 'R',
        mods = 'CMD|SHIFT',
        action = wezterm.action.PromptInputLine {
            description = 'Enter new name for tab',
            action = wezterm.action_callback(function(window, pane, line)
                if line then
                    window:active_tab():set_title(line)
                end
            end)
        }
    }
}

return config
