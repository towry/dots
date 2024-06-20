#!/usr/bin/env bash

font_name_prefix="BerkeleyMono"
font_variants="Regular Bold Italic BoldItalic"
font_ext="ttf"

# copy fonts to a temp dir
cd $(mktemp -d)
mdkir -p dist

# download fonts
for variant in $font_variants; do
  # wget https://www.berkely.edu/fonts/${font_name_prefix}-${variant}.${font_ext}
  cp $HOME/Library/fonts/${font_name_prefix}-${variant}.${font_ext} .
done

echo "current dir: $(pwd)"

ls -al

printf "> Begin to patch fonts\n> Make sure nerd-font-patcher is installed.\n\t> nix-env -iA nixpkgs.nerd-font-patcher"

# run nerd-font-patcher (path-to-font) -out ./dist
for variant in $font_variants; do
  font_name="${font_name_prefix}-${variant}.${font_ext}"
  echo "patching $font_name"
  nerd-font-patcher $font_name -out ./dist
done

ls -al ./dist

echo ""
echo "> [done] ==========================="
echo "> dir: $(pwd)"
echo ""
