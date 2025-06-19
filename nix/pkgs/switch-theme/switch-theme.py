import os
import os.path
import re
import signal
import subprocess
import sys

# author: https://github.com/olimorris/dotfiles/blob/main/commands/color_mode.py
tmux_path = "~/.config/tmux"
nvim_path = "~/.config/nvim"

# If we toggle dark mode via Alfred, we end up in a infinite loop. The dark-mode
# binary changes the MacOS mode which in turn causes color-mode-notify to run
# this script. This script then calls dark-mode (via the app_macos method)
# which kick starts this loop all over again. We use this boolean var
# to detect when we've run the command via the cmdline or alfred.
ran_from_cmd_line = False

# The order in which apps are changed
apps = [
  "fish",
  "neovim",
]

def app_macos(mode):
    """
    Change the macOS environment
    """
    path_to_file = "~/.color_mode"

    # Open the color_mode file
    with open(os.path.expanduser(path_to_file), "r") as config_file:
      contents = config_file.read()

    # Change the mode to ensure on a fresh startup, the color is remembered
    if mode == "dark":
        contents = contents.replace("light", "dark")
        if ran_from_cmd_line:
            subprocess.run(["dark-mode", "on"])

    if mode == "light":
        contents = contents.replace("dark", "light")
        if ran_from_cmd_line:
            subprocess.run(["dark-mode", "off"])

    with open(os.path.expanduser(path_to_file), "w") as config_file:
        config_file.write(contents)


def app_tmux(mode):
    subprocess.run(
        [
            "tmux",
            "source-file",
            os.path.expanduser(tmux_path + "/tmux.conf"),
        ]
    )
    # return os.system("exec zsh")


def app_neovim(mode):
    """
    Change the Neovim color scheme
    """
    try:
        nvim_config = nvim_path + "/lua/settings_env.lua"
        if not os.path.isfile(os.path.expanduser(nvim_config)):
            with open(os.path.expanduser(nvim_config), 'w') as fp:
                pass

        with open(os.path.expanduser(nvim_config), "r+") as config_file:
            contents = config_file.read()
            if contents.find("background") == -1:
                updated_contents = contents + 'vim.opt.background = "{mode}"'.format(mode=mode)
            else:
                updated_contents = re.sub(r'vim\.opt\.background\s*=\s*["\'].*?["\']', 'vim.opt.background = "{mode}"'.format(mode=mode), contents)
            config_file.seek(0)
            config_file.write(updated_contents)
            config_file.truncate()

        app_neovim_nvr(mode)
    except Exception as e:
            print(e)

def app_neovim_nvr(mode):
    from pynvim import attach
    # Get the neovim servers using neovim-remote
    print("start nvr call")
    servers = subprocess.run(["nvr", "--serverlist"], stdout=subprocess.PIPE)
    servers = servers.stdout.splitlines()

    # Loop through them and change the theme by calling our custom Lua code
    print("start loop nvim servers")
    for server in servers:
        try:
            nvim = attach("socket", path=server)
            nvim.command("call v:lua.V.util_toggle_dark('" + mode + "')")
        except Exception as e:
            print(e)
            continue
    print("finish nvr call")
    return


def app_fish(mode):
    file_path = "~/.private.fish"
    # write set -x DARKMODE ${mode} to .private.fish
    # if this line exists, then replace it, otherwise append it
    contents = ""
    if not os.path.isfile(os.path.expanduser(file_path)):
      with open(os.path.expanduser(file_path), 'w') as fp:
        pass
    with open(os.path.expanduser(file_path), "r") as config_file:
        contents = config_file.read()
    if "set -x DARKMODE" in contents:
        contents = re.sub(r"set -x DARKMODE .*", "set -x DARKMODE {}".format(mode), contents)
    else:
        contents += "\nset -x DARKMODE {}".format(mode)
    with open(os.path.expanduser(file_path), "w") as config_file:
        config_file.write(contents)

def run_apps(mode=None):
    """
    Based on the apps in our list, sequentially run and trigger them
    """
    if mode == None:
        mode = get_mode()

    print(f"mode is: {mode}")

        # sucks https://github.com/neovim/pynvim/issues/231
    def handler(signum, frame):
        raise Exception("end of time")
    signal.signal(signal.SIGALRM, handler)

    # must exit after 3s
    signal.alarm(5)
    for app in apps:
        try:
            getattr(sys.modules[__name__], "app_%s" % app)(mode)
        except Exception as e:
            continue
    return


def get_mode():
    """
    Determine what mode macOS is currently in
    """
    mode = os.environ.get("DARKMODE", 1)
    if mode == 1 or mode == "1":
        return "dark"
    else:
        return "light"


if __name__ == "__main__":
    # If we've passed a specific mode then activate it
    try:
        if sys.argv[1]:
            ran_from_cmd_line = True
        run_apps(sys.argv[1])
    except IndexError:
        try:
            run_apps()
        except Exception as e:
            print(e)

