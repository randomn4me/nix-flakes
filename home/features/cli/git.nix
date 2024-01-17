{ pkgs, lib, ... }: {
  home.packages = with pkgs; [
    lazygit
  ];

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;

    aliases = {
      graph = "log --decorate --oneline --graph";
      st = "status";
      tree = "log --oneline --graph --decorate --all";
    };

    userName = "Philipp Kühn";
    userEmail = lib.mkDefault "p.contact@audacis.net";

    extraConfig = { init.defaultBranch = "main"; };
    lfs.enable = true;
    ignores = [ ".direnv" ];

    delta.enable = true;
  };
}

