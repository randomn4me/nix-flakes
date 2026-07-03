{
  programs.ssh = {
    enable = true;

    # Hetzner Storage Boxes (SSH-only). Match by real hostname so borgmatic
    # picks the right per-box key automatically when it connects via the repo URL.
    settings = {
      # Falkenstein (DE)
      "u487410.your-storagebox.de" = {
        User = "u487410";
        Port = 23;
        IdentityFile = "/run/secrets/storagebox/falkenstein-ssh-key";
      };
      # Helsinki (FI)
      "u489939.your-storagebox.de" = {
        User = "u489939";
        Port = 23;
        IdentityFile = "/run/secrets/storagebox/helsinki-ssh-key";
      };
    };
  };
}
