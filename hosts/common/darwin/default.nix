{ outputs, ... }:
{
  imports = [
    ./nix.nix
    ./users.nix
    ./sops.nix
  ];

  security.pam.services.sudo_local.touchIdAuth = true;
}
