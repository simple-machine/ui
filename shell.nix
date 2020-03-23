with import <nixpkgs> {};
{ unstable ? import <nixos-unstable> {} }:
let
  flutterPkgs = (import (builtins.fetchTarball  "https://github.com/babariviere/nixpkgs/archive/flutter-init.tar.gz")  {});
in
  stdenv.mkDerivation {
    name = "env";
    buildInputs = [
      flutterPkgs.flutter
      unstable.android-studio
      unstable.dart
    ];
    shellHook=''
      echo -e "\e[0;34m${flutterPkgs.flutter.unwrapped}\e[m" 1>&2
    '';
  }

