{
  programs.ssh = {
    enable = true;

    settings = {
      "*" = {
        KexAlgorithms = "mlkem768x25519-sha256,sntrup761x25519-sha512,sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256";
      };
      hetzner = {
        HostName = "168.119.169.96";
        User = "r4ndom";
        IdentityFile = "~/.ssh/hetzner-privat";
      };

      "github.com" = {
        IdentityFile = "~/.ssh/github";
      };

      "git.audacis.net" = {
        IdentityFile = "~/.ssh/forgejo-audacis";
        User = "forgejo";
      };

      "codeberg.org" = {
        IdentityFile = "~/.ssh/codeberg";
      };

      pi = {
        HostName = "192.168.178.3";
        User = "r4ndom";
        IdentityFile = "~/.ssh/rpi5";
      };

      netcup = {
        HostName = "89.58.28.80";
        User = "phil";
        IdentityFile = "~/.ssh/netcup";
      };
    };
  };
}
