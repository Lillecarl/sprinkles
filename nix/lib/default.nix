let
  private = import ./private.nix;
in

rec {
  /**
  Create a new Sprinkle.

  # Type

  ```
  source = attrset[any];
  input = attrset[any];

  output = {
    source: source,
    input: input,
    output: any,
    override: {
      ?source: source,
      ?input: source -> input,
    } -> output,
  };

  new = {
    source: source,
    input: source -> input,
    output: output -> any,
  } -> output;
  ```
  */
  new =
    {
      source,
      input,
      output,
    }@args:

    let
      input' = input source;
      output' = output sprinkle;
      errorMessage = attr: (
        "attributes that are not present in the original `${attr}` attribute "
        + "set are present in the overriden `${attr}` attribute set\n"
        + "help: consider removing them from the override"
      );
      sprinkle = {
        inherit source;
        input = input';
        output = output';

        override =
          {
            input ? _: {},
            source ? {},
          }:

          new {
            source = private.mergeAttrsSubset
              args.source
              source
              (errorMessage "source");

            input = source:
              private.mergeAttrsSubset
                (args.input source)
                (input source)
                (errorMessage "input");

            inherit (args) output;
          };
      };
    in

    sprinkle;
}
