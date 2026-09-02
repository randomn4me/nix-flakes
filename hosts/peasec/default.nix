{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.hardware.nixosModules.lenovo-thinkpad-t490
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix

    ../common/global
    ../common/users/phil

    ../common/optional/fonts.nix
    ../common/optional/bluetooth.nix
    ../common/optional/scanning.nix

    ../common/optional/ddcutils.nix
    ../common/optional/sops.nix
    ../common/optional/greetd.nix
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
  # An ignored lid means the machine stays fully awake in a bag. On battery it
  # now suspends and, after HibernateDelaySec below, hands over to disk.
  # Plugged in or docked it still only locks, so it stays reachable over ssh.
  services.logind.lidSwitch = "suspend-then-hibernate";
  services.logind.lidSwitchExternalPower = "lock";
  services.logind.lidSwitchDocked = "lock";

  programs = {
    dconf.enable = true;
    # System-level Hyprland: pulls in xdg-desktop-portal-hyprland and the
    # polkit/session wiring that the home-manager module alone doesn't provide.
    # It also registers hyprland.desktop, which is what greetd's session menu
    # (../common/optional/greetd.nix) lists.
    hyprland.enable = true;
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = "*";
  };

  hardware.graphics.enable = true;

  # --- power -------------------------------------------------------------
  # Whiskey Lake i7-8565U, a 15W part. nixos-hardware turns tlp on by mkDefault
  # but ships no settings; this pulls in the tuned config from
  # modules/nixos/powerManagement (charge thresholds, DYTC platform profile,
  # PCIe ASPM, runtime PM).
  custom.powerManagement = {
    enable = true;
    # Clamps turbo and caps p-states at 60% while discharging. This is the
    # knob to flip first if the machine feels slow unplugged.
    tlp.aggressiveOnBattery = true;
  };

  # nixos-hardware's t490 module enables throttled, whose stock config permits
  # PL1=29W/PL2=44W on battery -- roughly double the part's rated TDP, so a
  # single build can pull 30W+ out of the pack. AC keeps the headroom.
  services.throttled.extraConfig = ''
    [GENERAL]
    Enabled: True
    Sysfs_Power_Path: /sys/class/power_supply/AC*/online
    Autoreload: True

    [BATTERY]
    Update_Rate_s: 30
    PL1_Tdp_W: 12
    PL1_Duration_s: 28
    PL2_Tdp_W: 20
    PL2_Duration_S: 0.002
    Trip_Temp_C: 80
    cTDP: 0
    Disable_BDPROCHOT: False

    [AC]
    Update_Rate_s: 5
    PL1_Tdp_W: 25
    PL1_Duration_s: 28
    PL2_Tdp_W: 44
    PL2_Duration_S: 0.002
    Trip_Temp_C: 95
    cTDP: 0
    Disable_BDPROCHOT: False

    [UNDERVOLT.BATTERY]
    CORE: 0
    GPU: 0
    CACHE: 0
    UNCORE: 0
    ANALOGIO: 0

    [UNDERVOLT.AC]
    CORE: 0
    GPU: 0
    CACHE: 0
    UNCORE: 0
    ANALOGIO: 0
  '';

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
