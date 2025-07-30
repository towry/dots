{
  pkgs,
  packages ? [ ],
  ...
}:

pkgs.python312.withPackages (
  pp:
  (with pp; [
    pynvim
  ])
  ++ packages
)
