# Standalone litellm config builder for CI/CD
# This uses the shared config generator
{ pkgs, lib }:

let
  configGen = import ./config-generator.nix { inherit pkgs lib; };
in
(pkgs.formats.yaml { }).generate "litellm-config.yaml" configGen.config
