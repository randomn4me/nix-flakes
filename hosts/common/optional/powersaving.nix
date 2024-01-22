{ pkgs, ... }: {
  imports = [
    ./powersaving-ignore-usb.nix
    ./tlp.nix
  ];

  environment.systemPackages = with pkgs; [ powertop ];

  powerManagement.enable = true;
  powerManagement.powertop.enable = true;

  services.thermald.enable = true;
}
