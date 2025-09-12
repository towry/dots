# 命令行指南

_命令 1_: `nix flake update` _描述_: 更新 Nix flake 的输入依赖，当需要拉取最新版
本的包或模块时使用。

_命令 2_: `home-manager switch --flake .#towry` _描述_: 应用用户级别的配置更改，
使用 home-manager 切换到指定的配置。

_命令 3_: `darwin-rebuild switch --flake .` _描述_: 应用系统级别的配置更改，使用
nix-darwin 切换到新的系统配置。

_命令 4_: `jj ci -m "message"` _描述_: 提交当前更改到 JJ 仓库，使用描述性消息。

_命令 5_: `jj df` _描述_: 显示当前工作目录与父提交之间的差异。

_命令 6_: `jj log` _描述_: 显示提交历史日志。

_命令 7_: `jj new branch-name` _描述_: 创建新的分支或书签。

_命令 8_: `jj gp -b branch-name` _描述_: 推送指定的分支到远程仓库。

_命令 9_: `make build` _描述_: 构建用户配置，使用 home-manager 构建激活包。

_命令 10_: `make switch` _描述_: 切换系统配置，使用 darwin-rebuild 应用更改。

_命令 11_: `just update-self-repo` _描述_: 更新私有仓库的输入，使用 nix flake
update 针对特定输入。

_注意事项_:

- 在这个 dotfiles 项目中，`nix build` 命令通常用于构建特定的输出，如
  `.#homeConfigurations.towry.activationPackage`，而不是整个项目构建。
- JJ 被用作版本控制系统而不是 Git，因此提交和推送命令使用 `jj ci` 和 `jj gp` 而
  不是 `git commit` 和 `git push`。
- `make` 目标如 `build` 和 `switch` 是对 nix 命令的包装，简化了常见操作。
- 更新 flake 输入后，通常需要运行 `home-manager switch` 或
  `darwin-rebuild switch` 来应用更改。
- 私有仓库的更新使用 `just update-self-repo` 来避免手动指定输入名称。
