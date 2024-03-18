{ config, ... }:
{
  programs.nixvim.plugins.obsidian =
    let
      vaultPath = "${config.home.homeDirectory}/usr/docs/obsidian";
    in
    {
      enable = true;
      workspaces = [
        {
          name = "obsidian";
          path = "${vaultPath}";
          overrides.notesSubdir = "./";
        }
      ];

      templates.subdir = "templates";

      dailyNotes = {
        folder = "journal";
        template = "templates/journaling";
      };

      completion.newNotesLocation = "notes_subdir";

      noteIdFunc = # lua
        ''
          function(title)
              return title
          end
        '';
    };
}
