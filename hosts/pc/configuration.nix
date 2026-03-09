{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Basic system
  networking.hostName = "pc";
  time.timeZone = "Asia/Almaty";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:alt_shift_toggle";
  };

  console.keyMap = "us";

  # Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # Bootloader
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    default = "saved";
    useOSProber = true;
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."cryptroot".allowDiscards = true;

  # Networking
  networking.networkmanager.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  # Users
  users.users.user = {
    isNormalUser = true;
    description = "user";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    packages = [ ];
  };

  # Base packages
  environment.systemPackages = with pkgs; [
    git
    vim
    ripgrep
    htop
    go
    gcc
    pciutils
    ghostty
    hyprlock
    wofi
    firefox
    google-chrome
    hysteria
    bun
    nodejs
    telegram-desktop
    pkgs."teamspeak6-client"
    wl-clipboard
    blueman
    pavucontrol
  ];

  # Fonts (Waybar icons)
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    font-awesome
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
  ];
  fonts.fontconfig.defaultFonts = {
    sansSerif = [ "Noto Sans" "Symbols Nerd Font" "Font Awesome 6 Free" ];
    monospace = [ "DejaVu Sans Mono" "Symbols Nerd Font Mono" ];
    emoji = [ "Noto Color Emoji" ];
  };

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 128;
        "default.clock.min-quantum" = 64;
        "default.clock.max-quantum" = 256;
      };
    };
  };

  # Hysteria client (autostart)
  # Keep real config with secrets at: /persist/secrets/hysteria/client.yaml
  systemd.services.hysteria-client = {
    description = "Hysteria2 client";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    unitConfig = {
      ConditionPathExists = "/persist/secrets/hysteria/client.yaml";
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hysteria}/bin/hysteria client -c /persist/secrets/hysteria/client.yaml";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  # Hyprland (Wayland)
  programs.hyprland.enable = true;
  programs.dconf.enable = true;
  programs.xfconf.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
    ];
  };
  services.xserver.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd /run/current-system/sw/bin/start-hyprland";
        user = "greeter";
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };
  services.gvfs.enable = true;
  services.tumbler.enable = true;
  services.udisks2.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    TERMINAL = "ghostty";
  };
  environment.shellAliases = {
    ls = "ls -a";
  };

  # Gaming
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  programs.gamemode.enable = true;

  # Nvidia (hybrid Intel iGPU + Nvidia dGPU)
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    nvidiaSettings = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.latest;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Btrfs maintenance
  services.btrfs.autoScrub.enable = true;

  # Hibernate (swapfile) TODO:
  # - Create a swapfile at /swap/swapfile (inside Btrfs, CoW disabled)
  # - Set boot.resumeDevice to the Btrfs filesystem UUID
  # - Add resume_offset for the swapfile
  # Example (fill placeholders):
  # swapDevices = [ { device = "/swap/swapfile"; } ];
  # boot.resumeDevice = "/dev/disk/by-uuid/<BTRFS_UUID>";
  # boot.kernelParams = [ "resume_offset=<OFFSET>" ];

  # IMPORTANT: set this to the NixOS release you install.
  system.stateVersion = "25.11";
}
