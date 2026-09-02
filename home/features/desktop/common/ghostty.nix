{
  home.sessionVariables.TERMINAL = "ghostty";
  programs.ghostty = {
    enable = true;

    settings = {
      font-family = "FiraMono Nerd Font Mono";
      font-size = 13;

      mouse-hide-while-typing = true;

      theme = "TokyoNight";

      quick-terminal-animation-duration = 0.1;
      keybind = [
        "global:super+shift+plus=toggle_quick_terminal"
        "shift+enter=text:\\n"
      ];
    };
  };
}
