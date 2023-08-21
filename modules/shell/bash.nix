{ pkgs, ... }:

{
  programs.bash = {
    enableCompletion = true;

    shellAliases = {
      ll = "ls -lhF --color=auto";

      rm = "rm -i";
      mv = "mv -i";
      cp = "cp -r";

      cal = "cal -m";

      ".." = "cd ..";
    };
  };
}
