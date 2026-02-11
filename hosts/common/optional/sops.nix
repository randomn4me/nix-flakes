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

    # Secret definitions
    secrets = {
      # Audax Dashboard secrets (disabled - service not enabled)
      # "audax-dashboard/nvd-api-key" = {
      #   owner = "audax-dashboard";
      #   group = "audax-dashboard";
      #   mode = "0440";
      # };
      # "audax-dashboard/threatfox-api-key" = {
      #   owner = "audax-dashboard";
      #   group = "audax-dashboard";
      #   mode = "0440";
      # };
      # "audax-dashboard/dashboard-passphrase" = {
      #   owner = "audax-dashboard";
      #   group = "audax-dashboard";
      #   mode = "0440";
      # };
      "joshua/passphrase" = {
        owner = "nginx";
        group = "nginx";
        mode = "0440";
      };
      "joshua/username" = {
        owner = "nginx";
        group = "nginx";
        mode = "0440";
      };
      # FreshRSS secret (disabled - service not enabled)
      # "freshrss/passphrase" = {
      #   owner = "freshrss";
      #   group = "freshrss";
      #   mode = "0440";
      # };
      # ntfy secret (disabled - service not enabled)
      # "ntfy/philippkuehn" = {
      #   owner = "ntfy-sh";
      #   group = "ntfy-sh";
      #   mode = "0440";
      # };
      # Forgejo runner token (format: TOKEN=<secret>)
      "forgejo/runner-connection" = {
        owner = "gitea-runner";
        group = "gitea-runner";
        mode = "0440";
      };
    };
  };
}
