{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # services.power-profiles-daemon.enable = true;
  home-manager.backupFileExtension = "backup";
  services.gvfs.enable = true;

  # Set your time zone.
  time.timeZone = "America/Bogota";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Set Default Text Editor
  environment.variables.EDITOR = "nvim";

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Testing New Settings
  # GPU and OpenGL Configuration
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Testing New Settings
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
    };
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Add an allowlist for NVIDIA GPU usage
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:45:0:0"; # 2d:00.0 converted to PCI format
    };
  };

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  # CREATED LOOP OF SHELL LOADING AND COULD NOT EXIT

  programs.direnv.enable = true;
  programs.direnv.enableZshIntegration = true;

  # Hyprland Setup
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  services.xserver.enable = true;
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "Hyprland";
        user = "zacmagee";
      };
    };
  };
  programs.zsh = {
    enable = true;
  };

  boot = {
    # Enable systemd-boot as bootloader
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      # Reduce boot menu timeout for faster startup
      timeout = 1;
    };

    # Support for FUSE filesystems
    supportedFilesystems = ["fuse"];

    # Clean /tmp on boot to prevent accumulation of temporary files
    tmp.cleanOnBoot = true;

    # Kernel parameters for performance optimization
    kernelParams = [
      # Enable Intel P-state driver for better CPU frequency management
      "intel_pstate=active"
      # Optimize PCI Express Active State Power Management
      "pcie_aspm=performance"
      # Optimize GPU page attribute table
      # Added parameters for better interactivity
      "preempt=full"
      "transparent_hugepage=madvise"
    ];

    # Kernel sysctl parameters for system performance
    kernel.sysctl = {
      #   # Reduce swap tendency (0-100, lower means less swapping)
      "vm.swappiness" = 1;
      #   # Disable kernel debugging feature for better performance
      "kernel.nmi_watchdog" = 0;
      #   # Set percentage of total memory for dirty pages before forced write
      "vm.dirty_ratio" = 30;
      #   # Set percentage of total memory for dirty pages before background write
      "vm.dirty_background_ratio" = 5;
      #   # Reduce VFS pressure on inode caches
      "vm.vfs_cache_pressure" = 30;
      #   # Add for better I/O performance
      "vm.page_lock_unfairness" = 1;
    };
  };
  # Testing New Settings

  # Add systemd optimizations
  systemd = {
    extraConfig = ''
      DefaultTimeoutStopSec=15s
    '';
    user.extraConfig = ''
      DefaultTimeoutStopSec=15s
    '';
  };

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      connect-timeout = 60;
      stalled-download-timeout = 100;
      max-jobs = "auto";
      cores = 8; # Updated to match your CPU
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 4d";
    };
    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
  };

  # # Testing New Settings
  # # Add to your configuration
  # zramSwap = {
  #   enable = true;
  #   algorithm = "zstd";
  #   memoryPercent = 25; # Creates ~8GB ZRAM based on your 16GB RAM
  # };

  # Create a new group for backlight control
  users.groups.video-control = {};
  users.users.zacmagee = {
    isNormalUser = true;
    shell = pkgs.zsh;
    description = "Zac";
    extraGroups = ["networkmanager" "libvirtd" "wheel" "video" "input" "video-control"];
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # Base utilities
    alejandra
    nixd
    wget
    git
    unzip
    ripgrep
    zoxide
    xclip
    jq
    fd
    tree
    coreutils-full
    copyq
    blueman

    # Development tools
    gcc
    gnumake
    gnugrep
    rustc
    cargo
    nodejs
    nodePackages_latest.npm
    python312Packages.gpustat
    pkg-config
    glib.dev
    vala
    gobject-introspection
    neovim
    sqlite
    marksman
    atac
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.prettier
    nodePackages.eslint
    nodePackages.eslint_d # Faster ESLint daemon
    lazygit

    # Desktop environment and system tools
    dbus
    polkit
    mate.mate-polkit
    libheif
    accountsservice
    home-manager
    sumneko-lua-language-server
    rust-analyzer
    brave

    # Wayland/Hyprland core
    hyprland
    hyprpaper
    hyprpicker
    xdg-desktop-portal-hyprland
    wl-clipboard
    wl-clip-persist
    wlr-randr
    waybar
    hyprshot
    json-glib
    libdbusmenu-gtk3
    mesa

    # Theme and appearance (Adwaita)
    libadwaita
    nwg-look
    gradience
    swww
    pywal
    imagemagick
    adw-gtk3

    # Screenshot and image tools
    slurp
    gthumb

    # Audio/Video
    playerctl
    pamixer
    obs-studio
    wf-recorder

    # Notification and system tools
    swaynotificationcenter
    swayosd
    libnotify
    wlogout

    # Application launchers
    rofi-wayland

    # Network and Bluetooth
    networkmanagerapplet
    blueberry
    blueman

    # Theme and Qt/GTK configuration
    libsForQt5.qt5ct
    brightnessctl

    # Terminals and shells
    zsh-powerlevel10k
    eza
    bat
    fd

    # Applications
    appimage-run
    obsidian
    beeper
    syncthing
    scrcpy
    firefox
    thunderbird

    # Build tools
    meson
    ninja
    pkg-config
    openssl

    # System utilities
    xdg-utils
    gtk-layer-shell
    swaylock-effects
    swayidle
    clipse
    powertop
    stress-ng
    inotify-tools
    stow
    uwsm
    hyprlock

    # Multimedia
    mpv
    pavucontrol
    imv
    gimp
    # Testing Firefox settings
    ffmpeg
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    remmina
        freerdp

    # File compression
    zip
    p7zip
    nemo-with-extensions
    ffmpegthumbnailer
    xfce.thunar
    xfce.tumbler

    # System monitoring
    nitch
    glib
    cmake
    cairo
    atk
    libsoup
    gjs
    ags
  ];

  # # Testing New Settings
  # # Add early OOM killer
  # services.earlyoom = {
  #   enable = true;
  #   enableNotifications = true;
  # };

  services.syncthing = {
    enable = true;
    user = "zacmagee";
    dataDir = "/home/zacmagee/.config/syncthing";
    configDir = "/home/zacmagee/.config/syncthing";
    guiAddress = "127.0.0.1:8384";
  };

  # And the security configuration
  security.pam.services.hyprlock = {};
  security.pam.services.uwsm = {};

  # Enable Bluetooth
  services.blueman.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Testing  New Settings
  # services.thermald.enable = true;
  # services.auto-cpufreq = {
  #   enable = true;
  #   settings = {
  #     battery = {
  #       governor = "powersave";
  #       turbo = "auto";
  #     };
  #     charger = {
  #       governor = "performance";
  #       turbo = "auto";
  #     };
  #   };
  # };
  services.dbus.enable = true;
  services.openssh.enable = true;
  programs.ssh.startAgent = true;
  services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="leds", KERNEL=="*::kbd_backlight", RUN+="${pkgs.coreutils}/bin/chgrp video-control /sys/class/leds/%k/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w /sys/class/leds/%k/brightness"
      ACTION=="add|change", KERNEL=="sd[a-z]|nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]|nvme[0-9]n[0-9]", ATTR{queue/read_ahead_kb}="2048"
  '';
  environment.sessionVariables = {
    FLAKE = "/etc/nixos";
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    OBS_USE_EGL = "1";
    GI_TYPELIB_PATH = lib.concatStringsSep ":" [
      "/usr/lib/girepository-1.0"
      "/run/current-system/sw/lib/girepository-1.0"
      "${pkgs.libgtop}/lib/girepository-1.0"
      "${pkgs.gtk3}/lib/girepository-1.0"
      "${pkgs.gdk-pixbuf}/lib/girepository-1.0"
      "${pkgs.pango.out}/lib/girepository-1.0"
    ];
    LD_LIBRARY_PATH =
      lib.makeLibraryPath [
        pkgs.sqlite
      ]
      + ":/usr/lib:/run/current-system/sw/lib";
    NIX_CURL_FLAGS = "-k";
    GIT_SSL_CAINFO = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    GDK_BACKEND = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    WLR_DRM_NO_ATOMIC = "1";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    XCURSOR_SIZE = "24";
    LIBSEAT_BACKEND = "logind";
    WLR_RENDERER = "vulkan";
    # Testing New Settings
    # LIBGL_DRI3_DISABLE = "1";
    # __GL_THREADED_OPTIMIZATION = "1";
    __NV_PRIME_RENDER_OFFLOAD = "0";

    # Use the Intel driver explicitly
    LIBGL_DRIVER = "i965";
  };

  security.polkit.enable = true;
  security.sudo.enable = true;

  security.pki.certificateFiles = [
    "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
  ];
  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
      insertNameservers = ["8.8.8.8" "8.8.4.4" "1.1.1.1"];
      # Use lib.mkForce to override the default
      dns = lib.mkForce "none";
    };
    firewall = {
      allowedTCPPorts = [22];
      checkReversePath = "loose";
    };
    nameservers = ["8.8.8.8" "8.8.4.4" "1.1.1.1"];
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
    domains = ["~."];
    fallbackDns = ["8.8.8.8" "8.8.4.4" "1.1.1.1"];
    extraConfig = ''
      DNSStubListener=yes
      Cache=yes
      DNS=8.8.8.8 8.8.4.4 1.1.1.1
      Domains=~.
      DNSOverTLS=no
    '';
  };

  system.stateVersion = "24.05";
}
