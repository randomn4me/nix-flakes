{ pkgs, inputs, ... }:

{
  imports = [
    inputs.hardware.nixosModules.lenovo-thinkpad-t490

    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-intel

    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-pc-laptop-acpi_call

    ./hardware-configuration.nix

    ../common/global
    ../common/users/bine

    ../common/optional/wireless.nix
    ../common/optional/bluetooth.nix
    ../common/optional/pipewire.nix
    ../common/optional/scanning.nix

    ../common/optional/powersaving.nix
    ../common/optional/tlp.nix
  ];

  networking.hostName = "hummel";

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  services = {
    flatpak.enable = true;

    printing = {
      enable = true;
      drivers = with pkgs; [ cups-kyodialog brgenml1lpr brgenml1cupswrapper ];
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    udisks2.enable = true; # required by udiskie

    clamav = {
      daemon.enable = true;
      updater.enable = true;
    };

    pantheon = {
      apps.enable = true;
      contractor.enable = true;
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
    config.common.default = "*";
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;

    extraPackages = with pkgs; [ intel-media-driver ];
  };

  system.stateVersion = "23.11";
}
