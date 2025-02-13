{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    autoraise
  ];

  home.file.autoraise = {
    executable = true;
    target = ".config/AutoRaise/config";
    text = ''
      pollMillis=500
      delay=1
      focusDelay=2
      warpX=0.5
      warpY=0.1
      scale=2.5
      altTaskSwitcher=false
      ignoreSpaceChanged=false
      ignoreApps=""
      mouseDelta=0.1
    '';
  };
}
