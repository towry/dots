#!/usr/bin/env python3

import os
import re
import os.path
import sys
import subprocess
import signal

# author: https://github.com/olimorris/dotfiles/blob/main/commands/color_mode.py

kitty_path = os.path.expandvars("$HOME/.config/kitty")
# starship_path = "~/.config/starship"
tmux_path = "~"
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
  "kitty",
  # "alacritty",
  "neovim",
  # "tmux",
  #"starship",
  # tmux must come after neovim.
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


def app_alacritty(mode):
    print("Changing Alacritty theme to", mode)
    """
    Change the Alacritty terminal configuration based on the mode.
    """
    alacritty_file_path = os.path.expanduser("~/.config/alacritty/alacritty.toml")

    # Read the contents of the file
    with open(alacritty_file_path, 'r') as doc:
        file_contents = doc.read()

    # Define patterns for light and dark mode
    light_pattern = r'_light\.toml'
    dark_pattern = r'_dark\.toml'

    # Determine if Alacritty is in light or dark mode based on the file contents
    is_light = re.search(light_pattern, file_contents)
    is_dark = re.search(dark_pattern, file_contents)

    if mode == "light" and is_dark:
        # Replace dark mode with light mode
        new_contents = re.sub(dark_pattern, "_light.toml", file_contents, flags=re.M)
    elif mode == "dark" and is_light:
        # Replace light mode with dark mode
        new_contents = re.sub(light_pattern, "_dark.toml", file_contents, flags=re.M)
    else:
        # If the current mode is already set, print a message and stop the function
        print(f"Alacritty is already in {mode} mode.")
        return

    # Write the new configuration to the file
    with open(alacritty_file_path, 'w') as doc:
        doc.write(new_contents)

    print(f"Alacritty theme changed to {mode} mode.")

# Example usage:
# app_alacritty("light")
# app_alacritty("dark")

def app_kitty(mode):
    """
    Change the Kitty terminal
    """
    kitty_file = kitty_path + "/theme/current-theme.conf"
    kitty_theme_json = kitty_path + "/theme.json"

    dark_theme = ""
    light_theme = ""

    import json
    try:
        with open(kitty_theme_json, 'r') as j:
            theme_dict = json.loads(j.read())
            dark_theme = theme_dict["dark"]
            light_theme = theme_dict["light"]
    except Exception as e:
        print(e)
        return

    # Begin changing the modes
    if mode == "dark":
        contents = "include ./{}".format(dark_theme)

    if mode == "light":
        contents = "include ./{}".format(light_theme)

    with open(os.path.expanduser(kitty_file), "w") as config_file:
        config_file.write(contents)

    # Reload the Kitty config
    # Note: For Kitty 0.23.1, this breaks it
    try:
        pids = subprocess.run(["pgrep", "kitty"], stdout=subprocess.PIPE)
        pids = pids.stdout.splitlines()
        for pid in pids:
            try:
                subprocess.run(["kill", "-SIGUSR1", pid])
            except:
                continue
    except IndexError:
        pass


def app_starship(mode):
    """
    Change the prompt in the terminal
    """
    if mode == "dark":
        return subprocess.run(
            [
                "cp",
                os.path.expanduser(starship_path + "/starship_dark.toml"),
                os.path.expanduser(starship_path + "/starship.toml"),
            ]
        )

    if mode == "light":
        return subprocess.run(
            [
                "cp",
                os.path.expanduser(starship_path + "/starship_light.toml"),
                os.path.expanduser(starship_path + "/starship.toml"),
            ]
        )


def app_tmux(mode):
    subprocess.run(
        [
            "/usr/local/bin/tmux",
            "source-file",
            os.path.expanduser(tmux_path + "/.tmux.conf"),
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
            nvim.command("call v:lua.Ty.ToggleTheme('" + mode + "')")
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
