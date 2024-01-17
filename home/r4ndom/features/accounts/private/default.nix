{ lib, ... }:
{
  imports = [
    ./hetzner-mail.nix

    ./audacis-contacts.nix
    ./audacis-calendar.nix
  ];
}
