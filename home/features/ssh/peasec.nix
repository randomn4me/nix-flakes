{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      "gitlab.dev.peasec.de" = {
        user = "philippkuehn";
        identityFile = "~/.ssh/peasec-gitlab";
      };

      lbc = {
        hostname = "lcluster17.hrz.tu-darmstadt.de";
        user = "ba01viny";
        identityFile = "~/.ssh/hochleistungsrechner";
      };

      "peasec-experimental" = {
        hostname = "130.83.156.168";
        user = "philippkuehn";
        identityFile = "~/.ssh/peasec-experimental";
      };

      "peasec-webserver02" = {
        hostname = "130.83.156.166";
        user = "philippkuehn";
        identityFile = "~/.ssh/peasec-webserver02";
      };
    };
  };
}
