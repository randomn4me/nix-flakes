{
  imports = [
    # Existing modules
    ./audio.nix
    ./printing.nix

    # Core infrastructure services
    ./acme.nix
    ./nginx.nix
    ./postgres.nix
    ./fail2ban.nix

    # Application services
    ./grafana.nix
    ./hedgedoc.nix
    ./mastodon.nix
    ./taskserver.nix
    ./forgejo.nix
    ./vaultwarden.nix
    ./freshrss.nix
    ./zulip.nix
    ./ntfy.nix
    ./alerts.nix
    ./backup.nix
    ./mail-relay.nix

    # External flake-based services live in hosts/netcup, not here: each one
    # does an unconditional `imports = [ inputs.<x>.nixosModules.default ]`,
    # so listing them globally forces every host to fetch netcup's private
    # git+ssh repos — one unreachable repo then blocks every rebuild.
    ./podman-cleanup.nix
    ./vulnix-scan.nix
  ];
}
