{ pkgs, inputs, ... }:

{
  imports = [
    inputs.hardware.nixosModules.lenovo-thinkpad-t490
    inputs.hardware.nixosModules.common-gpu-nvidia-disable

    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-pc-laptop-acpi_call

    ./hardware-configuration.nix

    ../common/global
    ../common/users/phil

    ../common/optional/fonts.nix
    ../common/optional/wireless.nix
    ../common/optional/bluetooth.nix
    ../common/optional/scanning.nix

    ../common/optional/docker.nix
    ../common/optional/virtualization.nix
    ../common/optional/ddcutils.nix
  ];

  networking.hostName = "peasec";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    kernelModules = [ "sg" ]; # for makemkv

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  custom.audio.enable = true;
  custom.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-kyodialog
      mfcj6510dwlpr
    ];
  };

  custom.powerManagement = {
    enable = true;
    ignoreUsbEnable = true;
    devices = [
      "SK622 Mechanical Keyboard - White Edition"
      "Optical Mouse"
    ];
  };

  services = {
    fwupd.enable = true;

    udisks2.enable = true;
    dbus.implementation = "broker";
    flatpak.enable = true;
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

  hardware.graphics.enable = true;

  system.stateVersion = "24.05";
}
