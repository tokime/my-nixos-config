{ lib, pkgs, ... }:

{
  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;

    extraConfig.pipewire."10-audio-buffer" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [ 48000 ];
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 512;
        "default.clock.max-quantum" = 4096;
      };
    };

  };

  xdg.portal = {
    enable = true;
    extraPortals = lib.mkForce (
      with pkgs;
      [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ]
    );
    config.common = {
      default = [
        "gnome"
        "gtk"
      ];
      "org.freedesktop.impl.portal.ScreenCast" = "gnome";
      "org.freedesktop.impl.portal.Screenshot" = "gnome";
    };
  };

  programs.niri.enable = true;
  programs.dconf.enable = true;
  programs.kdeconnect.enable = true;
  hardware.uinput.enable = true;
  programs.zsh.enable = true;
  programs.xwayland.enable = true;
  users.defaultUserShell = pkgs.zsh;

  networking.firewall = {
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      }
    ];
  };

  environment.sessionVariables = {
    GLFW_PLATFORM = "x11";
    NIXOS_OZONE_WL = "1";
  };

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.theme = lib.mkForce "breeze";
}
