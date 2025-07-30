{
  pkgs,
  packages ? [ ],
  ...
}:

pkgs.python3.withPackages (
  pp:
  (with pp; [
    pynvim
  ])
  ++ packages
)
