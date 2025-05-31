{ username, ... }:
{
  vars = {
    path-prefix = {
      value = "/etc/profiles/per-user/${username}";
      enable = true;
    };
    git-town = {
      enable = true;
    };
    editor = "vim";
  };
}
