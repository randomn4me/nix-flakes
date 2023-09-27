{ pkgs, inputs, ... }:

{

  imports = [
    inputs.hardware.nixosModules.lenovo-thinkpad-t490

    inputs.hardware.nixosModules.common-cpu-intel

    inputs.hardware.nixosModules.common-gpu-intel
    inputs.hardware.nixosModules.common-gpu-nvidia-disable

    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-pc-laptop-acpi_call

    ./hardware-configuration.nix

    ../common/global
    ../common/users/phil

    ../common/optional/wireless.nix
    ../common/optional/bluetooth.nix
    ../common/optional/powersaving.nix
    ../common/optional/pipewire.nix

    ../common/optional/docker.nix
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

    clamav = {
      daemon.enable = true;
      updater.enable = true;
    };
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

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;

    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  system.stateVersion = "23.05";
}


