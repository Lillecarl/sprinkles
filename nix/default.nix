{ sprinkles ? null }:

let
  source =
    # Load sources from `lon.nix`.
    (import ./lon.nix)
    //
    # Load sources from elsewhere.
    {
      self = if builtins.pathExists ../.git
        then builtins.fetchGit { url = ../.; shallow = true; }
        else ../.;
    };

  input = source: {
    sprinkles = if sprinkles == null
      then import source.self
      else sprinkles;
    nixpkgs = import source.nixpkgs {
      config.allowAliases = false;
    };
  };
in

(input source).sprinkles.new {
  inherit input source;

  output = self: {
    shells.default = self.input.nixpkgs.callPackage ./shells/default {};
  };
}
