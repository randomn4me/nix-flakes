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
            dashboard.button( "n", "󰈔 New file" , "<cmd>enew<cr>"),
            dashboard.button( "e", " Explore", ":Explore<cr>"),
            dashboard.button( "g", " Git summary", ":Git | :only<cr>"),
            dashboard.button( "c", "  Nix config flake" , ":cd ~/etc | :e flake.nix<cr>"),
            dashboard.button( "q", "󰅙  Quit nvim", ":qa<CR>"),
        }

        alpha.setup(dashboard.opts)
        vim.keymap.set("n", "<space>a", "<cmd>Alpha<cr>", { desc = "Open alpha dashboard" })
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

    {
      plugin = tokyonight-nvim;
      type = "lua";
      config = /* lua */ ''
        require("tokyonight").setup({
          style = "night",
        })
        
        vim.cmd[[colorscheme tokyonight-night]]
      '';
    }

    {
      plugin = lualine-nvim;
      type = "lua";
      config = /* lua */ ''
      require('lualine').setup()
      '';
    }
  ];
}
