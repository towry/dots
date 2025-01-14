{ username, ... }:
{
  vars = {
    path-prefix = {
      value = "/etc/profiles/per-user/${username}";
      enable = true;
    };
  };
}
