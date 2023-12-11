{ pkgs, ... }: {
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = alpha-nvim;
      type = "lua";
      config = /* lua */ ''
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
        vim.keymap.set("n", "<space>a", ":Alpha<CR>", { desc = "Open alpha dashboard" })
      '';
    }

    {
      plugin = which-key-nvim;
      type = "lua";
      config = /* lua */ ''
        require('which-key').setup{}
      '';
    }

    {
      plugin = gitsigns-nvim;
      type = "lua";
      config = /* lua */ ''
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
      config = /* lua */ ''
        require('fidget').setup{
          -- text = {
          --   spinner = "dots",
          -- },
        }
      '';
    }
  ];
}
