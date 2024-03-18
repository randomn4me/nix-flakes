{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      storagebox = {
        hostname = "u340000.your-storagebox.de";
        user = "u340000";
        port = 23;
        identityFile = "~/.ssh/storagebox";
      };
    };
  };
}
