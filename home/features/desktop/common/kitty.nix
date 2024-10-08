{
  home.sessionVariables.TERMINAL = "kitty";
  programs.kitty = {
    enable = true;
    font = {
      name = "monospace";
      size = 10;
    };
    environment.TERM = "xterm-direct";
    themeFile = "tokyo_night_night";
    settings = {
      enable_audio_bell = false;
    };
  };
}
