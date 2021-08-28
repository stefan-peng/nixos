{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  
  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  # Set up networking
  networking = {
    hostName = "nixos";

    # Enables wireless support via networkmanager
    networkmanager = {
      enable = true;
    };
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "America/New_York";
  environment = {
    variables = {
      EDITOR = "vi";
      #GDK_SCALE = "2";
      #GDK_DPI_SCALE = "0.5";
      #QT_SCALE_FACTOR = "2";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      #_JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
    };

    # List packages installed in system profile.
    systemPackages = with pkgs; [
      # basic
      wget lsof vim

      # services
      light powertop networkmanagerapplet
    ];
  };

  # Wrapper for backlight. Must enable hardware.brightness.ctl and add
  # user to the "video" group as well.
  #programs.light.enable = true;

  programs.seahorse.enable = true;

  #powerManagement = {
  #  # run powertop --auto-tune on startup
  #  powertop.enable = true;
  #};

  # List services that you want to enable:
  services = {
    # automatically change xrandr profiles on display change
    autorandr.enable = true;

    # keyring
    gnome.gnome-keyring.enable = true;

    # bluetooth control
    #blueman.enable = true;

    # monitor and manage CPU temp, throttling as needed
    thermald.enable = true;

    # Enable dbus + dconf to manage system dialogs
    dbus = {
      packages = with pkgs; [ gnome3.dconf ];
    };

    # Remap what happens on power key press so it suspends rather than
    # shutting down immediately
    logind = {
      extraConfig = ''
        HandlePowerKey=suspend
      '';
    };

    # Enable the X11 windowing system
    xserver = {
      videoDrivers = [ "intel" ];
      deviceSection = ''
        Option "DRI" "3"
        Option "TearFree" "true"
      '';
      enable = true;
      autorun = true;
      # dpi = 192;

      # support external monitors via DisplayPort in addition to the
      # default screen eDP (use `xrandr` to list)
      # xrandrHeads = [ "eDP-1" "DisplayPort-0" ];

      desktopManager = {
        xterm.enable = false;
      };

      displayManager.defaultSession = "none+i3";

      displayManager.lightdm = {
        enable = true;
      };

      windowManager = {
        i3.enable = true;
      };

      # Enable touchpad support
      #libinput = {
      #  enable = true;
      #  touchpad.naturalScrolling = true;
      #};
    };
  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;

    fontconfig = {
      enable = true;
      antialias = true;
      useEmbeddedBitmaps = true;

      defaultFonts = {
        serif = [ "Source Serif Pro" "DejaVu Serif" ];
        sansSerif = [ "Source Sans Pro" "DejaVu Sans" ];
        monospace = [ "Fira Code" "Hasklig" ];
      };
    };

    fonts = with pkgs; [
      hasklig
      source-code-pro
      overpass
      nerdfonts
      fira
      fira-code
      fira-mono
    ];
  };

  # Hardware options
  sound.enable = true;
  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
    };

    #bluetooth.enable = true;
  };

  # Define a user account.
  users.extraUsers.stefan = {
    isNormalUser = true;
    group = "users";
    extraGroups = [ "wheel" "networkmanager" "video" ];
    createHome = true;
    uid = 1000;
  };

  # Allow unfree packages system-wide. To allow access to unfree packages
  # in nix-env, also set:
  #
  # ~/.config/nixpkgs/config.nix to { allowUnfree = true; }
  nixpkgs.config = {
    allowUnfree = true;
  };

  # don't change this
  system.stateVersion = "21.05";
}

