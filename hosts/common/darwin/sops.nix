{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.darwinModules.sops
  ];

  # Generic sops plumbing only; see hosts/common/optional/sops.nix. A host that
  # declares secrets must also set `sops.defaultSopsFile`.
  sops = {
    # This is using an age key that is expected to be already present on the system
    age.keyFile = "/var/lib/sops-nix/key.txt";
  };
}
