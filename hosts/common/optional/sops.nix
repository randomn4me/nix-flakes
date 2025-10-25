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

    # Example secret definitions - uncomment and modify as needed
    # secrets.example-secret = {
    #   # The secret will be written to /run/secrets/example-secret by default
    #   # owner = "user";
    #   # group = "group";
    #   # mode = "0440";
    # };
  };
}
