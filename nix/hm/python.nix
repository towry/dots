{
  pkgs,
  config,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    uv
    python3
    pipx
  ];

  # Create global Python version pin for uv
  # This writes .python-version to the uv config directory
  # On macOS/Linux: $XDG_CONFIG_HOME/uv or ~/.config/uv
  xdg.configFile."uv/.python-version" = {
    text = "3.11.13\n";
  };

  # Set up Python environment variables
  home.sessionVariables = {
    # Ensure uv uses the pinned Python version globally
    UV_PYTHON = "3.13.5";
  };

  # Optional: Set up uv configuration
  xdg.configFile."uv/uv.toml" = {
    text = ''
      # Global Python version preference
      python-preference = "only-managed"
    '';
  };
}
