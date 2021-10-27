{ config, pkgs, lib, ... }:

let
  bg-path = "~/Pictures/background.jpg";

  pulseaudio = pkgs.pulseaudioFull;

  # Spotify is terrible on hidpi screens (retina, 4k); this small wrapper
  # passes a command-line flag to force better scaling.
  spotify-4k = pkgs.symlinkJoin {
    name = "spotify";
    paths = [ pkgs.spotify ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/spotify \
        --add-flags "--force-device-scale-factor=1.8"
    '';
  };

in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages which ought to be available for this user
  home.packages = with pkgs; [
    # system
    feh playerctl

    # nix utilities
    nix-prefetch-git

    # i3
    dmenu
    xorg.xkbcomp
    rofi

    # sway
    # swaylock
    # swayidle
    # wl-clipboard
    # mako

    # command line
    htop
    ranger
    zathura
    xclip
    tree
    youtube-dl
    mpv
    fzf
    streamlink

    # applications
    arandr
    firefox
    google-chrome
    spotify
    slack
    anki
    kitty
    syncthing
    discord
    mendeley
    obsidian
    epiphany
    libreoffice-qt
    qutebrowser
    gnome3.gnome-keyring
    bitwarden
    mpv
    pavucontrol
    hakuneko
    nyxt
  ];

  home.sessionVariables = {
    #GDK_CORE_DEVICE_EVENTS = "";
    XCURSOR_SIZE = "16";
    MOZ_USE_XINPUT2 = 1;
  };

  home.keyboard = {
    options = [
      "ctrl:nocaps" # remap caps to ctrl
    ];
  };

  gtk = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Stefan Peng";
    userEmail = "sp8@fastmail.com";
    extraConfig = {
      core.editor = "vim";
      github.username = "stefan-peng";
    };
    aliases = {
      l = "log --graph --pretty='%Cred%h%Creset - %C(bold blue)<%an>%Creset %s%C(yellow)%d%Creset %Cgreen(%cr)' --abbrev-commit --date=relative";
      co = "checkout";
      br = "branch";
      ci = "commit";
      st = "status";
      last = "log -l HEAD";
    };
  };

  programs.bat = {
    enable = true;
  };

  programs.lsd = {
    enable = true;

    # ls, ll, la, lt ...
    enableAliases = true;
  };

  programs.vim = {
    enable = true;

    # to see available plugins:
    # nix-env -f '<nixpkgs>' -qaP -A vimPlugins
    plugins = with pkgs.vimPlugins;
      [
        # Writing
        goyo          # distraction-free writing; toggle with :Goyo
        vim-pencil    # better word-wrapping, markdown, etc.
        limelight-vim # highlight only current paragraph

        # Languages
        vim-nix

        # Syntax checking / status
        syntastic
      ];

    extraConfig = ''
      " no tabs
      set tabstop=4 softtabstop=0 expandtab shiftwidth=2 smarttab

      " nerdtree-esque with netrw
      let g:netrw_banner=0
      let g:netrw_winsize=20
      let g:netrw_liststyle=3
      let g:netrw_localrmdir='rm -r'
      nnoremap <leader>nt :Lexplore<CR>

      " syntastic
      let g:syntastic_always_populate_loc_list = 1
      let g:syntastic_auto_loc_list = 1
      let g:syntastic_check_on_wq = 0

      " set up writing environment when goyo starts
      function! s:goyo_enter()
        set noshowmode
        set noshowcmd
        Limelight  " start limelight
        SoftPencil " start pencil with soft wrap
      endfunction

      " clear writing environment when goyo exits
      function! s:goyo_leave()
        set showmode
        set showcmd
        Limelight! " quit limelight
        NoPencil   " quit pencil
      endfunction

      autocmd! User GoyoEnter nested call <SID>goyo_enter()
      autocmd! User GoyoLeave nested call <SID>goyo_leave()

      " set limelight colors
      let g:limelight_conceal_ctermfg = 'DarkGray'
    '';
  };

  programs.bash = {
    enable = true;

    shellAliases = {
      cat = "bat";
      firefox = "env -uGDK_CORE_DEVICE_EVENTS MOZ_USE_XINPUT2=1 firefox";
    };

    shellOptions = [
      # defaults
      "histappend"
      "checkwinsize"
      "extglob"
      "globstar"
      "checkjobs"

      # save multi-line commands as single entries
      "cmdhist"
    ];

    initExtra = ''
      eval "$(${pkgs.direnv}/bin/direnv hook bash)"
    '';
  };

  # tmux
  programs.tmux = {
    enable = true;
    keyMode = "vi";
  };

  programs.alacritty = {
    enable = true;
  };

  # kitty
  xdg.configFile."kitty/kitty.conf".text = ''
    font_size 12.0

    # https://github.com/arcticicestudio/nord-termite/
    cursor #d8dee9
    foreground #d8dee9
    background #2e3440
    color0 #3b4252
    color1 #bf616a
    color2 #a3be8c
    color3 #ebcb8b
    color4 #81a1c1
    color5 #b48ead
    color6 #88c0d0
    color7 #e5e9f0
    color8 #4c566a
    color9 #bf616a
    color10 #a3be8c
    color11 #ebcb8b
    color12 #81a1c1
    color13 #b48ead
    color14 #8fbcbb
    color15 #eceff4
  '';

  programs.htop = {
    enable = true;
  };

  programs.ssh = {
    enable = true;
  };

  programs.vscode = {
    enable = true;

    # Overrides manually-installed extensions, but there are almost none in
    # nixpkgs as of 2020-01-01
    extensions = with pkgs.vscode-extensions; [
      # Nix language support
      bbenoist.Nix

      # Vim bindings
      vscodevim.vim
    ]

    # To fetch the SHA256, use `nix-prefetch-url` with this template:
    #
    #   https://<publisher>.gallery.vsassets.io/_apis/public/gallery/publisher/<publisher>/extension/<name>/<version>/assetbyname/Microsoft.VisualStudio.Services.VSIXPackage

    ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [

      # The Nord color scheme
      {
        name = "nord-visual-studio-code";
        publisher = "arcticicestudio";
        version = "0.13.0";
        sha256 = "15c1gcw00lssq1qiqmkxapw2acgnlixy055wh5pgq68brm6fwdq6";
      }

    ];

    # vscode settings.json is made read-only and controlled via this section; editing settings
    # in the ui will reveal what to copy over here.
    userSettings = {
      # editor settings
      "editor.formatOnSave" = false;
      "editor.minimap.enabled" = false;
      "editor.fontSize" = 14;
      "editor.lineHeight" = 24;
      "editor.fontFamily" = "Hasklig, Overpass Mono, monospace";
      "editor.fontLigatures" = true;
      "editor.tabSize" = 2;
      "editor.rulers" = [80 100];

      # theme
      "workbench.colorTheme" = "Nord";
      "editor.tokenColorCustomizations" = {
        "[Nord]" = {
          "textMateRules" = [
            {
              "scope" = [ "entity.name.type.purescript" ];
              "settings" = {
                "foreground" = "#88C0D0";
              };
            }
          ];
        };
      };

      # misc
      "files.trimTrailingWhitespace" = true;
      "workbench.activityBar.visible" = false;
      "breadcrumbs.enabled" = true;
      "git.autofetch" = true;
      "window.zoomLevel" = 0;
      "css.validate" = false;
      "scss.validate" = false;
      "less.validate" = false;
      "files.associations" = {
        "*.css" = "scss";
        "*.js" = "javascript";
      };
    };
  };

  # services.blueman-applet.enable = true;

  services.redshift = {
    enable = true;
    latitude = "39.1732";
   longitude = "-77.2717";
  };

  services.syncthing = {
    enable = true;
  };

  services.unclutter = {
    enable = true;
  };

  services.picom = {
    enable = true;
    activeOpacity = "0.90";
    blur = true;
    blurExclude = [
      "class_g = 'slop'"
    ];
    extraOptions = ''
      corner-radius = 10;
      blur-method = "dual_kawase";
      blur-strength = "10";
      xinerama-shadow-crop = true;
    '';
    experimentalBackends = true;

    shadowExclude = [
      "bounding_shaped && !rounded_corners"
    ];

    fade = true;
    fadeDelta = 5;
    vSync = true;
    opacityRule = [
      "100:class_g   *?= 'Chromium-browser'"
      "100:class_g   *?= 'google-chrome'"
      "100:class_g   *?= 'Firefox'"
      "100:class_g   *?= 'gitkraken'"
      "100:class_g   *?= 'emacs'"
      "100:class_g   ~=  'jetbrains'"
      "100:class_g   *?= 'slack'"
    ];
    package = pkgs.picom.overrideAttrs(o: {
      src = pkgs.fetchFromGitHub {
        repo = "picom";
        owner = "ibhagwan";
        rev = "44b4970f70d6b23759a61a2b94d9bfb4351b41b1";
        sha256 = "0iff4bwpc00xbjad0m000midslgx12aihs33mdvfckr75r114ylh";
      };
    });
  };

  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
    };
    extraConfig =
    let
      white = "#ECEFF4";
      gray = "#65737E";
      black = "#232423";
      blue = "#88C0D0";
      yellow = "#EBCB8B";
      orange = "#D08770";
      red = "#BF616A";
      green = "#A3BE8C";
      magenta = "#B48EAD";
      background = "#802E3440";

      overpass = "Overpass Mono:pixelsize=14;2";
      monofur = "Monofur Nerd Font:pixelsize=14;2";
    in
    # inspired by /ossix/dotfiles/dark-forest
    ''
    [global/wm]
    margin-top = 0
    margin-bottom = 0

    # Settings
    [settings]
    screenchange-reload = true

    #
    # Bars
    #

    [bar/top]
    dpi = 96
    radius = 0.0
    fixed-center = true
    bottom = false
    height = 20
    padding-left = 3
    padding-right = 4
    background = ${background}
    foreground = ${white}
    module-margin = 1
    underline-size = 1
    border-bottom-size = 2
    border-color = ${gray}
    separator = " "

    font-0 = "TerminessTTF Nerd Font:size=12;2"
    font-1 = Font Awesome 5 Free:style=Regular:pixelsize=12;2
    font-2 = Font Awesome 5 Free:style=Solid:pixelsize=12;2
    font-3 = Font Awesome 5 Brands:pixelsize=12;2
    font-4 = "TerminessTTF Nerd Font:style=Bold:size=12;2"
    font-5 = FontAwesome:size=12;2
    font-6 = fontawesome:size=12;2

    enable-ipc = true

    #modules-right = cpu memory battery0 battery1 pulseaudio
    modules-right = cpu memory pulseaudio
    modules-center = date
    modules-left = i3 xwindow

    #
    # Modules
    #

    [module/cpu]
    type = internal/cpu
    interval = 0.5

    format-prefix = 
    format = <label> <ramp-coreload>

    label = %{A1:termite --exec=htop & disown:}%percentage:3%%%{A}

    ramp-coreload-0 = ▁
    ramp-coreload-1 = ▂
    ramp-coreload-2 = ▃
    ramp-coreload-3 = ▄
    ramp-coreload-4 = ▅
    ramp-coreload-5 = ▆
    ramp-coreload-6 = ▇
    ramp-coreload-7 = █
    ramp-coreload-0-foreground = ${gray}
    ramp-coreload-1-foreground = ${green}
    ramp-coreload-2-foreground = ${green}
    ramp-coreload-3-foreground = ${yellow}
    ramp-coreload-4-foreground = ${yellow}
    ramp-coreload-5-foreground = ${orange}
    ramp-coreload-6-foreground = ${orange}
    ramp-coreload-7-foreground = ${red}


    [module/memory]
    type = internal/memory
    interval = 0.2
    format-prefix = 
    format = <label> <ramp-used>
    label = %{A1:termite --exec=htop & disown:}%percentage_used:3%%%{A}

    ramp-used-0 = ▁
    ramp-used-1 = ▂
    ramp-used-2 = ▃
    ramp-used-3 = ▄
    ramp-used-4 = ▅
    ramp-used-5 = ▆
    ramp-used-6 = ▇
    ramp-used-7 = █
    ramp-used-0-foreground = ${gray}
    ramp-used-1-foreground = ${green}
    ramp-used-2-foreground = ${green}
    ramp-used-3-foreground = ${yellow}
    ramp-used-4-foreground = ${yellow}
    ramp-used-5-foreground = ${orange}
    ramp-used-6-foreground = ${orange}
    ramp-used-7-foreground = ${red}


    [module/battery0]
    type = internal/battery
    battery = BAT0
    adapter = ADP1
    full-at = 100
    interval = 1

    format-charging-prefix = 
    format-charging = <label-charging>
    label-charging = %percentage:3%%

    format-discharging = <ramp-capacity> <label-discharging>
    label-discharging = %percentage:3%%

    format-full-prefix = 
    format-full = <label-full>
    label-full = %percentage:3%%

    ramp-capacity-0 = 
    ramp-capacity-0-font = 5
    ramp-capacity-1 = 
    ramp-capacity-1-font = 5
    ramp-capacity-2 = 
    ramp-capacity-2-font = 5
    ramp-capacity-3 = 
    ramp-capacity-3-font = 5
    ramp-capacity-4 = 
    ramp-capacity-4-font = 5
    ramp-capacity-0-foreground = ${red}
    ramp-capacity-1-foreground = ${orange}
    ramp-capacity-2-foreground = ${yellow}
    ramp-capacity-foreground = ${white}

    [module/battery1]
    type = internal/battery
    battery = BAT1
    adapter = ADP1
    full-at = 100
    interval = 1

    format-charging-prefix = 
    format-charging = <label-charging>
    label-charging = %percentage:3%%

    format-discharging = <ramp-capacity> <label-discharging>
    label-discharging = %percentage:3%%

    format-full-prefix = 
    format-full = <label-full>
    label-full = %percentage:3%%

    ramp-capacity-0 = 
    ramp-capacity-0-font = 5
    ramp-capacity-1 = 
    ramp-capacity-1-font = 5
    ramp-capacity-2 = 
    ramp-capacity-2-font = 5
    ramp-capacity-3 = 
    ramp-capacity-3-font = 5
    ramp-capacity-4 = 
    ramp-capacity-4-font = 5
    ramp-capacity-0-foreground = ${red}
    ramp-capacity-1-foreground = ${orange}
    ramp-capacity-2-foreground = ${yellow}
    ramp-capacity-foreground = ${white}

    [module/pulseaudio]
    type = internal/pulseaudio
    sink = alsa_output.pci-0000_00_1f.3.analog-stereo
    use-ui-max = false

    format-volume = <ramp-volume> <label-volume>
    label-volume = %percentage:3%%
    label-volume-foreground = ${white}

    format-muted-prefix = 
    format-muted-foreground = ${gray}
    label-muted = %percentage:3%%

    ramp-volume-0 = 
    ramp-volume-0-foreground = ${gray}
    ramp-volume-1 = 
    ramp-volume-1-foreground = ${yellow}
    ramp-volume-2 = 
    ramp-volume-2-foreground = ${orange}
    ramp-volume-3 = 
    ramp-volume-3-foreground = ${red}


    [module/date]
    type = internal/date
    date-alt = "%a - %m/%d"
    date = "%H:%M"
    interval = 1
    format-padding = 1
    format-background = ${gray}


    [module/i3]
    type = internal/i3
    format = <label-state>
    index-sort = true
    wrapping-scroll = false
    format-padding-right = 1

    label-focused = %name%
    label-focused-background = ${gray}
    label-focused-foreground = ${white}
    label-focused-overline  = ${gray}
    label-focused-padding = 2
    label-focused-font = 5

    label-unfocused = %name%
    label-unfocused-padding = 1
    label-unfocused-foreground = ${gray}
    label-unfocused-overline = ${background}

    label-occupied = %name%
    label-occupied-padding = 1

    label-urgent = 
    label-urgent-background = ${red}
    label-urgent-overline  = ${red}
    label-urgent-padding = 2

    label-empty = %name%
    label-empty-foreground = ${gray}
    label-empty-overline = ${background}
    label-empty-padding = 1

    label-visible = %name%
    label-visible-overline = ${background}
    label-visible-padding = 2


    [module/xwindow]
    type = internal/xwindow
    label =   %title:0:40:...%
    label-empty = root-window
    label-empty-foreground = ${yellow}
    label-background = ${gray}
    label-padding = 1
    click-left = skippy-xd
    click-right = skippy-xd
    '';

    # necessary to include i3 path to start correctly
    script = ''
      PATH=$PATH:${pkgs.i3}/bin polybar top &
    '';
  };

  xresources = {
    extraConfig =
      builtins.readFile (
        # nix-prefetch-git
        pkgs.fetchFromGitHub {
          owner = "arcticicestudio";
          repo = "nord-xresources";
          rev = "5a409ca2b4070d08e764a878ddccd7e1584f0096";
          sha256 = "1b775ilsxxkrvh4z8f978f26sdrih7g8w2pb86zfww8pnaaz403m";
        } + "/src/nord"
      );
  };

  xsession = {
    enable = true;

    # i3 configuration
    windowManager.i3 = let modifier = "Mod4"; in {
      enable = true;

      config = {
        modifier = "${modifier}";

        bars = [ ];

        keybindings =
        lib.mkOptionDefault {
          "${modifier}+Return" = "exec kitty";
          "${modifier}+BackSpace" = "kill";
          "${modifier}+f" = "fullscreen toggle";
          #"${modifier}+backslash" = "exec env -u GDK_CORE_DEVICE_EVENTS MOZ_USE_XINPUT2=1 firefox";
          #"${modifier}+backslash" = "exec qutebrowser";
          "${modifier}+backslash" = "exec google-chrome-stable --use-gl=desktop --enable-features=VaapiVideoDecoder";
          "${modifier}+x" = "exec i3lock";

          # TODO: fix multiple sinks
          "XF86AudioRaiseVolume" = "exec ${pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86AudioLowerVolume" = "exec ${pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86AudioMute" = "exec ${pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" = "exec ${pulseaudio}/bin/pactl set-source-mute 1 toggle";


          "XF86MonBrightnessUp" = "exec light -A 10%";
          "XF86MonBrightnessDown" = "exec light -U 10%";

          "XF86AudioPrev" = "exec ${pkgs.playerctl}/bin/playerctl previous";
          "XF86AudioPause" = "exec ${pkgs.playerctl}/bin/playerctl play-pause";
          "XF86AudioNext" = "exec ${pkgs.playerctl}/bin/playerctl next";
        };

        # ensure these commands are run when i3 is restarted
        startup = [
          { command = "${pkgs.feh}/bin/feh --bg-fill ${bg-path}";
            always = true;
            notification = false;
          }
          { command = "systemctl --user restart polybar";
            always = true;
            notification = false;
          }
          { command = "setxkbmap -option 'ctrl:nocaps'";
            always = true;
            notification = false;
          }
          { command = "xrandr --output HDMI1 --mode 1920x1080 --rate 75";
            always = true;
            notification = false;
          }
        ];

      };

    extraConfig = ''
      default_border pixel 1
      hide_edge_borders smart
    '';
    };
  };

  # wayland.windowManager.sway = {
  #   enable = true;
  #   wrapperFeatures.gtk = true ;
  # };
}
