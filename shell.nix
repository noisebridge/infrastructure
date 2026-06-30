{
  pkgs ? import <nixpkgs> { config.allowUnfree = true; },
}:
with pkgs;

mkShell {
  buildInputs = [
    ansible
    ansible-lint

    dockerfmt
  ];
}
