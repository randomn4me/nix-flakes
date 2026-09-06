# Services whose implementation lives in a private flake input.
#
# Split out of ./default.nix so that `nixosConfigurations.netcup-core` can be
# evaluated and built without them. Each of these does an unconditional
# `imports = [ inputs.<x>.nixosModules.default ]`, so evaluating this file
# requires all three git remotes to be reachable -- an expired key, a deleted
# branch or a VPN-only host then blocks the rebuild. The core config carries
# nginx, acme, forgejo, vaultwarden, zulip and the backups, so keeping it
# buildable on its own is what lets the box still take a security update while
# one of these repos is unreachable.
{
  imports = [
    ../../modules/nixos/services/audacis-blog.nix
    ../../modules/nixos/services/serify-page.nix
    ../../modules/nixos/services/code-of-courage.nix
  ];

  services.custom = {
    audacis-blog.enable = true;
    serify-page = {
      enable = true;
      redirectDomains = [
        "acipra.de"
        "acipra.com"
        "serify.de"
        "serify.ai"
      ];
    };
    code-of-courage.enable = true;
  };
}
