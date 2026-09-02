{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  # Generic sops plumbing only. Each host sets its own `sops.defaultSopsFile`
  # (hosts/<host>/secrets.yaml) and declares the secrets it actually consumes —
  # a secret declared here would be provisioned on every host, and activation
  # fails on any host whose secrets file does not contain it.
  sops = {
    # This is using an age key that is expected to be already present on the system
    age.keyFile = "/var/lib/sops-nix/key.txt";
  };
}
