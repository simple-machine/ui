with import <nixpkgs> {};
{ unstable ? import <nixos-unstable> { config.android_sdk.accept_license = true; } }:
let
  flutterPkgs = (import (builtins.fetchTarball  "https://github.com/NixOS/nixpkgs/archive/master.tar.gz")  {});
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
      # export ANDROID_HOME="${android-studio.unwrapped}"
    '';
  }

