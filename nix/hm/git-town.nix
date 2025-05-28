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
    aliases = {
      hack = ''!f() { if [ -z "$1" ]; then echo "Usage: git hack <description>"; return 1; fi; branch_name=$(aichat --role git-branch -S -c "$*"); if [ $? -eq 0 ] && [ -n "$branch_name" ]; then date_suffix=$(date +%m%d); final_branch_name="$branch_name-$date_suffix"; git-town hack "$final_branch_name"; else echo "Failed to generate branch name"; return 1; fi; }; f'';
      append = ''!f() { if [ -z "$1" ]; then echo "Usage: git append <description>"; return 1; fi; branch_name=$(aichat --role git-branch -S -c "$*"); if [ $? -eq 0 ] && [ -n "$branch_name" ]; then date_suffix=$(date +%m%d); final_branch_name="$branch_name-$date_suffix"; git-town append "$final_branch_name"; else echo "Failed to generate branch name"; return 1; fi; }; f'';
    };
    extraConfig = {
      git-town = {
        sync-tags = false;
        contribution-regex = "^(pub/sandbox)$";
        sync-feature-strategy = "merge";
      };
    };
  };
}
