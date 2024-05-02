{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    checkConfig = true;
    package = pkgs.postgresql_16;
  };
}
