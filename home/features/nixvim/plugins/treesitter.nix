{
  programs.nixvim.plugins = {
    treesitter = {
      enable = true;
      folding = true;
      indent = true;

      nixvimInjections = true;
    };

    treesitter-refactor = {
      enable = true;
      highlightDefinitions.enable = true;
    };

    hmts.enable = true;
  };
}
