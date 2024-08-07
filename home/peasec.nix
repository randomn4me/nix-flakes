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

    ./features/cli/udiskie.nix

    inputs.nix-index-database.hmModules.nix-index
  ];

  custom.nvim.enable = true;

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

    # home
    ddcutil
    comma
    obsidian
    darktable
    calibre
    tesseract
    ocrmypdf
    anki-bin
    makemkv
    mkvtoolnix
    yt-dlp
    devenv
    timewarrior
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

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;

  wallpaper = outputs.wallpapers.hollow-knight-abyss;
  #wallpaper = outputs.wallpapers.aenami-bright-planet;
  #wallpaper = outputs.wallpapers.aenami-15steps;
  #wallpaper = outputs.wallpapers.aenami-far-from-tomorrow;
  #wallpaper = outputs.wallpapers.aenami-cold;
}
