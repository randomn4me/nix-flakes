{ inputs, ... }:
{
    imports = [
        inputs.audax-dashboard.nixosModules.default
    ];
    services.audax-dashboard = {
        enable = true;
        domain = "dashboard.audax-security.com";
        # nvdApiKeyFile = "/run/secrets/nvd-api-key";
    };
}

