{ pkgs, ... }:

{
  home.username = "user";
  home.homeDirectory = "/home/user";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "rakhimgaliyev";
        email = "rakhimgaliev56@gmail.com";
      };
      credential.helper = "store";
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = false;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        jnoortheen.nix-ide
        golang.go
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
      ];
      userSettings = {
        "editor.formatOnSave" = true;
        "editor.tabSize" = 2;
        "files.autoSave" = "afterDelay";
        "files.autoSaveDelay" = 1000;
        "terminal.integrated.defaultProfile.linux" = "zsh";
      };
    };
  };

  home.packages = with pkgs; [
    waybar
    wallpaper-runner
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    TERMINAL = "ghostty";
    GTK_THEME = "Adwaita:dark";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "36";
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 36;
    gtk.enable = true;
    x11.enable = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Adwaita-dark";
      cursor-theme = "Bibata-Modern-Ice";
      cursor-size = 36;
    };
  };

  xdg.configFile."hypr/hyprland.conf".source = ../configs/hypr/hyprland.conf;
  xdg.configFile."ghostty/config".source = ../configs/ghostty/config;
  xdg.configFile."ghostty/gtk.css".source = ../configs/ghostty/gtk.css;
  xdg.configFile."wofi/config".source = ../configs/wofi/config;
  xdg.configFile."wofi/style.css".source = ../configs/wofi/style.css;
  xdg.configFile."waybar/config".source = ../configs/waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source = ../configs/waybar/style.css;
  xdg.configFile."waybar/scripts/network-status.sh" = {
    source = ../configs/waybar/scripts/network-status.sh;
    executable = true;
  };
  xdg.configFile."waybar/scripts/bluetooth-status.sh" = {
    source = ../configs/waybar/scripts/bluetooth-status.sh;
    executable = true;
  };
  xdg.configFile."waybar/scripts/open-audio.sh" = {
    source = ../configs/waybar/scripts/open-audio.sh;
    executable = true;
  };
  xdg.configFile."waybar/scripts/open-bluetooth.sh" = {
    source = ../configs/waybar/scripts/open-bluetooth.sh;
    executable = true;
  };
  home.file.".local/bin/mac-capture" = {
    source = ../scripts/mac-capture.sh;
    executable = true;
  };
  xdg.configFile."wallpapers".source = ../assets/wallpapers;
  home.file.".local/share/Steam/steamapps/common/Counter-Strike Global Offensive/game/csgo/cfg/autoexec.cfg".source =
    ../configs/cs2/autoexec.cfg;
}
