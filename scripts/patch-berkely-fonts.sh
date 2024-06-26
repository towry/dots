#!/usr/bin/env bash

set -x

font_name_prefix="BerkeleyMono"
font_variants="Regular Bold Italic BoldItalic"
font_ext="ttf"

# copy fonts to a temp dir
cd $(mktemp -d)
mkdir -p dist

# download fonts
for variant in $font_variants; do
  # wget https://www.berkely.edu/fonts/${font_name_prefix}-${variant}.${font_ext}
  cp $HOME/Library/fonts/${font_name_prefix}-${variant}.${font_ext} .
done

echo "current dir: $(pwd)"

ls -al

printf "> Begin to patch fonts\n> Make sure nerd-font-patcher is installed.\n\t> nix-env -iA nixpkgs.nerd-font-patcher"

## https://tech.serhatteker.com/post/2023-04/patch-berkeley-mono-font-with-nerd-fonts/
# run nerd-font-patcher (path-to-font) -out ./dist
for variant in $font_variants; do
  font_name="${font_name_prefix}-${variant}.${font_ext}"
  echo "patching $font_name"
  nerd-font-patcher --debug --careful -c --name "${font_name_prefix}NerdFont-${variant}" -out ./dist $font_name
done

ls -al ./dist

mkdir -p $HOME/Library/fonts/BerkeleyMonoNerdFont
cp -rf ./dist/*.ttf $HOME/Library/fonts/BerkeleyMonoNerdFont/

echo "> checking the fonts dir, make sure no old nerd fonts exists"
cd $HOME/Library/fonts/ && fd Berkeley

echo ""
echo "> [done] ==========================="
echo "> dir: $(pwd)"
echo ""
