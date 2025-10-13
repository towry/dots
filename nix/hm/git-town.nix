{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    git-town
  ];
  programs.fish.shellAliases = {
    gt = "git-town";
  };
  programs.git = {
    # TODO: add 'towry/' prefix
    aliases = {
      hack = ''!f() { if [ -z "$1" ]; then echo "Usage: git hack <description>"; return 1; fi; branch_name=$(aichat --role git-branch -S -c "$*"); if [ $? -eq 0 ] && [ -n "$branch_name" ]; then date_suffix=$(date +%m%d%H); final_branch_name="$branch_name-$date_suffix"; git-town hack "$final_branch_name"; else echo "Failed to generate branch name"; return 1; fi; }; f'';
      append = ''!f() { if [ -z "$1" ]; then echo "Usage: git append <description>"; return 1; fi; branch_name=$(aichat --role git-branch -S -c "$*"); if [ $? -eq 0 ] && [ -n "$branch_name" ]; then date_suffix=$(date +%m%d%H); final_branch_name="$branch_name-$date_suffix"; git-town append "$final_branch_name"; else echo "Failed to generate branch name"; return 1; fi; }; f'';
    };
    extraConfig = {
      git-town = {
        # https://www.git-town.com/all-commands.html?highlight=observed#limit-branch-syncing
        sync-tags = false;
        # prevent merge into parent branch
        # contribution-regex = "^(pub/sandbox|wip)$";
        # no parent, never ship
        # perennial-regex = "^(pub/sandbox|wip)$";
        sync-feature-strategy = "rebase";
        perennial-branches = "master main develop wip";
      };
    };
  };
}
