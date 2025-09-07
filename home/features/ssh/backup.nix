{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      storagebox = {
        hostname = "u487410.your-storagebox.de";
        user = "u487410";
        port = 23;
        identityFile = "~/.ssh/storagebox";
      };
    };
  };
}
