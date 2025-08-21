{ inputs, ... }:
{
    imports = [
        inputs.audacis-blog.nixosModules.default
    ];
    services.audacis-blog.enable = true;
    services.audacis-blog.domain = "audacis.net";
}
