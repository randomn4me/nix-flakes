{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "gitlab.dev.peasec.de" = {
        User = "git";
        IdentityFile = "~/.ssh/peasec-gitlab";
      };

      crawler = {
        HostName = "130.83.156.164";
        User = "philippkuehn";
        IdentityFile = "~/.ssh/peasec-crawler";
      };

      lbc-cpu = {
        HostName = "lcluster14.hrz.tu-darmstadt.de";
        User = "ba01viny";
        IdentityFile = "~/.ssh/hochleistungsrechner";
      };

      lbc-13 = {
        HostName = "lcluster13.hrz.tu-darmstadt.de";
        User = "ba01viny";
        IdentityFile = "~/.ssh/hochleistungsrechner";
      };

      lbc-15 = {
        HostName = "lcluster15.hrz.tu-darmstadt.de";
        User = "ba01viny";
        IdentityFile = "~/.ssh/hochleistungsrechner";
      };

      lbc-17 = {
        HostName = "lcluster17.hrz.tu-darmstadt.de";
        User = "ba01viny";
        IdentityFile = "~/.ssh/hochleistungsrechner";
      };

      lbc-19 = {
        HostName = "lcluster19.hrz.tu-darmstadt.de";
        User = "ba01viny";
        IdentityFile = "~/.ssh/hochleistungsrechner";
      };
    };
  };
}
