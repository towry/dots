{pkgs, ...}: {
  home.packages = [
    pkgs.yabai
  ];

  xdg.configFile = let
    jqbin = "${pkgs.jq}/bin/jq";
  in {
    "yabai/yabairc".text = ''
    '';
  };
}
