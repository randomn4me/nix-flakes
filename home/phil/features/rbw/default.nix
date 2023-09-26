{ lib, config, ... }:
{
  imports = [
    ./rbw.nix
  ] ++ (lib.optionals config.programs.wofi.enable [
    ./rofi-rbw.nix
  ]);
}
