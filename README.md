# Sprinkles

Sprinkles provides a common schema for managing dependencies, exposing items,
and enabling overrideability.

Sprinkles does not require or provide any particular mechanism for acquiring and
pinning sources. Instead, it expects another tool to provide that functionality,
such as [`NIX_PATH`], [built-in fetchers], [niv], [npins], or even [flakes],
for example.

[`NIX_PATH`]: https://docs.lix.systems/manual/lix/stable/command-ref/env-common.html#env-NIX_PATH
[built-in fetchers]: https://docs.lix.systems/manual/lix/stable/language/builtins.html
[niv]: https://github.com/nmattia/niv
[npins]: https://github.com/andir/npins
[flakes]: https://docs.lix.systems/manual/lix/stable/command-ref/new-cli/nix3-flake.html

## Usage

In this section, it will be assumed that a path to the root of this repository
is in `NIX_PATH` with the name `sprinkles`. This is done to avoid getting
bogged down in the details of the acquisition and pinning of sources. In
general however, this is recommended against because it is not conducive to
reproducibility.

### Public API

Only the `default.nix` file at the root of this repository and items accessible
through it are considered public API.

### Minimal example

Here is a minimal example of a Sprinkle:

```nix
let
  source = {
    sprinkles = <sprinkles>;
  };

  input = source: {
    sprinkles = import source.sprinkles;
  };
in

(input source).sprinkles.new {
  inherit input source;

  output = self: null;
}
```

### Accessing `source` and `input`

**IMPORTANT:** The `(input source).sprinkles.new {` and `inherit input source;`
lines must be the only instances where:

* `input` is called manually.
* `source` and `input` are directly referenced from their `let` bindings.

Outside of those two cases, accessing `input` and `source` must be done in
the body of the `output` function via its argument.

This allows consumers of a Sprinkle to override its sources, inputs, or both.
However, it is unfortunately not possible to override the source or input used
for the initial `(input source).sprinkles.new` call.

### The difference between sources and inputs

A source is generally a path, or something that coerces to a path, to a
dependency.

An input is a source with an arbitrary transform applied to it. Typically,
this means `import`ing the source.

It is not necessary for each source to have a corresponding input and vice
versa.

For example, `<nixpkgs>` could be a source, and `import sources.nixpkgs {}`
could be an input.

This distinction is useful because it allows for the underlying source and the
transform to overridden independently, and for the underlying source and its
transform to be accessed simultaneously throughout a Sprinkle.

### The `output` function

The return value of the `output` function is completely freeform. However, there
are some conventions:

* The argument is named `self`.
* The return value is an attribute set.
* The attribute name `lib` is an attribute set of functions, potentially nested
  within additional attribute sets.
* The attribute name `package` is an attribute set of packages, potentially
  nested within additional attribute sets. If there is only one package or if
  there is an obvious primary package, its attribute name is `default`.
* The attribute name `shell` is an attribute set of shells, potentially nested
  within additional attribute sets. If there is only one shell or if there is an
  obvious primary shell, its attribute name is `default`.
* The attribute name `nixosModule` is an attribute set of NixOS modules,
  potentially nested within additional attribute sets. If there is only one
  NixOS module or if there is an obvious primary NixOS module, its attribute
  name is `default`.
* The attribute name `homeManagerModule` is an attribute set of Home Manager
  modules, potentially nested within additional attribute sets. If there is only
  one Home Manager module or if there is an obvious primary Home Manager module,
  its attribute name is `default`.
* The attribute name `nixosConfiguration` is an attribute set of NixOS
  configurations, potentially nested within additional attribute sets. If
  there is only one NixOS configuration or if there is an obvious primary NixOS
  configuration, its attribute name is `default`.
* The attribute name `homeManagerConfiguration` is an attribute set of Home
  Manager configurations, potentially nested within additional attribute sets.
  If there is only one Home Manager configuration or if there is an obvious
  primary Home Manager configuration, its attribute name is `default`.

The argument to the `output` function is an attribute set that contains the
following attributes:

* `source`: The possibly-overridden `source` attribute set originally defined in
  the `let` binding.
* `input`: The possibly-overridden attribute set returned by the `input`
  function originally defined in the `let` binding.
* `output`: The value returned by the `output` function. This allows
  self-references without using the `rec` keyword.
* `override`: A function that can be used to override sources and inputs of
  the Sprinkle.

### The `(input source).sprinkles.new` function

The value returned by the `(input source).sprinkles.new` function is the same
as the argument to the `output` function. This allows consumers of a Sprinkle to
be able to access its outputs, apply overrides to it, and inspect its original
sources and inputs.

### Overriding sources and inputs

Assuming the minimal example Sprinkle has been imported into the variable
`sprinkle`, its sources and inputs can be overridden like so:

```nix
sprinkle.override {
  source = {
    sprinkles = <sprinkles>;
  };

  input = source: {
    sprinkles = (import source.sprinkles) // {
      new = _: builtins.abort "overridden `new` function in effect";
    };
  };
}
```

The `source` attribute itself is optional, and so are the attributes within it.
Similarly, the `input` attribute itself is optional, and so are the attributes
within its return value. The `source` attribute set provided to the `input`
function, for each source, will contain the overridden source if the source was
overridden, or the original source if not. If the overridden `source` or `input`
attribute sets contain any attributes that are not present in the original
Sprinkle, an error message will be emitted and evaluation will abort.

In the above example, the `source` override makes no semantic difference because
it's the same as the original, and the `input` override imports the source like
before but also overrides the `new` function. The override for the `sprinkles`
input will not apply for the `(input source).sprinkles.new` call inside
`sprinkle` as discussed earlier, so this will only cause evaluation to abort if
it is called again inside `sprinkle`'s `output` function.

### API reference

See the source code at [`nix/lib/default.nix`](nix/lib/default.nix) which
contains doc comments.

Also try loading the `default.nix` in `nix repl` and exploring the API
interactively, making use of `:doc` if using [Lix].

[Lix]: https://lix.systems/
