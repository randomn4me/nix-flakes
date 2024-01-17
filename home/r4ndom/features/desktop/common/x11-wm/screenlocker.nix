{ pkgs, config, ... }: {
  services.screen-locker = {
    enable = true;
    lockCmd = "${pkgs.i3lock-color}/bin/i3lock-color -i ${config.wallpaper}";

    xautolock = {
      enable = true;
      extraOptions = [
        "-corners '000-"
        "-time 5"
        "-notify 30"
        "-notifier ${pkgs.libnotify}/bin/notify-send 'locker sleeping soon'"
      ];
    };
  };
}
