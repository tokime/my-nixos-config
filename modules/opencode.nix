{ config, pkgs, ... }:

let
  ohMyOpencode = pkgs.writeShellScriptBin "oh-my-opencode" ''
    exec ${pkgs.bun}/bin/bunx oh-my-opencode-slim@latest "$@"
  '';

  omoShortcut = pkgs.writeShellScriptBin "omo" ''
    exec ${pkgs.bun}/bin/bunx oh-my-opencode-slim@latest "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    opencode
    bun
    tmux
    ohMyOpencode
    omoShortcut
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      glibc
      openssl
    ];
  };

  environment.variables = {
    OMO_TMUX_AUTO = "yes";
    OMO_SKILLS_AUTO = "yes";
  };
}
