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
{ config, ... }:
{
  imports = [
    ../../modules/nixos/services/audacis-blog.nix
    ../../modules/nixos/services/serify-page.nix
    ../../modules/nixos/services/code-of-courage.nix
    ../../modules/nixos/services/poll.nix
    ../../modules/nixos/services/crm.nix
  ];

  services.custom = {
    audacis-blog.enable = true;
    poll = {
      enable = true;
      domain = "poll.serify.eu";
    };
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
    crm = {
      enable = true;
      domain = "crm.serify.eu";
      userTopics.philippkuehn = "serify-crm-philippkuehn";
    };
  };

  # The pilot form endpoint, mailing each enquiry (serify-page
  # docs/contact-form.md).
  # TODO: file enquiries in the CRM once serify-page grows a
  # `contactForm.crm` option: url = http://127.0.0.1:<serify-crm port>/api/v1/leads,
  # tokenFile = sops secret "serify-page/crm-token" (CRM_TOKEN=<contact-relay token>).
  services.serify-page.contactForm = {
    enable = true;
    from = config.services.custom.mail-relay.fromAddress;
    to = "contact@serify.eu";
  };
}
