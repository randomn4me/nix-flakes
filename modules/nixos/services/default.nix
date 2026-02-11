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
    ./ntfy.nix

    # External flake-based services
    ./audacis-blog.nix
    ./audax-page.nix
    ./audax-zola.nix
    ./code-of-courage.nix
  ];
}
