{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    aliases = {
      graph = "log --decorate --oneline --graph";
    };
    userName = "Philipp Kühn";
    userEmail = "contact@audacis.net";
    extraConfig = {
      init.defaultBranch = "main";
    };
    lfs.enable = true;
    ignores = [ ".direnv" ];
  };
}
