{
  pkgs,
  lib,
  ...
}:
{
  home.packages = [
    pkgs.dark-notify
    pkgs.neovim-remote
    pkgs.switch-theme
  ];
  launchd.agents.dark-mode-notify = {
    enable = true;
    config = {
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/dark-mode-notify.stdout";
      StandardErrorPath = "/tmp/dark-mode-notify.stderr";
      ProgramArguments = [ "${pkgs.switch-theme}/bin/switch-theme" ];
      EnvironmentVariables = {
        PATH =
          (lib.makeBinPath [
            pkgs.dark-notify
            pkgs.neovim-remote
            pkgs.python3
            pkgs.bash
          ])
          + ":/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin";
      };
    };
  };
}
