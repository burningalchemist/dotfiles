local wezterm = require 'wezterm';
return {
  font = wezterm.font_with_fallback({"JetBrains Mono", "Apple Color Emoji"}),
  font_size = 14.0,
  initial_cols = 100,
  initial_rows = 30,
  color_scheme = "Mirage",
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
    { key="Q", mods="SHIFT|CTRL", action="QuickSelect"},
  }
}
