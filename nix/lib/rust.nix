{ ... }@inputs:
let
  supportedPlatforms = {
    aarch64-darwin = {
      rustTarget = "aarch64-apple-darwin";
    };
    aarch64-linux = {
      rustTarget = "aarch64-unknown-linux-gnu";
    };
    x86_64-darwin = {
      rustTarget = "x86_64-apple-darwin";
    };
    x86_64-linux = {
      rustTarget = "x86_64-unknown-linux-gnu";
    };
  };
in
{
  inherit supportedPlatforms;
  currentPlatform =
    system: 
    if builtins.hasAttr "system" inputs then supportedPlatforms.${system} else { };
}
