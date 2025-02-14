let
  source =
    # Load sources from `flake.lock`.
    (import (
      let
        lock = builtins.fromJSON (builtins.readFile ./flake.lock);
        inherit (lock.nodes.flake-compat.locked) narHash rev url;
      in
      builtins.fetchTarball {
        url = "${url}/archive/${rev}.tar.gz";
        sha256 = narHash;
      }
    ) { src = ./.; }).inputs
    //
    # Load sources from elsewhere.
    {
      self = if builtins.pathExists ../.git
        then builtins.fetchGit ../.
        else ../.;
    };

  input = source: {
    sprinkles = import source.self;
    nixpkgs = import source.nixpkgs {
      config.allowAliases = false;
    };
  };
in

(input source).sprinkles.new {
  inherit input source;

  output = self: {
    shell.default = self.input.nixpkgs.callPackage ./shell/default {};
  };
}
