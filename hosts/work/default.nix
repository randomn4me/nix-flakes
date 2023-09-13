{ pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/phil

    ../common/optional/wireless.nix
    ../common/optional/powersaving.nix
    ../common/optional/pipewire.nix

    ../../modules/desktop/hyprland
  ];

  networking.hostName = "work";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    plymouth.enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    neovim

    wget
    curl

    brightnessctl
    xdg-utils

    fzf

    powertop

    isync
    neomutt
    msmtp
    vdirsyncer
    khard
    urlview
    pandoc
    w3m
    mdcat

    texlive.combined.scheme-full
    zotero
    poppler_utils

    jameica
  ];

  services.printing = {
    enable = true;
    drivers = [
      pkgs.cups-kyodialog
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

  services.thermald.enable = true;


  system.stateVersion = "23.05";

}

