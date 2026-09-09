{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
let
  wallpapers = import ./wallpapers;
in
{
  imports = [
    ./global

    ./features/ssh/private.nix
    ./features/ssh/peasec.nix

    ./features/accounts/private
    ./features/accounts/peasec

    ./features/productivity

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
      # Number keys 1-8 stay on the laptop panel; 9 belongs to the office
      # display below, so it is reachable by key press instead of only by
      # pushing a workspace over (SUPER + SHIFT + Tab).
      workspaces = lib.range 1 8;
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
      # The last number key, and this monitor's default. Only 9 lands here,
      # so connecting the display never pulls 1-8 off the laptop panel.
      workspaces = [ 9 ];
    }
  ];

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;

  wallpaper = wallpapers.hollow-knight-abyss;
  #wallpaper = wallpapers.aenami-bright-planet;
  #wallpaper = wallpapers.aenami-15steps;
  #wallpaper = wallpapers.aenami-far-from-tomorrow;
  #wallpaper = wallpapers.aenami-cold;
}
