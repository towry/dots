{
  username,
  pkgs,
  ...
}: {
  # csrutil enable --without fs --without debug --without nvram
  # nvram boot-args=-arm64e_preview_abi
  environment.etc."sudoers.d/yabai".text = ''
    ${username} ALL = (root) NOPASSWD: ${pkgs.yabai}/bin/yabai --load-sa
  '';
}
