{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.custom.rbw;
in
{
  options.custom.rbw = {
    enable = mkEnableOption "Enable rbw";
  };

  config = mkIf cfg.enable {
    programs.rbw = {
      enable = true;
      settings = {
        email = "p.services@audacis.net";
        base_url = "https://vault.audacis.net";
        pinentry = pkgs.pinentry-qt;
      };
    };

    home.packages = with pkgs; [ rofi-rbw ];

    xdg.configFile."rofi-rbw.rc".text = ''
      action = copy
      clear-after = 15
      selector = ${if config.programs.wofi.enable then "wofi" else "bemenu"}
    '';
  };
}
