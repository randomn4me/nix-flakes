# r4ndom flake

This flake defines my nixOS configuration(s).
It currently only stores one configuration for one system, but this is expected to soon be expanded.
I also aim to split the different use-cases to different users and eventually support (impermanence)[https://github.com/nix-community/impermanence] and (sops)[https://github.com/Mic92/sops-nix].

It uses the experimental nix feature `nix-command`, `flakes`, and `repl-flake` and for dotfiles it uses (home-manager)[https://github.com/nix-community/home-manager].

### Acknowledgements

This flake is heavily inspired by (this)[https://git.sr.ht/~misterio/nix-config] one.
