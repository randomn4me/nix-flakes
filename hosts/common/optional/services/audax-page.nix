{ inputs, ... }:
{
    imports = [
        inputs.audax-page.nixosModules.default
    ];
    services.audax-page.enable = true;
    services.audax-page.domain = "audax-security.com";
    services.audax-page.acmeMail = "admin@audax-security.com";
}
