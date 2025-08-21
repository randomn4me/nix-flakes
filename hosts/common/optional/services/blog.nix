{ inputs, ... }:
{
    imports = [
        inputs.audacis-blog.nixosModules.default
    ];
    services.audacis-blog.enable = true;
}
