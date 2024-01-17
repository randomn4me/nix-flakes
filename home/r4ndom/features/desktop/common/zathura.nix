{
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      synctex = true;
      synctex-editor-command = "nvr --remote-silent +%{line} %{input}";
    };
  };

  xdg.mimeApps.defaultApplications = {
    "application/pdf" = [ "org.pwmt.zathura.desktop" ];
  };
}
