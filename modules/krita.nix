{ inputs, pkgs, ... }:

let
  stablePkgs = inputs.nixpkgs-stable.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  environment.systemPackages = [
    stablePkgs.krita
  ];
}
