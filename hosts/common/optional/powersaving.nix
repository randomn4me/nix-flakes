{ pkgs, ... }: {
  powerManagement.enable = true;

  powerManagement.powertop.enable = true;
  environment.systemPackages = with pkgs; [ powertop ];

  services.thermald.enable = true;
}
