{ pkgs, ... }:
{
  networking = {
    computerName = "towryDeMpb";
    hostName = "towryDeMpb";
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
        # KeyRepeat = 0;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      dock = {
        autohide = false;
        largesize = 42;
        tilesize = 40;
        magnification = true;
        showhidden = true;
        show-recents = true;
        minimize-to-application = true;
        orientation = "bottom";
      };
      finder = {
        AppleShowAllFiles = false;
        ShowPathbar = true;
        QuitMenuItem = false;
        ShowStatusBar = true;
      };
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
      };
      magicmouse = {
        MouseButtonMode = "TwoButton";
      };
    };
    activationScripts.postActivation.text = ''sudo chsh -s ${pkgs.fish}/bin/fish'';
  };
}
