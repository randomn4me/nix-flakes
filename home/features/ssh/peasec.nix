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

      lbc-gpu = {
        hostname = "lcluster19.hrz.tu-darmstadt.de";
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
