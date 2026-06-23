{ inputs, pkgs, ... }:

let
  minecraftCursorTheme = import ./minecraft-cursor.nix { inherit pkgs; };
in
{
  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    minecraftCursorTheme
    nano
    wget
    curl
    btop
    git
    ghostty
    wl-clipboard
    xwayland-satellite
    xwayland-run
    fuzzel
    waybar
    zsh
    neovim
    appimage-run
    gcc
    gnumake
    cargo
    rustc
    go
    nodejs
    bubblewrap
    nvtopPackages.full
    kitty
    libnotify
    obs-studio
    obsidian
    mpv
    satty
    zip
    unzip
    gamescope
    (llama-cpp.override { cudaSupport = true; })
  ];

  programs.nix-ld.enable = true;
}
