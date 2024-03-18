{ config, ... }:
{
  programs.nixvim.plugins.vimtex = {
    enable = true;
    texlivePackage = null;
    settings = {
      view_method = if config.programs.zathura.enable then "zathura" else "general";
      compiler_latexmk = {
        out_dir = "out";
        aux_dir = "out";
      };
    };
  };
}
