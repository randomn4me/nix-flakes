{ pkgs, inputs, outputs, ... }: {
  imports = [
    ./global

    ./features/accounts/private
    #../features/accounts/peasec

    #./features/desktop/hyprland
    ./features/desktop/cwm
    ./features/multimedia
    ./features/backup
    ./features/rbw
    #../features/desktop/common/nextcloud.nix

    ./features/productivity

    ./features/cli/udiskie.nix
  ];

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

    rustup
  ];

  monitors = [{
    name = "eDP-1";
    width = 2540;
    height = 1440;
    x = 0;
    primary = true;
  }];

  colorscheme = inputs.nix-colors.colorSchemes.tokyo-night-dark;
  wallpaper = outputs.wallpapers.aenami-far-from-tomorrow;
}
