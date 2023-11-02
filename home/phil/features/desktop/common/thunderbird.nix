{ config, ... }: {
  programs.thunderbird = {
    enable = true;
    profiles.${config.home.username}.isDefault = true;
    settings = {
      "mail.inline_attachments" = false;
      "mail.identity.default.archive_granularity" = 0;
    };
  };
}
