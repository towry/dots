{ config, lib, ... }:
let
  gitCfg = config.programs.git.extraConfig;
in
{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = gitCfg.user.name;
        email = gitCfg.user.email;
      };
      ui = {
        default-command = "status";
        pager = "less -FRX";
      };
      signing = {
        backend = "ssh";
        key = "~/.ssh/id_ed25519.pub";
        sign-all = true;
      };
      templates = {
        draft_commit_description = ''
          concat(
            description,
            indent("JJ: ", concat(
              "\n",
              "Change summary:\n",
              indent("     ", diff.summary()),
              "\n",
              "Full change:\n",
              indent("     ", diff.git()),
            )),
          )
        '';
      };
    };
  };
}
