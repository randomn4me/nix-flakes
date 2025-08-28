{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      "gitlab.dev.peasec.de" = {
        user = "philippkuehn";
        identityFile = "~/.ssh/peasec-gitlab";
      };

      crawler = {
        hostname = "130.83.156.164";
        user = "philippkuehn";
        identityFile = "~/.ssh/peasec-crawler";
      };

      lbc-cpu = {
        hostname = "lcluster14.hrz.tu-darmstadt.de";
        user = "ba01viny";
        identityFile = "~/.ssh/hochleistungsrechner";
      };

      lbc-13 = {
        hostname = "lcluster13.hrz.tu-darmstadt.de";
        user = "ba01viny";
        identityFile = "~/.ssh/hochleistungsrechner";
      };

      lbc-15 = {
        hostname = "lcluster15.hrz.tu-darmstadt.de";
        user = "ba01viny";
        identityFile = "~/.ssh/hochleistungsrechner";
      };

      lbc-17 = {
        hostname = "lcluster17.hrz.tu-darmstadt.de";
        user = "ba01viny";
        identityFile = "~/.ssh/hochleistungsrechner";
      };

      lbc-19 = {
        hostname = "lcluster19.hrz.tu-darmstadt.de";
        user = "ba01viny";
        identityFile = "~/.ssh/hochleistungsrechner";
      };
    };
  };
}
