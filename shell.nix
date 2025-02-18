{pkgs ? import <nixpkgs> {}, ...}:

pkgs.mkShellNoCC {
  name = "awesome-debug";

  packages = with pkgs; [
    awesome
    arandr
  ];

  NIX_LANG_LUA = "TRUE";
}
