{ ... }:
{
  services.yabai = {
    enable = true;
    enableScriptingAddition = true;
    config = {
      mouse_follows_focus = "off";
      focus_follows_mouse = "off";
      window_origin_display = "default";
      window_placement = "second_child";
      window_topmost = "off";
      window_shadow = "on";
      window_opacity = "off";
      window_opacity_duration = 0.0;
      active_window_opacity = 1.0;
      normal_window_opacity = 0.9;
      split_ratio = 0.5;
      auto_balance = "off";
      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      mouse_drop_action = "swap";

      layout = "bsp";
      top_padding = 12;
      bottom_padding = 12;
      left_padding = 12;
      right_padding = 12;
      window_gap = 12;
      external_bar = "all:30:0";

      window_border = "on";
      window_border_width = 3;
      active_window_border_color = "0xFF21C7e8";
      normal_window_border_color = "0x002E3440";
      insert_feedback_color = "0xffd75f5f"; # where?
    };
    extraConfig = ''
      # Apps that disable titling layout
      yabai -m rule --add app="^Karabiner-Elements$" manage=off
      yabai -m rule --add app="^Karabiner-EventViewer$" manage=off
      yabai -m rule --add app="^System Preferences$" manage=off
      yabai -m rule --add app="^System Information$" manage=off
      yabai -m rule --add app="^Finder" manage=off
      # yabai -m rule --add app="^UTM" manage=off
      yabai -m rule --add title="^システム環境設定$" manage=off # why I cannot use "system Preferences"???
      yabai -m rule --add title="Bluetooth" manage=off # why I cannot use "system Preferences"???
    '';
  };
}
