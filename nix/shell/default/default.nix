{
  engage,
  findutils,
  markdownlint-cli,
  mkShell,
  nixdoc,
  reuse,
}:

mkShell {
  packages = [
    engage
    findutils
    markdownlint-cli
    nixdoc
    reuse
  ];
}
