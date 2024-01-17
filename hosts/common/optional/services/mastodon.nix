{
  services.mastodon = {
    enable = true;
    localDomain = "social.audacis.net";
    configureNginx = true;
    smtp.fromAddress = "noreply@social.audacis.net";
    extraConfig.SINGLE_USER_MODE = "true";
  };
}
