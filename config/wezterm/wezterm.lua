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

local function is_blank(text)
  return text:match("^%s*$") ~= nil
end

local function same_zone(a, b)
  if not a or not b then
    return false
  end

  return a.semantic_type == b.semantic_type
    and a.start_x == b.start_x
    and a.start_y == b.start_y
    and a.end_x == b.end_x
    and a.end_y == b.end_y
end

local function get_cursor_zone(pane)
  local cursor = pane:get_cursor_position()
  local x = math.max(cursor.x - 1, 0)
  return pane:get_semantic_zone_at(x, cursor.y)
end

local function reverse_join(parts)
  local ordered = {}

  for i = #parts, 1, -1 do
    table.insert(ordered, parts[i])
  end

  return trim_trailing_newlines(table.concat(ordered))
end

local function get_last_completed_command(zones, pane)
  local cursor_zone = get_cursor_zone(pane)
  local output_parts = {}
  local state = "skip_trailing"

  for i = #zones, 1, -1 do
    local zone = zones[i]
    local zone_text = trim_trailing_newlines(pane:get_text_from_semantic_zone(zone))
    local zone_type = zone.semantic_type

    if not same_zone(zone, cursor_zone) then
      if state == "skip_trailing" then
        if zone_type == "Output" then
          state = "collect_output"
          table.insert(output_parts, pane:get_text_from_semantic_zone(zone))
        elseif zone_type == "Input" then
          if not is_blank(zone_text) then
            return zone_text, nil
          end
        end
      elseif state == "collect_output" then
        if zone_type == "Output" then
          table.insert(output_parts, pane:get_text_from_semantic_zone(zone))
        elseif zone_type == "Input" then
          return zone_text, reverse_join(output_parts)
        elseif zone_type ~= "Prompt" then
          break
        end
      end
    end
  end

  return nil, nil
end

local function copy_last_command_with_output(window, pane)
  if pane:is_alt_screen_active() then
    flash_status(window, "copy unavailable in alt screen")
    return
  end

  local zones = pane:get_semantic_zones()
  local input_text, output_text = get_last_completed_command(zones, pane)

  if not input_text then
    flash_status(window, "semantic zones unavailable")
    return
  end

  local payload = input_text
  if output_text and output_text ~= "" then
    payload = input_text .. "\n" .. output_text
  end

  window:copy_to_clipboard(payload)
  flash_status(window, "copied last command + output")
end

-- font settings
config.font = wezterm.font("Cica")
config.font_size = 15

-- theme
config.color_scheme = "Kanagawa (Gogh)"

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

-- ToggleFullScreen の挙動を macOS のネイティブなフルスクリーンにする
config.native_macos_fullscreen_mode = true

-- keybinds
config.leader = { key = ".", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
  -- フルスクリーン切り替え, same as macOS native fullscreen toggle.
  { key = "f", mods = "CMD|CTRL", action = act.ToggleFullScreen },

  -- ペイン分割
  { key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "s", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  -- ペイン移動
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  -- ペイン閉じる
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

-- Finally, return the configuration to wezterm:
return config
