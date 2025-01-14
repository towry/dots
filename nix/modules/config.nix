{
  lib,
  # config,
  # pkgs,
  ...
}:
{
  options.vars.path-prefix = {
    value = lib.mkOption {
      description = "The path prefix used for env path";
      type = lib.types.str;
    };
    enable = lib.mkEnableOption {
      default = false;
    };
  };
  options.vars.editor = lib.mkOption {
    description = "The editor used for editing";
    type = lib.types.str;
    default = "nvim";
  };
}
