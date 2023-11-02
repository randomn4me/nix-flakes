{ pkgs, inputs, outputs, ... }: {
  imports = [
    ./global

    ./features/accounts/private
    ./features/accounts/peasec

    ./features/desktop/hyprland
    ./features/multimedia
    ./features/backup
    ./features/rbw
    #./features/desktop/common/nextcloud.nix

    ./features/productivity

    ./features/cli/udiskie.nix
  ];
  #++ (lib.optionals config.services.xserver.windowManager.cwm.enable [
  #  ./features.desktop.cwm
  #]);

  nixpkgs.config.permittedInsecurePackages = [ "zotero-6.0.27" ];

  home.packages = with pkgs; [
    texlive.combined.scheme-full
    libreoffice
    zotero
    obsidian
    signal-desktop
    gnumake
    watchexec
    openconnect

    pandoc
    ffmpeg
  ];

  monitors = [{
    name = "eDP-1";
    width = 1920;
    height = 1080;
    x = 0;
    primary = true;
  }];

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;
  wallpaper = outputs.wallpapers.aenami-far-from-tomorrow;
}
