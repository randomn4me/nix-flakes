{ inputs, ... }:
{
    imports = [
        inputs.audax-zola.nixosModules.default
    ];

    services.audax-page = {
      enable = true;
      domain = "audax-security.com";
    };

}

