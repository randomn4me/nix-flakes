{
  imports = [
    ../common
    ../common/wayland-wm

    ./tty-init.nix
    #/basic-binds.nix
    #./windowrule.nix
    #./systemd-fixes.nix
  ];

  wayland.windowManager.sway = {
    enable = true;

    config = {
      modifier = "Mod4";
      seat = {
        "*" = {
          hide_cursor = "when-typing enable";
        };
      };
    };
  };
}
