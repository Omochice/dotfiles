{ pkgs, ... }:
{
  services.paneru = {
    # NOTE:
    # we want to need
    # - [ ] padding
    # - [ ] keep width between fullscreen https://github.com/karinushka/paneru/issues/51
    # - [ ] move window to next monitor
    # - [ ] focus other monitor
    enable = false;
    # enable = pkgs.stdenv.isDarwin;
    settings = {
      options = {
        preset_column_widths = [
          0.25
          0.5
          0.75
          1.00
        ];
        animation_speed = 7500;
      };
      bindings = {
        window_focus_west = "cmd - h";
        window_focus_east = "cmd - l";
        window_focus_north = "cmd - k";
        window_focus_south = "cmd - j";
        window_swap_west = "cmd + shift - h";
        window_swap_east = "cmd + shift - l";
        window_swap_north = "cmd + shift - k";
        window_swap_south = "cmd + shift - j";
        window_center = "cmd + shift - c";
        window_resize = "cmd + shift - r";
        window_fullwidth = "cmd - f";
        window_manage = "cmd - space";
      };
    };
  };
}
