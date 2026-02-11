{ config, lib, ... }:

with lib;

let
  cfg = config.services.custom.ntfy;
in
{
  options.services.custom.ntfy = {
    enable = mkEnableOption "ntfy push notification service";

    domain = mkOption {
      type = types.str;
      default = "ntfy.audacis.net";
      description = "Domain name for ntfy";
    };

    listenAddress = mkOption {
      type = types.str;
      default = "127.0.0.1:2586";
      description = "Internal address ntfy listens on";
    };

    cacheDuration = mkOption {
      type = types.str;
      default = "12h";
      description = "Duration for which messages are cached";
    };

    attachmentTotalSizeLimit = mkOption {
      type = types.str;
      default = "1G";
      description = "Total size limit for all attachments";
    };

    attachmentFileSizeLimit = mkOption {
      type = types.str;
      default = "15M";
      description = "Per-file size limit for attachments";
    };

    attachmentExpiryDuration = mkOption {
      type = types.str;
      default = "3h";
      description = "Duration after which attachments expire";
    };

    visitorSubscriptionLimit = mkOption {
      type = types.int;
      default = 50;
      description = "Maximum number of subscriptions per visitor";
    };

    auth = {
      enableAuth = mkOption {
        type = types.bool;
        default = true;
        description = "Enable authentication for ntfy";
      };

      authFile = mkOption {
        type = types.str;
        default = "/var/lib/ntfy-sh/user.db";
        description = "Path to user/access database";
      };

      defaultAccess = mkOption {
        type = types.enum [ "read-write" "read-only" "write-only" "deny-all" ];
        default = "deny-all";
        description = "Default access for unauthenticated users";
      };

      enableLogin = mkOption {
        type = types.bool;
        default = true;
        description = "Enable user login via web/API";
      };

      enableSignup = mkOption {
        type = types.bool;
        default = false;
        description = "Allow new user registration";
      };

      users = mkOption {
        type = types.listOf (types.submodule {
          options = {
            username = mkOption {
              type = types.str;
              description = "Username for ntfy authentication";
            };

            passwordFile = mkOption {
              type = types.path;
              description = "Path to file containing the user's password";
            };

            role = mkOption {
              type = types.enum [ "user" "admin" ];
              default = "user";
              description = "User role (user or admin)";
            };

            access = mkOption {
              type = types.listOf (types.submodule {
                options = {
                  topic = mkOption {
                    type = types.str;
                    description = "Topic pattern (supports wildcards like 'alerts_*')";
                  };

                  permission = mkOption {
                    type = types.enum [ "read-write" "read-only" "write-only" "deny-all" ];
                    default = "read-write";
                    description = "Permission level for this topic";
                  };
                };
              });
              default = [];
              description = "Access control list for topics";
            };
          };
        });
        default = [];
        description = "Declaratively defined users";
      };
    };

    nginx = {
      enableACME = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ACME SSL certificates";
      };

      forceSSL = mkOption {
        type = types.bool;
        default = true;
        description = "Force SSL for all connections";
      };
    };
  };

  config = mkIf cfg.enable {
    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://${cfg.domain}";
        listen-http = cfg.listenAddress;

        # Cache settings
        cache-file = "/var/lib/ntfy-sh/cache.db";
        cache-duration = cfg.cacheDuration;

        # Attachment settings
        attachment-cache-dir = "/var/lib/ntfy-sh/attachments";
        attachment-total-size-limit = cfg.attachmentTotalSizeLimit;
        attachment-file-size-limit = cfg.attachmentFileSizeLimit;
        attachment-expiry-duration = cfg.attachmentExpiryDuration;

        # Rate limiting
        visitor-subscription-limit = cfg.visitorSubscriptionLimit;

        # Behind proxy
        behind-proxy = true;

        # Authentication settings
        auth-file = mkIf cfg.auth.enableAuth cfg.auth.authFile;
        auth-default-access = mkIf cfg.auth.enableAuth cfg.auth.defaultAccess;
        enable-login = mkIf cfg.auth.enableAuth cfg.auth.enableLogin;
        enable-signup = mkIf cfg.auth.enableAuth cfg.auth.enableSignup;
      };
    };

    services.nginx.virtualHosts.${cfg.domain} = {
      enableACME = cfg.nginx.enableACME;
      forceSSL = cfg.nginx.forceSSL;
      serverName = cfg.domain;

      locations."/" = {
        proxyPass = "http://${cfg.listenAddress}";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;

          # Disable buffering for SSE (Server-Sent Events)
          proxy_buffering off;
        '';
      };
    };

    # User provisioning service
    systemd.services.ntfy-sh-provision-users = mkIf (cfg.auth.enableAuth && cfg.auth.users != []) {
      description = "Provision ntfy users";
      after = [ "ntfy-sh.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "ntfy-sh";
        Group = "ntfy-sh";
      };

      script = let
        ntfyPkg = config.services.ntfy-sh.package;
        provisionUser = user: ''
          # Read password from file
          PASSWORD=$(cat ${user.passwordFile})

          # Check if user exists
          if ${ntfyPkg}/bin/ntfy user list 2>/dev/null | grep -q "^user ${user.username}"; then
            echo "User ${user.username} already exists, updating..."
            # Change password
            echo "$PASSWORD" | ${ntfyPkg}/bin/ntfy user change-pass ${user.username}
            # Change role
            ${ntfyPkg}/bin/ntfy user change-role ${user.username} ${user.role}
          else
            echo "Creating user ${user.username}..."
            echo "$PASSWORD" | ${ntfyPkg}/bin/ntfy user add --role=${user.role} ${user.username}
          fi

          ${lib.concatMapStringsSep "\n" (acl: ''
            echo "Setting access for ${user.username} on topic ${acl.topic}..."
            ${ntfyPkg}/bin/ntfy access ${user.username} ${acl.topic} ${acl.permission}
          '') user.access}
        '';
      in ''
        set -e

        # Wait for ntfy to be ready
        sleep 2

        ${lib.concatMapStringsSep "\n" provisionUser cfg.auth.users}

        echo "User provisioning complete"
      '';
    };
  };
}
