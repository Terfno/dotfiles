local wezterm = require("wezterm")
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

local function flash_status(window, message)
  window:set_right_status(message)
  wezterm.time.call_after(1, function()
    window:set_right_status("")
  end)
end

local function trim_trailing_newlines(text)
  return (text:gsub("[\r\n]+$", ""))
end

local function copy_last_command_with_output(window, pane)
  if pane:is_alt_screen_active() then
    flash_status(window, "copy unavailable in alt screen")
    return
  end

  local zones = pane:get_semantic_zones()
  local input_zone_index = nil

  for i = #zones, 1, -1 do
    if zones[i].semantic_type == "Input" then
      input_zone_index = i
      break
    end
  end

  if not input_zone_index then
    flash_status(window, "semantic zones unavailable")
    return
  end

  local input_text = trim_trailing_newlines(pane:get_text_from_semantic_zone(zones[input_zone_index]))

  local output_parts = {}
  for i = input_zone_index + 1, #zones do
    local zone = zones[i]

    if zone.semantic_type == "Prompt" then
      break
    end

    if zone.semantic_type == "Output" then
      table.insert(output_parts, pane:get_text_from_semantic_zone(zone))
    end
  end

  local payload = input_text
  if #output_parts > 0 then
    payload = input_text .. "\n" .. trim_trailing_newlines(table.concat(output_parts))
  end

  window:copy_to_clipboard(payload)
  flash_status(window, "copied last command + output")
end

-- font settings
config.font = wezterm.font("Cica")
config.font_size = 15

-- theme
config.color_scheme = "Kanagawa (Gogh)"

-- keybinds
config.leader = { key = ".", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
  -- ペイン移動
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

  -- 分割
  { key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "s", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- 閉じる
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
  -- 直前のコマンドと出力をコピー
  {
    key = "c",
    mods = "LEADER",
    action = wezterm.action_callback(function(window, pane)
      copy_last_command_with_output(window, pane)
    end),
  },
}

-- pane border (color_scheme から自動取得)
local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]
local split_color = scheme.cursor_bg
config.inactive_pane_hsb = {
  saturation = 0.5,
  brightness = 0.4,
}
config.colors = {
  split = split_color,
}

-- Finally, return the configuration to wezterm:
return config
