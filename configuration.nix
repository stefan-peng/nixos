# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Set up networking
  networking = {
    hostName = "nixos";

    networkmanager = {
      enable = true;
    };
  };

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

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
      wget lsof vim firefox

      # services
      light powertop networkmanagerapplet
    ];
  };

  # Wrapper for backlight. Must enable hardware.brightness.ctl and add
  # user to the "video" group as well.
  programs.light.enable = true;

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
    blueman.enable = true;

    # monitor and manage CPU temp, throttling as needed
    thermald.enable = true;

    # Enable dbus + dconf to manage system dialogs
    dbus = {
      packages = with pkgs; [ dconf ];
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

      layout = "us";
      xkbVariant = "";

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.stefanp = {
    isNormalUser = true;
    description = "Stefan Peng";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages system-wide. To allow access to unfree packages
  # in nix-env, also set:
  #
  # ~/.config/nixpkgs/config.nix to { allowUnfree = true; }
  nixpkgs.config = {
    allowUnfree = true;
  };

  # don't change this
  system.stateVersion = "22.05";
}

