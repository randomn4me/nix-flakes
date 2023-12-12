{ pkgs, inputs, outputs, lib, osConfig, ... }: {
  imports = [
    ./global

    ./features/accounts/private
    ./features/accounts/peasec

    ./features/desktop/hyprland
    ./features/multimedia
    ./features/backup
    ./features/rbw
    ./features/scripts

    ./features/productivity

    ./features/cli/udiskie.nix
  ] ++ (lib.optionals osConfig.services.xserver.windowManager.cwm.enable
    [ ./features/desktop/cwm ])
    ++ (lib.optionals osConfig.services.xserver.windowManager.i3.enable
      [ ./features/desktop/i3 ]);

  accounts.email.accounts.audacis.primary = true;
  accounts.calendar.accounts.peasec.primary = true;

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      warn-dirty = false;
    };
  };

  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [
    texlive.combined.scheme-full
    libreoffice

    darktable

    signal-desktop

    gnumake
    watchexec
    openconnect

    pandoc
    ffmpeg
  ];

  monitors = [{
    name = "eDP-1";
    width = 2540;
    height = 1440;
    x = 0;
    primary = true;
  }];

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;

  wallpaper = outputs.wallpapers.aenami-15steps;
  #wallpaper = outputs.wallpapers.aenami-far-from-tomorrow;
}
