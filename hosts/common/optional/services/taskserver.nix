{
  services.taskserver = {
    enable = true;
    fqdn = "audacis.net";
    listenHost = "::";
    organisations.personal.users = [ "r4ndom" ];
  };

  networking.firewall.allowedTCPPorts = [ 53589 ];
}
