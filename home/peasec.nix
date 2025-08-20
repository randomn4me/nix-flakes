{
  pkgs,
  inputs,
  outputs,
  config,
  ...
}:
{
  imports = [
    ./global

    ./features/ssh/private.nix
    ./features/ssh/peasec.nix

    ./features/accounts/private
    ./features/accounts/peasec

    ./features/productivity

    ./features/desktop/sway
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
    texlive.combined.scheme-full
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
    outputs.packages.x86_64-linux.python-icore

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
  services.kdeconnect.enable = true;

  monitors = [
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      refreshRate = 60;
      scaling = 1.0;
      primary = true;
    }
  ];

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;

  wallpaper = outputs.wallpapers.hollow-knight-abyss;
  #wallpaper = outputs.wallpapers.aenami-bright-planet;
  #wallpaper = outputs.wallpapers.aenami-15steps;
  #wallpaper = outputs.wallpapers.aenami-far-from-tomorrow;
  #wallpaper = outputs.wallpapers.aenami-cold;
}
