{ inputs, ... }:
{
    imports = [
        inputs.audax-zola.nixosModules.default
    ];

    services.audax-page = {
      enable = true;
      domain = "audax-security.com";
      smtp = {
        host = "mail.your-server.com";
        port = 587;
        user = "noreply@audax-security.com";
        passwordFile = "/home/phil/audax/noreply-password";  # Outside repo
        tls = true;
      };
    };

}

