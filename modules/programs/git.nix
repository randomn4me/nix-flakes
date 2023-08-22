{ pkgs, ... }:
{
  programs = {
    git = {
      enable = true;
      aliases = {
        st = "status";
      };
    };
  };
}

