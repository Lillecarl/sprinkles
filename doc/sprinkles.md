# Sprinkles {#sec-functions-library-sprinkles}


## `sprinkles.new` {#function-library-sprinkles.new}

Create a new Sprinkle.

### Type

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


