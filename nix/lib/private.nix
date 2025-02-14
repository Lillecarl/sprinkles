rec {
  /**
  Remove the elements in `ys` from `xs`.

  # Type

  ```
  subtractLists[T] = list[T] -> list[any] -> list[T];
  ```
  */
  subtractLists = xs: ys: (builtins.filter (x: !(builtins.elem x ys)) xs);

  /**
  Merges two attribute sets, asserting that `y` is a subset of `x`. If this
  is not the case, an error is thrown with the given `msg`, after which the
  rejected attribute names will be listed on a new line. The values in `y` take
  precedence in the returned attribute set.

  # Type

  ```
  mergeAttrsSubset =
    attrset[any] ->
    attrset[any] ->
    str ->
    attrset[any];
  ```
  */
  mergeAttrsSubset = x: y: msg:
    let
      inYNotX = subtractLists
        (builtins.attrNames y)
        (builtins.attrNames x);
    in

    if builtins.length inYNotX == 0
    then x // y
    else builtins.abort (builtins.concatStringsSep "" [
      msg
      "\nnames: "
      (builtins.concatStringsSep ", " (builtins.map (x: "`${x}`") inYNotX))
    ]);
}
