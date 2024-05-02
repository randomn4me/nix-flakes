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

    ../common/optional/fonts.nix
    ../common/optional/wireless.nix
    ../common/optional/bluetooth.nix
    ../common/optional/pipewire.nix
    ../common/optional/scanning.nix

    ../common/optional/powersaving.nix

    ../common/optional/docker.nix
    # ../common/optional/virtualbox.nix
    # ../common/optional/virt-manager.nix
  ];

  networking.hostName = "peasec";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    kernelModules = [
      "sg"
      "i2c-dev"
    ]; # for makemkv and monitor control

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  services = {
    flatpak.enable = true;

    printing = {
      enable = true;
      drivers = with pkgs; [
        cups-kyodialog
        mfcj6510dwlpr
      ];
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    udisks2.enable = true;
    dbus.implementation = "broker";
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
  };

  system.stateVersion = "23.11";
}
