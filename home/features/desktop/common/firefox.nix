{
  pkgs,
  config,
  inputs,
  ...
}:
{
  programs.firefox = {
    enable = true;

    # Legacy location; matches home.stateVersion < 26.05. Switching to
    # "${config.xdg.configHome}/mozilla/firefox" needs the profile moved by hand.
    configPath = ".mozilla/firefox";

    profiles.${config.home.username} = {
      bookmarks = { };

      extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        ublock-origin
        bitwarden
        simple-tab-groups
        vimium
        cookie-autodelete
        skip-redirect
      ];

      settings = {
        "ui.systemUsesDarkTheme" = 1;
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
