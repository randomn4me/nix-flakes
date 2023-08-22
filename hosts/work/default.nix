{ pkgs, lib, user, ... }:

{
  imports = 
    [(import ./hardware-configuration.nix)] ++
    [(import ../../modules/desktop/hyprland/default.nix)];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    plymouth.enable = true;
  };

  networking.hostName = "work"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  environment.systemPackages = with pkgs; [
    git
    neovim
    wget
    curl
    texlive.combined.scheme-full
    brightnessctl
    xdg-utils
  ];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  system.stateVersion = "23.05"; # Did you read the comment?

}

