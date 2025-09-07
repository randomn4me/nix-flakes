{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      hetzner = {
        hostname = "168.119.169.96";
        user = "r4ndom";
        identityFile = "~/.ssh/hetzner-privat";
      };

      "github.com" = {
        identityFile = "~/.ssh/github";
      };

      "git.audacis.net" = {
        identityFile = "~/.ssh/forgejo-audacis";
        user = "forgejo";
      };

      "codeberg.org" = {
        identityFile = "~/.ssh/codeberg";
      };

      pi = {
        hostname = "192.168.178.3";
        user = "r4ndom";
        identityFile = "~/.ssh/rpi5";
      };

      netcup = {
        hostname = "89.58.28.80";
        user = "phil";
        identityFile = "~/.ssh/netcup";
      };
    };
  };
}
