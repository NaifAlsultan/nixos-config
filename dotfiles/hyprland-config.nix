''
  local mainMod = "SUPER"

  hl.monitor({
      output = "",
      mode = "preferred",
      position = "auto",
      scale = 1,
  })

  hl.env("XCURSOR_THEME", "Adwaita")
  hl.env("XCURSOR_SIZE", "24")
  hl.on("hyprland.start", function()
      hl.exec_cmd("hyprctl setcursor Adwaita 24")
  end)

  hl.config({
      general = {
          gaps_in = 0,
          gaps_out = 0,
          border_size = 1,
          col = {
              active_border = "rgb(60b8d6)",
              inactive_border = "rgb(323844)",
          },
          layout = "dwindle",
          resize_on_border = true,
      },
      decoration = {
          rounding = 0,
          shadow = { enabled = false },
          blur = { enabled = false },
      },
      animations = {
          enabled = false,
      },
      input = {
          kb_layout = "us,ara",
          kb_options = "grp:caps_toggle",
          follow_mouse = 1,
          touchpad = {
              natural_scroll = false,
          },
      },
      dwindle = {
          preserve_split = true,
      },
      misc = {
          disable_hyprland_logo = true,
          force_default_wallpaper = 0,
      },
  })

  hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd("ghostty"))
  hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("librewolf"))
  hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("obsidian"))
  hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("fuzzel"))
  hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.close())
  hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
  hl.bind(mainMod .. " + SHIFT + SPACE", hl.dsp.window.float())
  hl.bind(mainMod .. " + SPACE", hl.dsp.window.cycle_next())

  hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
  hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
  hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
  hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
  hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
  hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
  hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
  hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))

  hl.bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left", group_aware = true }))
  hl.bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down", group_aware = true }))
  hl.bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up", group_aware = true }))
  hl.bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right", group_aware = true }))
  hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.move({ direction = "left", group_aware = true }))
  hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "down", group_aware = true }))
  hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "up", group_aware = true }))
  hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right", group_aware = true }))

  hl.bind(mainMod .. " + C", hl.dsp.layout("preselect r"))
  hl.bind(mainMod .. " + V", hl.dsp.layout("preselect d"))
  hl.bind(mainMod .. " + E", hl.dsp.layout("togglesplit"))
  hl.bind(mainMod .. " + W", hl.dsp.group.toggle())
  hl.bind(mainMod .. " + S", hl.dsp.group.next())
  hl.bind(mainMod .. " + A", hl.dsp.group.prev())

  for i = 1, 10 do
      local key = i % 10
      hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
      hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
  end

  hl.bind(mainMod .. " + minus", hl.dsp.workspace.toggle_special("scratchpad"))
  hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "special:scratchpad" }))

  hl.bind(mainMod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprctl reload"))
  hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))
  hl.bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("hyprlock"))

  local logoutCommand = [[
    printf 'No\nYes\n' | fuzzel --dmenu --prompt='Exit Hyprland? ' | grep -qx Yes &&
      (command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()')
  ]]
  hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(logoutCommand))

  hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%+"), { locked = true, repeating = true })
  hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%-"), { locked = true, repeating = true })
  hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SINK@ toggle"), { locked = true })
  hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
  hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

  hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
  hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

  hl.define_submap("resize", function()
      hl.bind("H", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
      hl.bind("J", hl.dsp.window.resize({ x = 0, y = 10, relative = true }), { repeating = true })
      hl.bind("K", hl.dsp.window.resize({ x = 0, y = -10, relative = true }), { repeating = true })
      hl.bind("L", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
      hl.bind("escape", hl.dsp.submap("reset"))
      hl.bind("return", hl.dsp.submap("reset"))
  end)
  hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))

  hl.window_rule({
      name = "fix-xwayland-drags",
      match = {
          class = "^$",
          title = "^$",
          xwayland = true,
          float = true,
          fullscreen = false,
          pin = false,
      },
      no_focus = true,
  })
''
