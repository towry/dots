{
  username,
  pkgs,
  ...
}:
{
  environment.etc."sudoers.d/yabai".source = pkgs.runCommand "sudoers-yabai" { } ''
    YABAI_BIN="/etc/profiles/per-user/${username}/bin/yabai"
    SHASUM=$(sha256sum "$YABAI_BIN" | cut -d' ' -f1)
    cat <<EOF >"$out"
    ${username} ALL=(root) NOPASSWD: sha256:$SHASUM $YABAI_BIN --load-sa
    EOF
  '';
  # csrutil enable --without fs --without debug --without nvram
  # nvram boot-args=-arm64e_preview_abi
}
