{ pkgs, lib, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    settings = {
      alias = {
        graph = "log --decorate --oneline --graph";
        st = "status";
        tree = "log --oneline --graph --decorate --all";
      };

      user = {
        name = "Philipp Kühn";
        email = lib.mkDefault "git@audacis.net";
      };

      init.defaultBranch = "main";
    };

    lfs.enable = true;
    ignores = [ ".direnv" ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
