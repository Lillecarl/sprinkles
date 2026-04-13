# Sprinkles

Sprinkles is a convention and a vendorable library for structuring dependencies,
exposing items, allowing self-references, and enabling overridability.

Sprinkles does not require or provide any particular mechanism for acquiring and
pinning sources. Instead, it expects another tool to provide that functionality,
such as [`NIX_PATH`], [built-in fetchers], [lon], [niv], [npins], or even
[flakes], for example.

[`NIX_PATH`]: https://docs.lix.systems/manual/lix/stable/command-ref/env-common.html#env-NIX_PATH
[built-in fetchers]: https://docs.lix.systems/manual/lix/stable/language/builtins.html
[lon]: https://github.com/nikstur/lon
[niv]: https://github.com/nmattia/niv
[npins]: https://github.com/andir/npins
[flakes]: https://docs.lix.systems/manual/lix/stable/command-ref/new-cli/nix3-flake.html

## WORK IN PROGRESS

Most of the previous content of this README can be restored after some editing I
just don't feel like doing right this second.

The basic idea of this redesign is to:

1. Move the fixpoint to cover the entire Sprinkle, i.e. to include the sources
   and inputs as well as the outputs.
2. Reduce the amount of rules that need to be followed for a Sprinkle to be
   considered valid.
3. Change the distribution mechanism from a complicated combination of formal
   arguments, source acquisition and pinning tool, and `if` statements to the
   simpler approach of "vendor a file and import it".

So, roughly, the usage is now:

1. Copy `sprinkles.nix` into your project somewhere, preferably keeping the
   name.
2. Do not edit it beyond formatting changes.
3. Use it in your top level Nix file, say `default.nix`, like this:

   ```nix
   let sprinkles = import ./path/to/sprinkles.nix; in

   sprinkles.new (self: {
     # Define sources and inputs with these two attributes, whose values have
     # some conventions.
     sources = { /* Attributes whose values can be `import`ed go here. */ };
     inputs = { /* Attributes whose values are arbitrary go here. */ };

     # Define outputs as arbitrary attributes of this attribute set, with some
     # well-known attribute names. For example:
     nixosConfigurations = { /* NixOS configurations... */ };
     nixosModules = { /* NixOS modules... */ };
     overlays = { /* Nixpkgs overlays... */ };
     packages = { /* Packages... */ };
     shells = { /* Development shells... */ };
     lib = { /* Library functions and values... */ };
   })
   ```

4. Evaluate it like `nix build -f . packages.default` or `nix build --impure
   --expr '((import ./.).override (prev: { sources = prev.sources // { nixpkgs =
   <nixpkgs>; } })).packages.default'`.
