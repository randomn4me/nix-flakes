{ pkgs, ... }:
{
  programs = {
    git = {
      enable = true;
      aliases = {
        st = "status";
      };
      extraConfig = {
        core = {
          editor = "nvim";
        };
      };
    };
  };
}

