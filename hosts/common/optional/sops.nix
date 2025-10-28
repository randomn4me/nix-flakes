{ inputs, config, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  # Default configuration for sops
  sops = {
    # This will automatically import secrets from secrets.yaml
    defaultSopsFile = ../../secrets.yaml;

    # This is using an age key that is expected to be already present on the system
    age.keyFile = "/var/lib/sops-nix/key.txt";

    # Secret definitions for Audax Dashboard
    secrets = {
      "audax-dashboard/nvd-api-key" = {
        owner = "audax-dashboard";
        group = "audax-dashboard";
        mode = "0440";
      };
      "audax-dashboard/threatfox-api-key" = {
        owner = "audax-dashboard";
        group = "audax-dashboard";
        mode = "0440";
      };
      "audax-dashboard/dashboard-passphrase" = {
        owner = "audax-dashboard";
        group = "audax-dashboard";
        mode = "0440";
      };
    };
  };
}
