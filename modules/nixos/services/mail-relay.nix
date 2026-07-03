{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.custom.mail-relay;

  # Rewrite every sender (envelope + From: header) to the relay identity, so
  # locally generated mail (cron, fail2ban, ...) is accepted by the smarthost.
  # A regexp map is read directly by Postfix and needs no postmap step.
  senderCanonical =
    pkgs.writeText "sender_canonical" "/.+/ ${cfg.fromAddress}\n";
in
{
  options.services.custom.mail-relay = {
    enable = mkEnableOption "Local Postfix smarthost relay for outgoing system mail";

    relayHost = mkOption {
      type = types.str;
      default = "mail.your-server.de";
      description = "Upstream SMTP smarthost to relay all outgoing mail through.";
    };

    relayPort = mkOption {
      type = types.port;
      default = 587;
      description = "Submission port on the upstream smarthost (STARTTLS).";
    };

    fromAddress = mkOption {
      type = types.str;
      default = "noreply@audacis.net";
      description = ''
        Address that all outgoing mail is rewritten to use as the sender.
        Must be an address the smarthost lets the authenticated user send as.
      '';
    };

    authUser = mkOption {
      type = types.str;
      default = "noreply@audacis.net";
      description = "Username for SASL authentication against the smarthost.";
    };

    rootMailTo = mkOption {
      type = types.str;
      default = "";
      example = "admin@audacis.net";
      description = ''
        Where to forward mail addressed to local root/postmaster (cron failures,
        systemd OnFailure, smartd, bounces, ...). Empty disables forwarding.
      '';
    };
  };

  config = mkIf cfg.enable {
    # SASL credentials for the smarthost. Rendered outside the Nix store by
    # sops-nix and read directly by Postfix via the texthash lookup table.
    sops.secrets."mail-relay/password" = { };

    sops.templates."postfix-sasl-passwd" = {
      content = "[${cfg.relayHost}]:${toString cfg.relayPort} ${cfg.authUser}:${config.sops.placeholder."mail-relay/password"}";
      owner = config.services.postfix.user;
      mode = "0400";
    };

    services.postfix = {
      enable = true;

      rootAlias = cfg.rootMailTo;

      settings.main = {
        # Only ever talk to localhost; never accept mail from the network.
        inet_interfaces = "loopback-only";
        inet_protocols = "all";
        mynetworks = [ "127.0.0.0/8" "[::1]/128" ];

        # Relay everything through the authenticated smarthost over STARTTLS.
        # Brackets disable MX/SRV lookups for the smarthost name.
        relayhost = [ "[${cfg.relayHost}]:${toString cfg.relayPort}" ];
        smtp_sasl_auth_enable = true;
        smtp_sasl_password_maps = "texthash:${config.sops.templates."postfix-sasl-passwd".path}";
        smtp_sasl_security_options = "noanonymous";
        smtp_tls_security_level = "encrypt";

        sender_canonical_classes = "envelope_sender, header_sender";
        sender_canonical_maps = "regexp:${senderCanonical}";
      };
    };
  };
}
