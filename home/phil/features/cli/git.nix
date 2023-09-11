{ pkgs, lib, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;

    aliases = {
      graph = "log --decorate --oneline --graph";
      st = "status";
    };

    userName = "Philipp Kühn";
    userEmail = lib.mkDefault "p.contact@audacis.net";

    extraConfig = {
      init.defaultBranch = "main";
    };
    lfs.enable = true;
    ignores = [ ".direnv" ];
  };
}

