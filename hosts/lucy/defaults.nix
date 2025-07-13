{ pkgs, inputs, ... }:

{
  imports = [
    inputs.hardware.nixosModules.lenovo-thinkpad-t490
    inputs.hardware.nixosModules.common-pc-ssd

    inputs.disko.nixosModules.disko

    ../common/global
    ../common/users/milla

    ../common/global/disko/desktop.nix

    ../common/optional/fonts.nix
    ../common/optional/wireless.nix
    ../common/optional/bluetooth.nix
    ../common/optional/scanning.nix

    ../common/optional/ddcutils.nix
  ];

  networking.hostName = "lucy";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  custom.audio.enable = true;
  custom.printing = {
    enable = true;
    drivers = with pkgs; [
      mfcj6510dwlpr
    ];
  };

  custom.powerManagement = {
    enable = true;
    ignoreUsbEnable = true;
  };

  services.fwupd.enable = true;
  services.udisks2.enable = true;
  services.dbus.implementation = "broker";

  services = {
    desktopManager.plasma6.enable = true;
    displayManager.sddm.enable = true;
    displayManager.sddm.wayland.enable = true;
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

  system.stateVersion = "25.05";
}
