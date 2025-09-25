{ inputs, ... }:
{
    imports = [
        inputs.joshua.nixosModules.default
    ];
    services.joshua-dashboard.enable = true;
    services.joshua-dashboard.domain = "joshua.peasec.de";
}

