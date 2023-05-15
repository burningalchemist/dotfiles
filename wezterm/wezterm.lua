local wezterm = require 'wezterm';
return {
  font = wezterm.font_with_fallback({"JetBrains Mono", "Apple Color Emoji"}),
  font_size = 14.0,
  initial_cols = 100,
  initial_rows = 30,
  color_scheme = "Mirage",
  --color_scheme = "Catppuccin Mocha",
  scrollback_lines = 10000,
  tab_bar_at_bottom = true,
  use_cap_height_to_scale_fallback_fonts = true,
  adjust_window_size_when_changing_font_size = false,
  custom_block_glyphs = true,
  keys = {
    -- This will create a new split and run your default program inside it
    { key="Enter", mods="CTRL|SHIFT",
      action=wezterm.action{SplitVertical={domain="CurrentPaneDomain"}}
    },
    { key="%", mods="CTRL|SHIFT",
      action=wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}}
    },
    { key = "Z", mods="CTRL|SHIFT", action="TogglePaneZoomState" },
    { key="Q", mods="CTRL|SHIFT",
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
}
