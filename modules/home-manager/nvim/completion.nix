{
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.custom.nvim;
in
{
  config = mkIf cfg.completion {
    programs.nixvim = {
      plugins = {
        # Replaces nvim-cmp + luasnip + lspkind + cmp_nvim_lsp. Snippets go
        # through neovim's own vim.snippet, and blink registers its LSP
        # capabilities itself on nvim 0.11+, so nothing has to be wired by hand.
        blink-cmp = {
          enable = true;
          setupLspCapabilities = false;

          settings = {
            # Explicit rather than a preset, to keep the nvim-cmp bindings.
            keymap = {
              preset = "none";

              "<C-space>" = [
                "show"
                "show_documentation"
                "hide_documentation"
              ];
              "<C-e>" = [ "hide" ];
              "<CR>" = [
                "accept"
                "fallback"
              ];
              "<Tab>" = [
                "select_next"
                "snippet_forward"
                "fallback"
              ];
              "<S-Tab>" = [
                "select_prev"
                "snippet_backward"
                "fallback"
              ];
              "<C-d>" = [
                "scroll_documentation_up"
                "fallback"
              ];
              "<C-f>" = [
                "scroll_documentation_down"
                "fallback"
              ];
            };

            completion = {
              documentation.auto_show = true;
              # Keeps the [LSP]/[Path]/[Snippets] hints lspkind used to draw.
              menu.draw.columns = [
                {
                  __unkeyed-1 = "label";
                  __unkeyed-2 = "label_description";
                  gap = 1;
                }
                {
                  __unkeyed-1 = "kind_icon";
                  __unkeyed-2 = "source_name";
                  gap = 1;
                }
              ];
            };

            signature.enabled = true;
            appearance.nerd_font_variant = "normal";
          };
        };
      };
    };
  };
}
