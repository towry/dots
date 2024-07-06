{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    environment = {
    };
    font = {
      name = "";
      size = "";
    };
    settings = {
    };
    keybindings = {
    };
    extraConfig = ''
    '';
  };
  xdg.configFile = {
    "kitty/currentTheme.conf".text = ''
    '';
  };
}
