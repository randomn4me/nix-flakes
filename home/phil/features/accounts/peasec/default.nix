{ lib, ... }:
{
  imports = [
    #./peasec-mail.nix
    ./peasec-calendar.nix
  ];
}
