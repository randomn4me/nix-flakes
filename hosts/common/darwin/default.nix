{ outputs, ... }:
{
  imports = [
    ./nix.nix
    ./users.nix
  ];

  security.pam.services.sudo_local.touchIdAuth = true;
}
