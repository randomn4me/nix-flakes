{
  pkgs,
  inputs,
  outputs,
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
    ./features/multimedia
    ./features/backup
    ./features/rbw
    ./features/scripts

    ./features/desktop/common/zotero.nix

    ./features/cli/udiskie.nix

    inputs.nix-index-database.hmModules.nix-index
  ];

  editor.nvim.enable = true;

  accounts.email.accounts.peasec.primary = true;
  accounts.calendar.accounts.peasec.primary = true;

  systemd.user.startServices = "sd-switch";

  home.packages = with pkgs; [
    # work
    texlive.combined.scheme-full
    hunspellDicts.de_DE
    hunspellDicts.en_US

    comma
    ddcutil

    xournalpp

    rclone
    obsidian

    gnumake
    watchexec
    openconnect

    pandoc
    ffmpeg

    nextcloud-client

    # home
    darktable
    calibre
    tesseract
    anki-bin
    makemkv
    mkvtoolnix
    yt-dlp
  ];

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

  #wallpaper = outputs.wallpapers.hollow-knight-abyss;
  #wallpaper = outputs.wallpapers.aenami-bright-planet;
  #wallpaper = outputs.wallpapers.aenami-15steps;
  wallpaper = outputs.wallpapers.aenami-far-from-tomorrow;
  #wallpaper = outputs.wallpapers.aenami-cold;
}
