{ config, ...}:
{
  home.sessionVariables.RUNNER = "bemenu";

  programs.bemenu = {
    enable = true;
    settings = let
      inherit (config.colorscheme) colors;
    in {
      ignorecase = true;
      # title
      tf = "#000000";
      tb = "#${colors.base05}";
      # selected
      sf = "#000000";
      sb = "#${colors.base05}";
      # cursor
      cf = "#${colors.base00}";
      cb = "#${colors.base05}";
      # normal
      nb = "#000000";
      nf = "#${colors.base05}";
      # highlighted
      hf = "#000000";
      hb = "#${colors.base05}";
    };
  };
}
