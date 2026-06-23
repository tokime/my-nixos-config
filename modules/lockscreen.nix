{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    swaylock-effects
  ];
}
