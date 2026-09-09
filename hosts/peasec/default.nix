{
  pkgs,
  inputs,
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
    ../common/optional/eduroam.nix
  ];

  networking.hostName = "peasec";
  networking.networkmanager.enable = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    kernelModules = [ "sg" ]; # for makemkv

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Hibernation onto the btrfs swapfile from ./hardware-configuration.nix.
    # resume_offset is the file's first physical block, from
    #   btrfs inspect-internal map-swapfile -r /swap/swapfile
    # and has to be regenerated if that file is ever recreated or moved.
    resumeDevice = "/dev/mapper/cryptroot";
    kernelParams = [ "resume_offset=533760" ];
  };

  services.custom.audio.enable = true;
  services.custom.printing = {
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

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "lock";
  };

  programs = {
    dconf.enable = true;
    hyprland.enable = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
  };

  hardware.graphics.enable = true;

  services.custom.greetd.enable = true;

  custom.powerManagement = {
    enable = true;
    tlp.aggressiveOnBattery = false;
  };

  systemd.sleep.settings.Sleep.HibernateDelaySec = "45min";

  systemd.services = {
    nix-gc.unitConfig.ConditionACPower = true;
    nix-optimise.unitConfig.ConditionACPower = true;
    fstrim.unitConfig.ConditionACPower = true;
    fwupd-refresh.unitConfig.ConditionACPower = true;
  };

  services.udev.extraRules = ''
    # Fibocom L830-EB WWAN modem
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2cb7", ATTR{idProduct}=="0210", ATTR{authorized}="0"
    # Alcor EMV smartcard reader (nothing here runs pcscd)
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="058f", ATTR{idProduct}=="9540", ATTR{authorized}="0"
  '';

  sops.defaultSopsFile = ./secrets.yaml;

  # Borg repository passphrase, read by the user-level borgmatic service
  # (home/features/backup/borgmatic.nix) via /run/secrets.
  sops.secrets."borg/peasec-passphrase".owner = "phil";

  system.stateVersion = "24.05";

}
