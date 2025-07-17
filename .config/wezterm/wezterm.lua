-- WezTerm configuration based on VS Code settings
local wezterm = require 'wezterm'
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Font Configuration (from VS Code)
-- config.font = wezterm.font('Fira Code', { weight = 400 })
config.font_size = 14.0

-- Enable font ligatures (Fira Code has ligatures)
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }

-- Color Scheme - Aura Dracula Spirit inspired
-- Based on your VS Code color customizations
config.colors = {
  -- Foreground and background
  foreground = '#f8f8f2',
  background = '#140E1A', -- From sideBar.background

  -- Cursor colors (based on your pink/purple cursor)
  cursor_bg = '#DA70D6',
  cursor_fg = '#140E1A',
  cursor_border = '#DA70D6',

  -- Selection colors (based on your list selection colors)
  selection_fg = '#f8f8f2',
  selection_bg = '#231739',

  -- ANSI colors (Dracula-inspired palette)
  ansi = {
    '#21222C', -- black
    '#FF5555', -- red
    '#50FA7B', -- green
    '#F1FA8C', -- yellow
    '#BD93F9', -- blue
    '#FF79C6', -- magenta
    '#8BE9FD', -- cyan
    '#F8F8F2', -- white
  },

  -- Bright ANSI colors
  brights = {
    '#6272A4', -- bright black
    '#FF6E6E', -- bright red
    '#69FF94', -- bright green
    '#FFFFA5', -- bright yellow
    '#D6ACFF', -- bright blue
    '#FF92DF', -- bright magenta
    '#A4FFFF', -- bright cyan
    '#FFFFFF', -- bright white
  },

  -- Tab bar colors
  tab_bar = {
    background = '#140E1A',
    active_tab = {
      bg_color = '#231739',
      fg_color = '#f8f8f2',
    },
    inactive_tab = {
      bg_color = '#140E1A',
      fg_color = '#6272a4',
    },
    inactive_tab_hover = {
      bg_color = '#231739',
      fg_color = '#f8f8f2',
      italic = false,
    },
    new_tab = {
      bg_color = '#140E1A',
      fg_color = '#6272a4',
    },
    new_tab_hover = {
      bg_color = '#231739',
      fg_color = '#f8f8f2',
      italic = false,
    },
  },
}

-- Window Configuration
config.window_background_opacity = 1.0
config.window_decorations = "RESIZE" -- Similar to native title bar
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}

-- Tab Bar Configuration (minimal, like VS Code single tab mode)
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false

-- Cursor Configuration (block cursor like VS Code)
config.default_cursor_style = 'SteadyBlock'
config.cursor_blink_rate = 0 -- Solid cursor, no blinking

-- Scrollback
config.scrollback_lines = 10000

-- Visual Bell (disable audio bell)
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = 'CursorColor',
}
config.audible_bell = 'Disabled'

-- Performance
config.enable_wayland = false -- Set to true if on Wayland
config.front_end = "WebGpu" -- Or "OpenGL" if WebGpu causes issues

-- Key bindings (optional - add your preferred shortcuts)
config.keys = {
  -- Split panes
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  -- Navigate panes
  {
    key = 'LeftArrow',
    mods = 'CMD|ALT',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'RightArrow',
    mods = 'CMD|ALT',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'UpArrow',
    mods = 'CMD|ALT',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'DownArrow',
    mods = 'CMD|ALT',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },


-- Zoom with + and -
  {
  key = '+',
  mods = 'CMD',
  action = wezterm.action.IncreaseFontSize,
  },
  {
  key = '-',
  mods = 'CMD',
  action = wezterm.action.DecreaseFontSize,
  },
  {
  key = '0',
  mods = 'CMD',
  action = wezterm.action.ResetFontSize,
  },

  -- Shift Highlight
  -- { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = 'DisableDefaultAssignment' },
  -- { key = 'RightArrow', mods = 'CTRL|SHIFT', action = 'DisableDefaultAssignment' },

}

-- macOS specific settings
if wezterm.target_triple == 'x86_64-apple-darwin' or wezterm.target_triple == 'aarch64-apple-darwin' then
  config.native_macos_fullscreen_mode = true
  config.window_close_confirmation = 'NeverPrompt'
end

return config
