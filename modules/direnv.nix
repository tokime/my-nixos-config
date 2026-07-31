{ config, pkgs, ... }:

{
  # Включаем direnv и интеграцию с nix-direnv для кэширования
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;

    # Автоматическая интеграция с основными оболочками
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  environment.etc."direnv/direnv.toml".text = ''
    [global]
    hide_env_diff = true
  '';
}
