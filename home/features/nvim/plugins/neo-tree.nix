{
    programs.nixvim = {
        keymaps = [
            {
                key = "<leader>e";
                action = ":Neotree action=focus reveal toggle<CR>";
                mode = "n";
                options = {
                    desc = "Focus Neotree";
                    silent = true;
                };
            }
        ];

        plugins.neo-tree = {
            enable = true;

            closeIfLastWindow = true;
            window = {
                width = 30;
                autoExpandWidth = true;
            };
        };
    };
}
