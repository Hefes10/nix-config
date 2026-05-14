{ inputs, outputs, config, lib, hostname, system, username, pkgs, ... }:
let
  inherit (inputs) nixpkgs-darwin;
in
{
  users.users.hefes.home = "/Users/hefes";

  nix = {
    enable = false;  # Disable nix-darwin Nix management for Determinate Nix compatibility
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
    channel.enable = false;
  };
  system.stateVersion = 5;

  # Set primary user for system-wide activation
  system.primaryUser = "hefes";

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = lib.mkDefault "${system}";
  };

  environment.systemPackages = with pkgs; [
    yt-dlp
    get_iplayer

    pkgs.comma
    pkgs.hcloud
    pkgs.just
    pkgs.lima
    pkgs.nix
  ];

  fonts.packages = [
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.fira-mono
    pkgs.nerd-fonts.hack
    pkgs.nerd-fonts.jetbrains-mono
  ];

  # pins to nixpkgs-darwin (unstable) so 'nix run nixpkgs#foo' uses our pinned version
  nix.registry = {
    n.to = {
      type = "path";
      path = inputs.nixpkgs-darwin;
    };
  };

  programs.nix-index.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    promptInit = builtins.readFile ./../../data/mac-dot-zshrc;
  };

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
    global.autoUpdate = true;

    brews = [
      # vacío - todo movido a casks o nix
    ];
    taps = [
    ];
    casks = [
      ## Terminales
      "ghostty"
      "warp"
      #"alacritty"
      #"iterm2"

      ## Comunicación
      "discord"
      "spotify"
      #"signal"
      #"slack"

      ## Productividad
      "claude"             # Anthropic desktop app
      "claude-code"        # Anthropic CLI
      "evernote"
      "marta"              # file manager
      "notion"
      "raycast"
      "visual-studio-code"
      #"firefox"
      #"obsidian"

      ## Multimedia
      "audacity"
      "iina"
      "obs"                # grabación de pantalla
      "openscad"           # CAD 3D
      "vlc"
      #"cleanshot"
      #"flameshot"
      #"screenflow"

      ## Sistema / utilidades
      "bitwarden-cli"      # password manager CLI
      "istat-menus"
      "omnidisksweeper"
      #"alcove"
      #"jordanbaird-ice"
      #"popclip"
      #"shortcat"

      ## Dev / containers / networking
      "docker"
      "orbstack"
      "surfshark"          # VPN
      "tailscale-app"
      #"viscosity"         # alternativa OpenVPN

      ## Office (descomentar si lo necesito)
      #"libreoffice"

      ## Fuentes (redundantes con fonts.packages de Nix)
      #"font-fira-code"
      #"font-fira-code-nerd-font"
      #"font-fira-mono-for-powerline"
      #"font-hack-nerd-font"
      #"font-jetbrains-mono-nerd-font"
      #"font-meslo-lg-nerd-font"

      ## Apps comentadas (no usadas actualmente)
      #"adobe-creative-cloud"
      #"audio-hijack"
      #"bambu-studio"
      #"bentobox"
      #"displaylink"
      #"element"
      #"elgato-camera-hub"
      #"elgato-control-center"
      #"elgato-stream-deck"
      #"farrago"
      #"google-chrome"
      #"lm-studio"
      #"logitech-options"
      #"loopback"
      #"macwhisper"
      #"mqtt-explorer"
      #"music-decoy"
      #"nextcloud"
      #"ollama"
      #"openttd"
      #"plexamp"
      #"prusaslicer"
      #"soundsource"
      #"steam"
      #"wireshark"
    ];
    masApps = {
      "WhatsApp" = 310633997;
      "Telegram" = 747648890;

      ## Comentados - descomentar para instalar
      #"Pages" = 409201541;
      #"Keynote" = 409183694;
      #"Numbers" = 409203825;
      #"Home Assistant Companion" = 1099568401;
      "Windows App" = 1295203466;
      #"Perplexity" = 6714467650;
      #"Snippety" = 1530751461;
      #"The Unarchiver" = 425424353;
      #"UTM" = 1538878817;
    };
  };

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = false;

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # macOS configuration
  system.defaults = {
    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleShowScrollBars = "Always";
    NSGlobalDomain.NSUseAnimatedFocusRing = false;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
    NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
    NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
    NSGlobalDomain.PMPrintingExpandedStateForPrint2 = true;
    NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain.InitialKeyRepeat = 25;
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
    NSGlobalDomain.NSWindowShouldDragOnGesture = true;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
    LaunchServices.LSQuarantine = false; # disables "Are you sure?" for new apps
    loginwindow.GuestEnabled = false;
    finder.FXPreferredViewStyle = "Nlsv";
  };

  system.defaults.CustomUserPreferences = {
      "com.apple.finder" = {
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = false;
        ShowMountedServersOnDesktop = false;
        ShowRemovableMediaOnDesktop = true;
        _FXSortFoldersFirst = true;
        FXDefaultSearchScope = "SCcf";
        DisableAllAnimations = true;
        NewWindowTarget = "PfDe";
        NewWindowTargetPath = "file://$\{HOME\}/Desktop/";
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        ShowStatusBar = true;
        ShowPathbar = true;
        WarnOnEmptyTrash = false;
      };
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      "com.apple.dock" = {
        autohide = false;
        launchanim = false;
        static-only = false;
        show-recents = false;
        show-process-indicators = true;
        orientation = "bottom";
        tilesize = 36;
        minimize-to-application = true;
        mineffect = "scale";
        enable-window-tool = false;
      };
      "com.apple.ActivityMonitor" = {
        OpenMainWindow = true;
        IconType = 5;
        SortColumn = "CPUUsage";
        SortDirection = 0;
      };
      "com.apple.AdLib" = {
        allowApplePersonalizedAdvertising = false;
      };
      "com.apple.SoftwareUpdate" = {
        AutomaticCheckEnabled = true;
        ScheduleFrequency = 1;
        AutomaticDownload = 1;
        CriticalUpdateInstall = 1;
      };
      "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
      "com.apple.ImageCapture".disableHotPlug = true;
      "com.apple.commerce".AutoUpdate = true;
      "com.googlecode.iterm2".PromptOnQuit = false;
      "com.google.Chrome" = {
        AppleEnableSwipeNavigateWithScrolls = true;
        DisablePrintPreview = true;
        PMPrintingExpandedStateForPrint2 = true;
      };
  };

}
