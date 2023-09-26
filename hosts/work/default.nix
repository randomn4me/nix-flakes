{ inputs, outputs, config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../common/global
    ../common/users/phil

    ../common/optional/wireless.nix
    ../common/optional/bluetooth.nix
    ../common/optional/powersaving.nix
    ../common/optional/pipewire.nix
  ];

  networking.hostName = "work";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  services.printing = {
    enable = true;
    drivers = [
      pkgs.cups-kyodialog
    ];
  };

  programs.dconf.enable = true;

  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

  system.stateVersion = "23.05";
}
