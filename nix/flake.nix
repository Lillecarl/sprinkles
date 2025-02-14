{
  # Always specify `ref` and set `flake = false`.
  inputs = {
    flake-compat = { url = "git+https://git.lix.systems/lix-project/flake-compat?ref=main"; flake = false; };
    nixpkgs = { url = "github:NixOS/nixpkgs?ref=nixos-unstable"; flake = false; };
  };

  # This file is only used for its `inputs` functionality.
  outputs = inputs: {};
}
