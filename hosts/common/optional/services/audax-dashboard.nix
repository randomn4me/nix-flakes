{ inputs, lib, ... }:
{
    imports = [
        inputs.audax-dashboard.nixosModules.default
    ];
    services.audax-dashboard = {
        enable = true;
        domain = "dashboard.audax-security.com";
	acmeEmail = lib.mkDefault "admin@audax-security.com";
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
}

