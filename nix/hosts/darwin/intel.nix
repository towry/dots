#
#  Specific system configuration settings for MacBook 8,1
#
#  flake.nix
#   └─ ./darwin
#       ├─ default.nix
#       └─ ./intel.nix *
#
{pkgs, ...}: {
  networking = {
    computerName = "towryDeMacbook";
    hostName = "towryDeMacbook";
  };

  homebrew = {
    brews = [
    ];
    casks = [
    ];
  };

  system = {
    defaults = {
      NSGlobalDomain = {
        KeyRepeat = 1;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      dock = {
        autohide = false;
        largesize = 36;
        tilesize = 24;
        magnification = true;
        mineffect = "genie";
        orientation = "bottom";
        showhidden = false;
        show-recents = false;
        minimize-to-application = true;
      };
      finder = {
        AppleShowAllFiles = false;
        ShowPathbar = true;
        QuitMenuItem = false;
      };
      # keyboard = {
      #   remapCapsLockToEscape = true;
      # };
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };
      magicmouse = {
        MouseButtonMode = "TwoButton";
      };
      # CustomUserPreferences = {
      # # ~/Library/Preferences/
      # }
      # CustomSystemPreferences = {
      # # ~/Library/Preferences/
      # }
    };
    activationScripts.postActivation.text = ''sudo chsh -s ${pkgs.fish}/bin/fish'';
    # # Reload all settings without relog/reboot
    # activationScripts.postUserActivation.text = ''
    #   /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    # '';
  };
}
