# Nix derivation to build litellm config for remote deployment
# This exports just the config.yaml for use in CI/CD pipelines
#
# Build with: nix-build -A litellm-deploy-config deploy-config.nix
# Or reference from main config: nix eval --raw .#homeConfigurations.<host>.config.home.file.\".config/litellm/config.yaml\".source
{
  pkgs ? import <nixpkgs> { },
}:

let
  # Import the main litellm config
  # Note: This assumes nix-priv is available during build
  litellmModule = import ../litellm.nix {
    inherit pkgs;
    config = {
      home = {
        homeDirectory = "/home/deploy"; # Placeholder, not used for config generation
      };
      xdg = {
        stateHome = "/var/lib/litellm"; # Placeholder
      };
    };
    lib = pkgs.lib;
  };

in
{
  # Export the config file path
  # Usage: nix-build will create a result symlink pointing to the config
  litellm-config = litellmModule.home.file.".config/litellm/config.yaml".source;

  # Create a deployment package containing:
  # - config.yaml
  # - Containerfile
  # - systemd service file
  # - deploy script
  litellm-deploy = pkgs.stdenv.mkDerivation {
    name = "litellm-deploy";
    version = "1.0.0";

    src = ./.;

    buildInputs = [ ];

    installPhase = ''
      mkdir -p $out

      # Copy config (with embedded secrets from nix-priv)
      cp ${litellmModule.home.file.".config/litellm/config.yaml".source} $out/config.yaml

      # Copy deployment files
      cp ${./Containerfile} $out/Containerfile
      cp ${./litellm.service} $out/litellm.service
      cp ${./deploy.sh} $out/deploy.sh
      chmod +x $out/deploy.sh

      # Create a README
      cat > $out/README.md <<EOF
      # LiteLLM Deployment Package

      This package contains:
      - config.yaml: LiteLLM configuration (with embedded secrets)
      - Containerfile: Container build file
      - litellm.service: Systemd service unit
      - deploy.sh: Deployment script

      ## Deployment

      1. Copy files to remote server:
         \`\`\`
         scp -r * user@host:/tmp/litellm-deploy/
         \`\`\`

      2. Run deploy script on remote (as root):
         \`\`\`
         ssh user@host 'sudo /tmp/litellm-deploy/deploy.sh /tmp/litellm-deploy/config.yaml'
         \`\`\`

      3. Check service status:
         \`\`\`
         ssh user@host 'sudo systemctl status litellm'
         \`\`\`
      EOF
    '';

    meta = with pkgs.lib; {
      description = "LiteLLM deployment package for remote servers";
      platforms = platforms.all;
    };
  };
}
