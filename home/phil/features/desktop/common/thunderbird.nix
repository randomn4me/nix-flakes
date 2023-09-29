{ config, ... }:
{
  programs.thunderbird = {
    enable = true;
    profiles.${config.home.userName}.isDefault = true;
  };
}
