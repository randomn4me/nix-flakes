{ config, inputs, ... }: {
  programs.firefox = {
    enable = true;

    profiles.${config.home.username} = {
      bookmarks = { };
      #extensions = with inputs.firefox-addons; [
      #  ublock-origin
      #  bitwarden
      #  vimium
      #  cookie-autodelete
      #  simple-tab-groups
      #];

      settings = {
        "browser.disableResetPrompt" = true;
        "browser.download.useDownloadDir" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "privacy.trackingprotection.enabled" = true;
        "signon.rememberSignons" = false;
      };
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}
