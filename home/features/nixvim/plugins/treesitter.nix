{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      folding = true;
      indent = true;
      nixvimInjections = true;

      disabledLanguages = [ "latex" ];
    };

    treesitter-refactor = {
      enable = true;
      highlightDefinitions = {
        enable = true;
        clearOnCursorMove = false;
      };
    };
  };
}
