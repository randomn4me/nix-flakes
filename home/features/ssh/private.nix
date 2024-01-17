{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      hetzner = {
        hostname = "168.119.169.96";
        user = "r4ndom";
        identityFile = "~/.ssh/hetzner-privat";
      };

      "github.com" = {
        identityFile = "~/.ssh/github";
      };

      pi = {
        hostname = "192.168.178.3";
        identityFile = "~/.ssh/rpi5";
      };
    };
  };
}
