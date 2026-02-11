{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      "*" = {
        extraOptions = {
          KexAlgorithms = "mlkem768x25519-sha256,sntrup761x25519-sha512,sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256";
        };
      };
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
