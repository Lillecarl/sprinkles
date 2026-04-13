let
  sprinkles = import ../sprinkles.nix;
in

sprinkles.new (self: {
  sources = import ./lon.nix;

  inputs = {
    nixpkgs = import self.sources.nixpkgs {
      config.allowAliases = false;
    };
  };

  shells.default = self.inputs.nixpkgs.callPackage ./shells/default {};
})
