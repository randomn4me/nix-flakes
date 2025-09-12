{
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    inputs.hardware.nixosModules.lenovo-thinkpad-t490
    inputs.hardware.nixosModules.common-gpu-nvidia-disable

    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix

    ../common/global
    ../common/users/phil

    ../common/optional/fonts.nix
    ../common/optional/bluetooth.nix
    ../common/optional/scanning.nix

    ../common/optional/ddcutils.nix
    ../common/optional/sops.nix
  ];

  networking.hostName = "peasec";
  networking.networkmanager.enable = true;

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
      mfcj6510dwlpr
    ];
  };

  services.fwupd.enable = true;
  services.udisks2.enable = true;
  services.dbus.implementation = "broker";
  services.flatpak.enable = true;

  # setup as server
  services.openssh.enable = true;
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchExternalPower = "lock";
  services.logind.lidSwitchDocked = "lock";

  programs = {
    dconf.enable = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
  };

  hardware.graphics.enable = true;
  sops.defaultSopsFile = lib.mkForce ./secrets.yaml;

  system.stateVersion = "24.05";

}
