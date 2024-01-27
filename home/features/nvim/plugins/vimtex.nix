{ config, ... }:
{
    programs.nixvim = {
        plugins.vimtex = {
            enable = true;
            viewMethod = if config.programs.zathura.enable then "zathura" else "general";

            keymaps = [
            {
                mode = "n";
                key = "m";
                action = ":VimtexView<CR>";
                options.silent = true;
            }
            ];

            autoCmd = [
            {
                event = ["BufEnter" "BufWinEnter"];
                pattern = "*.tex";
                command = "set filetype=tex \"| VimtexTocOpen";
            }

            # Folding
            {
                event = "FileType";
                pattern = ["tex" "latex"];
                callback.__raw = ''
                    function ()
                    vim.o.foldmethod = 'expr'
                    vim.o.foldexpr = 'vimtex#fold#level(v:lnum)'
                    vim.o.foldtext = 'vimtex#fold#text()'
                    end
                    '';
            }

            # Compile on initialization
            {
                event = "User";
                pattern = "VimtexEventInitPost";
                callback = "vimtex#compiler#compile";
            }

            # Cleanup on exit
            {
                event = "User";
                pattern = "VimtexEventQuit";
                command = "call vimtex#compiler#clean(0)";
            }
            ];
        };
    };
}


