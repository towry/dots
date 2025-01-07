#!/usr/bin/env bash


echo "> Install latest nix ..."

## install the default:
# sudo nix-env --install --file '<nixpkgs>' --attr nix cacert -I nixpkgs=channel:nixpkgs-unstable

## Install the latest
sudo nix-env --install --file '<nixpkgs>' --attr nixVersions.latest cacert -I nixpkgs=channel:nixpkgs-unstable


echo "> Restart the daemon"

sudo launchctl remove org.nixos.nix-daemon
sudo launchctl load /Library/LaunchDaemons/org.nixos.nix-daemon.plist
