{ pkgs, ... }:
{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    {
      plugin = nvim-notify;
      type = "lua";
    }

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
            -- text = {
            --   spinner = "dots",
            -- },
          }
        '';
    }

    {
      plugin = tokyonight-nvim;
      type = "lua";
      config = # lua
        ''
          require("tokyonight").setup({
            style = "night",
            transparent = true,
            terminal_colors = true,
            style = {
                comments = { italic = false },
                keywords = { italic = false },
                sidebars = "dark",
                floats = "dark",
            },
          })

          vim.cmd("colorscheme tokyonight")
        '';
    }

    {
      plugin = nvim-colorizer-lua;
      type = "lua";
      config = # lua
        ''
          require("colorizer").setup()
        '';
    }

    {
      plugin = lualine-nvim;
      type = "lua";
      config = # lua
        ''
          require('lualine').setup()
        '';
    }
  ];
}
