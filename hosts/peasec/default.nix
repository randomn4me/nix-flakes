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
  # The lid belongs to Hyprland (the switch binds in home/features/desktop/
  # hyprland), so logind keeps its hands off it on battery. That drops the
  # immediate suspend-then-hibernate on close: the backstop is hypridle, which
  # suspends after 15min idle -- a shut lid reaches that on its own, so the
  # machine no longer stays awake in a bag indefinitely, just for a while.
  # Docked or on mains it still only locks, so it stays reachable over ssh.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "lock";
  };

  programs = {
    dconf.enable = true;
    # System-level Hyprland: pulls in xdg-desktop-portal-hyprland and the
    # polkit/session wiring that the home-manager module alone doesn't provide.
    # It also registers hyprland.desktop, which is what greetd's session menu
    # lists.
    hyprland.enable = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
  };

  hardware.graphics.enable = true;

  custom.greetd.enable = true;

  # --- power -------------------------------------------------------------
  # Whiskey Lake i7-8565U, a 15W part -- which is what the throttled defaults
  # in modules/nixos/powerManagement are tuned for, so the package limits need
  # no override here. nixos-hardware turns tlp and throttled on by mkDefault
  # but ships settings for neither; the module supplies both (charge
  # thresholds, DYTC platform profile, PCIe ASPM, runtime PM, RAPL limits).
  custom.powerManagement = {
    enable = true;
    tlp.aggressiveOnBattery = false;
  };

  # S3 alone still drains the pack over a long idle, so hand over to disk.
  systemd.sleep.settings.Sleep.HibernateDelaySec = "45min";

  # Housekeeping that has no business spinning the disk or the CPU while
  # discharging. borgmatic already carries ConditionACPower from home-manager.
  systemd.services = {
    nix-gc.unitConfig.ConditionACPower = true;
    nix-optimise.unitConfig.ConditionACPower = true;
    fstrim.unitConfig.ConditionACPower = true;
    fwupd-refresh.unitConfig.ConditionACPower = true;
  };

  # Built-in radios/readers that are enumerated and powered but never used.
  # Deauthorizing lets the USB port suspend; reversible at runtime with
  # `echo 1 > /sys/bus/usb/devices/<dev>/authorized`, or permanently in BIOS.
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
