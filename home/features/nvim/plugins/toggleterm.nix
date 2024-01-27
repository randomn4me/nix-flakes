{
    programs.nixvim = {
        keymaps = [
            {
                key = "<leader>tf";
                action = "<cmd>ToggleTerm<cr>";
                mode = "n";
                options = {
                    desc = "Open terminal";
                };
            }
        ];

        plugins.toggleterm = {
      enable = true;
      direction = "float";
    };
    };

}
