local wezterm = require 'wezterm';
local config = wezterm.config_builder();

config.font = wezterm.font_with_fallback({ "JetBrains Mono", "Apple Color Emoji" })
config.font_size = 14.0
config.font_rules = {
    {
        intensity = "Bold",
        italic = false,
        font = wezterm.font("JetBrains Mono", { weight = "Bold", stretch = "Normal", style = "Normal" }),
    },
    {
        intensity = "Bold",
        italic = true,
        font = wezterm.font("JetBrains Mono", { weight = "Bold", stretch = "Normal", style = "Italic" }),
    },
}

config.initial_cols = 120
config.initial_rows = 30
config.color_scheme = "Catppuccin Mocha"
config.hide_tab_bar_if_only_one_tab = true
config.scrollback_lines = 10000
config.tab_bar_at_bottom = true
config.use_cap_height_to_scale_fallback_fonts = true
config.adjust_window_size_when_changing_font_size = false
config.custom_block_glyphs = true


-- Hyperlink rules
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- make username/project paths clickable for github
table.insert(config.hyperlink_rules, {
    regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
    format = 'https://www.github.com/$1/$3',
})

-- Shortcuts
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
}

-- # Events

wezterm.on('augment-command-palette', function(window, pane)
    return {
        {
            -- Toggle background opacity
            brief = 'Window: Toggle background opacity',

            action = wezterm.action_callback(function(window, pane)
                local overrides = window:get_config_overrides() or {}
                if not overrides.window_background_opacity then
                    overrides.window_background_opacity = 0.8
                else
                    overrides.window_background_opacity = nil
                end
                window:set_config_overrides(overrides)
            end),
        },
        {
            -- Add 'Rename Tab' action to the command palette
            brief = 'Window: Rename tab',
            icon = 'md_rename_box',

            action = wezterm.action.PromptInputLine {
                description = 'Enter new name for tab',
                action = wezterm.action_callback(function(window, pane, line)
                    if line then
                        window:active_tab():set_title(line)
                    end
                end),
            },
        },
        {
            -- Toggle 'Cozette Vector' bitmap-like font yet can be scaled
            brief = 'Toggle Bitmap Font: Cozette Vector',
            icon = 'md_format_font',
            action = wezterm.action_callback(function(window, pane)
                local overrides = window:get_config_overrides() or {}
                if not overrides.font then
                    overrides.font = wezterm.font_with_fallback({ "CozetteVector", "Apple Color Emoji" })
                    overrides.font_size = 20.1 -- 18.1
                    overrides.font_rules = {
                        {
                            intensity = "Bold",
                            italic = false,
                            font = wezterm.font("CozetteVectorBold",
                                { weight = "Bold", stretch = "Normal", style = "Normal" }),
                        },
                        {
                            intensity = "Bold",
                            italic = true,
                            font = wezterm.font("CozetteVectorBold",
                                { weight = "Bold", stretch = "Normal", style = "Italic" }),
                        },
                    }
                else
                    overrides.font = nil
                    overrides.font_size = nil
                    overrides.font_rules = nil
                end
                window:set_config_overrides(overrides)
            end),
        },
        {
            -- Toggle 'Cozette HiDpi' bitmap font. Sharp but has a single size
            brief = 'Toggle Bitmap Font: Cozette HiDpi',
            icon = 'md_format_font',
            action = wezterm.action_callback(function(window, pane)
                local overrides = window:get_config_overrides() or {}
                if not overrides.font then
                    overrides.font = wezterm.font_with_fallback({ "CozetteHiDpi", "Apple Color Emoji" })
                    overrides.font_rules = {
                        {
                            intensity = "Bold",
                            italic = false,
                            font = wezterm.font("CozetteHiDpi", { weight = "Bold", stretch = "Normal", style = "Normal" }),
                        },
                        {
                            intensity = "Bold",
                            italic = true,
                            font = wezterm.font("CozetteHiDpi", { weight = "Bold", stretch = "Normal", style = "Italic" }),
                        },
                    }
                else
                    overrides.font = nil
                    overrides.font_size = nil
                    overrides.font_rules = nil
                end
                window:set_config_overrides(overrides)
            end),
        }

    }
end)

return config
