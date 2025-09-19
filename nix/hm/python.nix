{
  pkgs,
  config,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    uv
    (python3.withPackages (ps: with ps; [
      pynvim
    ]))
    pipx
  ];

  # Set up Python environment variables
  home.sessionVariables = {
    # Force uv to use system Python instead of downloading its own
    UV_PYTHON = "${pkgs.python3}/bin/python3";
  };

  # Configure uv to prefer system Python
  xdg.configFile."uv/uv.toml" = {
    text = ''
      # Use system Python instead of downloading managed versions
      python-preference = "system"
    '';
  };
}
