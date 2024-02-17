{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      hetzner = {
        hostname = "audacis.net";
        user = "r4ndom";
        identityFile = "~/.ssh/hetzner-privat";
      };

      "github.com" = {
        identityFile = "~/.ssh/github";
      };

      pi = {
        hostname = "192.168.178.3";
        user = "r4ndom";
        identityFile = "~/.ssh/rpi5";
      };
    };
  };
}
