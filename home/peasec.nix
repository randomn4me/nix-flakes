{
  pkgs,
  lib,
  inputs,
  outputs,
  config,
  ...
}:
{
  imports = [
    ./global

    ./features/cli/bash.nix

    ./features/ssh/private.nix
    ./features/ssh/peasec.nix

    ./features/accounts/private
    ./features/accounts/peasec

    ./features/productivity

    ./features/desktop/sway
    ./features/desktop/hyprland
    ./features/backup
    ./features/scripts

    inputs.nix-index-database.homeModules.nix-index
  ];

  custom.nvim = {
    enable = true;
    lsp = true;
    completion = true;
    allPlugins = true;
  };

  custom.mpd-music = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/usr/music";
  };
  custom.rbw.enable = true;

  accounts.email.accounts.peasec.primary = true;
  accounts.calendar.accounts.peasec.primary = true;

  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [
    # work
    texliveSmall
    hunspellDicts.de_DE
    hunspellDicts.en_US

    xournalpp
    rclone
    gnumake
    watchexec
    openconnect
    glab
    pandoc
    ffmpeg
    zotero
    zoom-us

    # home
    ddcutil
    comma
    obsidian
    darktable
    gimp
    tesseract
    yt-dlp
    devenv
    signal-desktop
    element-desktop
    jameica
    calibre
    udiskie
    # makemkv
    # mkvtoolnix
    # timewarrior
  ];

  services.udiskie.enable = true;
  services.syncthing.enable = true;

  monitors = [
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      scaling = 1.0;
      primary = true;
      # All nine number keys stay on the laptop panel; the office display
      # gets whatever workspace is pushed to it (SUPER + SHIFT + Tab) rather
      # than claiming one on its own the moment it is plugged in.
      workspaces = lib.range 1 9;
    }
    {
      # Office display. Only takes effect while it is actually connected, so
      # the rule is harmless on the road.
      name = "DP-2";
      width = 2560;
      height = 1440;
      refreshRate = 60;
      scaling = 1.0;
      x = 1920;
      # Its own workspace, well clear of the number keys, so connecting it
      # never pulls one of those nine off the laptop panel.
      workspaces = [ 10 ];
    }
  ];

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;

  wallpaper = outputs.wallpapers.hollow-knight-abyss;
  #wallpaper = outputs.wallpapers.aenami-bright-planet;
  #wallpaper = outputs.wallpapers.aenami-15steps;
  #wallpaper = outputs.wallpapers.aenami-far-from-tomorrow;
  #wallpaper = outputs.wallpapers.aenami-cold;
}
