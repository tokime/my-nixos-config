{ config, inputs, pkgs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "artem";
  home.homeDirectory = "/home/artem";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    calf
    dysk
    easyeffects
    lsp-plugins
    rnnoise-plugin
    zam-plugins
    ripgrep

    # WebRTC
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad

    adw-gtk3
    kdePackages.breeze-icons
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  xdg.configFile."kxkbrc".text = ''
    [Layout]
    DisplayNames=,
    LayoutList=us,ru
    Model=pc105
    Options=grp:win_space_toggle
    ResetOldOptions=true
    Use=true
    VariantList=,
  '';

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/artem/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "16";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.noctalia.enable = true;

  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      screenshots = true;
      effect-blur = "7x5";
      effect-scale = 0.5;
      indicator-caps-lock = true;
      color = "000000aa";
      font-size = 24;

      ring-color = "2e3440";
      ring-ver-color = "88c0d0";
      ring-wrong-color = "bf616a";
      ring-clear-color = "ebcb8b";
      ring-capslock-color = "d08770";

      key-hl-color = "88c0d0";
      bs-hl-color = "bf616a";

      text-color = "eceff4";
      text-ver-color = "88c0d0";
      text-wrong-color = "bf616a";
      text-clear-color = "ebcb8b";
      text-capslock-color = "d08770";

      line-color = "00000000";
      separator-color = "00000000";

      inside-color = "2e3440cc";
      inside-ver-color = "2e3440cc";
      inside-wrong-color = "2e3440cc";
      inside-clear-color = "2e3440cc";
      inside-capslock-color = "2e3440cc";

      indicator-radius = 120;
      indicator-thickness = 10;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
      icon-theme = "Adwaita";
    };
  };

  gtk = {
    enable = true;
    gtk2.enable = false;
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;

  qt = {
    enable = true;
    platformTheme.name = "kde";
    style = {
      package = pkgs.kdePackages.breeze;
      name = "breeze";
    };
  };

  xdg.configFile."kdeglobals".text = ''
    [General]
    ColorScheme=BreezeDark
    Name=Breeze Dark
    XftAntialias=true
    XftHintStyle=hintslight
    XftSubPixel=rgb

    [Icons]
    Theme=breeze-dark

    [KDE]
    LookAndFeelPackage=org.kde.breezedark.desktop
  '';
  xdg.configFile."kdeglobals".force = true;

  xdg.configFile."xdg-desktop-portal/portals.conf".text = ''
    [preferred]
    default=gnome;gtk;
    org.freedesktop.impl.portal.Settings=gnome;
  '';

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 16;
  };
}
