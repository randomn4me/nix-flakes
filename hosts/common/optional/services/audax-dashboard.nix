{ inputs, lib, config, ... }:
{
    imports = [
        inputs.audax-dashboard.nixosModules.default
    ];
    services.audax-dashboard = {
        enable = true;
        domain = "dashboard.audax-security.com";
        acmeEmail = lib.mkDefault "admin@audax-security.com";

        # Use sops-managed secrets for API keys and password
        nvdApiKeyFile = config.sops.secrets."audax-dashboard/nvd-api-key".path;
        threatfoxApiKeyFile = config.sops.secrets."audax-dashboard/threatfox-api-key".path;
        dashboardPasswordFile = config.sops.secrets."audax-dashboard/dashboard-passphrase".path;
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
}

