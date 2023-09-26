{ pkgs, ... }:

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

  services = {
    printing = {
      enable = true;
      drivers = [
        pkgs.cups-kyodialog
      ];
    };

    avahi = {
      enable = true;
      nssmdns = true;
      openFirewall = true;
    };

    udisks2.enable = true; # required by udiskie
  };

  programs = {
    dconf.enable = true;
    light.enable = true;
    adb.enable = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  system.stateVersion = "23.05";
}


