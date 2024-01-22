{ pkgs, ... }: {
  powerManagement.enable = true;

  powerManagement.powertop.enable = true;
  environment.systemPackages = with pkgs; [ powertop ];

  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
       governor = "powersave";
       turbo = "auto";
    };
    charger = {
       governor = "performance";
       turbo = "auto";
    };
  };

  services.thermald.enable = true;
}
