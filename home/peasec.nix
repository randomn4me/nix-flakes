{
  pkgs,
  inputs,
  outputs,
  ...
}:
{
  imports = [
    ./global

    #./features/nvim
    ./features/nixvim

    ./features/ssh/private.nix
    ./features/ssh/peasec.nix

    ./features/accounts/private
    ./features/accounts/peasec

    ./features/productivity

    ./features/desktop/hyprland
    #./features/desktop/sway
    #./features/desktop/i3
    ./features/multimedia
    ./features/backup
    ./features/rbw
    ./features/scripts

    ./features/desktop/common/zotero.nix

    ./features/cli/udiskie.nix
    #./features/virtualization/virt-manager.nix

    inputs.nix-index-database.hmModules.nix-index
  ];

  accounts.email.accounts.peasec.primary = true;
  accounts.calendar.accounts.peasec.primary = true;

  systemd.user.startServices = "sd-switch";

  services.gnome-keyring.enable = true;

  home.packages = with pkgs; [
    texlive.combined.scheme-full
    hunspellDicts.de_DE
    hunspellDicts.en_US

    comma
    ddcutil

    darktable
    calibre
    xournalpp

    makemkv
    mkvtoolnix

    signal-desktop

    gnumake
    watchexec
    openconnect

    pandoc
    ffmpeg
    anki-bin

    tesseract
    nextcloud-client
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
