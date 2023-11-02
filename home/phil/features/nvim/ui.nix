{ pkgs, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = alpha-nvim;
      type = "lua";
      config = # lua
        ''
          local alpha = require("alpha")
          local dashboard = require("alpha.themes.dashboard")

          dashboard.section.header.val = {
                "                                                     ",
                "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
                "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
                "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
                "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
                "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
                "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
                "                                                     ",
          }
          dashboard.section.header.opts.hl = "Title"

          dashboard.section.buttons.val = {
              dashboard.button( "n", "󰈔 New file" , ":enew<CR>"),
              dashboard.button( "e", " Explore", ":Explore<CR>"),
              dashboard.button( "g", " Git summary", ":Git | :only<CR>"),
              dashboard.button( "c", "  Nix config flake" , ":cd ~/etc | :e flake.nix<CR>"),
              dashboard.button( "q", "󰅙  Quit nvim", ":qa<CR>"),
          }

          alpha.setup(dashboard.opts)
        '';
    }

    {
      plugin = which-key-nvim;
      type = "lua";
      config = # lua
        ''
          require('which-key').setup{}
        '';
    }

    # TODO
    #{
    #  plugin = heirline-nvim;
    #  type = "lua";
    #  config = "
    #  ";
    #}

    #{
    #  plugin = rose-pine;
    #  type = "lua";
    #  config = /* lua */ ''
    #    vim.cmd('colorscheme rose-pine')
    #  '';
    #}

    {
      plugin = gitsigns-nvim;
      type = "lua";
      config = # lua
        ''
          require('gitsigns').setup{
            signs = {
              add = { text = '+' },
              change = { text = '~' },
              delete = { text = '_' },
              topdelete = { text = '‾' },
              changedelete = { text = '~' },
            },
          }
        '';
    }

    {
      plugin = fidget-nvim;
      type = "lua";
      config = # lua
        ''
          require('fidget').setup{
            text = {
              spinner = "dots",
            },
          }
        '';
    }
  ];
}
