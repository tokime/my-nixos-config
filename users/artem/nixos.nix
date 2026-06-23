{ pkgs, ... }:

{
  users.users.artem = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "docker"
      "uinput"
      "adbusers"
    ];
    packages = with pkgs; [
      firefox
      chromium
      git
      tree-sitter
      telegram-desktop
      blender

      # Minecraft
      (
        (prismlauncher.override {
          jdks = [
            temurin-bin-17
            temurin-bin-21
            temurin-bin-25
          ];
        }).overrideAttrs
        (old: {
          qtWrapperArgs = old.qtWrapperArgs ++ [
            "--set"
            "GLFW_PLATFORM"
            "x11"
            "--set"
            "__GL_THREADED_OPTIMIZATIONS"
            "0"
          ];
        })
      )
    ];
  };
}
