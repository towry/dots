local M = {}
local wez = require('wezterm')
local environment = require('environment')

---User home directory
---@return string home path to the suer home directory.
M.home = (os.getenv('USERPROFILE') or os.getenv('HOME') or wez.home_dir or ''):gsub('\\', '/')
M.is_windows = environment == 'windows'

---https://github.com/sravioli/wezterm/blob/3709298bb9ac25a75dba06caee5383a8412602cb/utils/fun.lua
---Returns the current working directory and the hostname.
---@param pane table The wezterm pane object.
---@param search_git_root_instead? boolean Whether to search for the git root instead.
---@return string cwd The current working directory.
---@return string hostname The hostname.
---@see Fun.find_git_dir
M.get_cwd_hostname = function(pane, search_git_root_instead)
  local cwd, hostname = '', ''
  ---figure cwd and host of current pane. This will pick up the hostname for the remote
  ---host shell is using OSC 7 on the remote host.
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    if type(cwd_uri) == 'userdata' then
      ---newer wezterm versions have a URL object, making it easier
      cwd = cwd_uri.file_path
      hostname = cwd_uri.host or wez.hostname()
    else
      ---older version, 20230712-072601-f4abf8fd or earlier, which doesn't have the URL object
      cwd_uri = cwd_uri:sub(8)
      local slash = cwd_uri:find('/')
      if slash then
        hostname = cwd_uri:sub(1, slash - 1)

        ---extract the cwd from the uri, decoding %-encoding
        cwd = cwd_uri:gsub('%%(%x%x)', function(hex)
          return string.char(tonumber(hex, 16))
        end)
      end
    end

    ---remove the domain name portion of the hostname
    local dot = hostname:find('[.]')
    if dot then
      hostname = hostname:sub(1, dot - 1)
    end
    if hostname == '' then
      hostname = wez.hostname()
    end
    hostname = hostname:gsub('^%l', string.upper)
  end

  if M.is_windows then
    cwd = cwd:gsub('/' .. M.home .. '(.-)$', '~%1')
  else
    cwd = cwd:gsub(M.home .. '(.-)$', '~%1')
  end

  ---search for the git root of the project if specified
  if search_git_root_instead then
    -- local git_root = M.find_git_dir(cwd)
    -- cwd = git_root or cwd ---fallback to cwd
  end

  return cwd, hostname
end

function M.is_vim(pane)
  local is_vim_env = pane:get_user_vars().IS_NVIM == 'true'
  if is_vim_env == true then
    return true
  end
  -- This gsub is equivalent to POSIX basename(3)
  -- Given "/foo/bar" returns "bar"
  -- Given "c:\\foo\\bar" returns "bar"
  local process_name = string.gsub(pane:get_foreground_process_name() or '', '(.*[/\\])(.*)', '%2')
  return process_name == 'nvim' or process_name == 'vim' or process_name == 'git'
end

function M.list_contains(list, name)
  for _, item in ipairs(list) do
    if item == name then
      return true
    end
  end

  return false
end

function M.basename(s)
  if not s then
    return ''
  end
  return string.gsub(s, '(.*[/\\])(.*)', '%2')
end

function M.convert_home_dir(path)
  local cwd = path
  local home = os.getenv('HOME')
  cwd = cwd:gsub('^' .. home .. '/', '~/')
  if cwd == '' then
    return path
  end
  return cwd
end

function M.convert_useful_path(dir)
  local cwd = M.convert_home_dir(dir)
  return M.basename(cwd)
end

function M.split_from_url(dir)
  local cwd = ''
  local hostname = ''
  local cwd_uri = dir:sub(8)
  local slash = cwd_uri:find('/')
  if slash then
    hostname = cwd_uri:sub(1, slash - 1)
    -- Remove the domain name portion of the hostname
    local dot = hostname:find('[.]')
    if dot then
      hostname = hostname:sub(1, dot - 1)
    end
    cwd = cwd_uri:sub(slash)
    cwd = M.convert_useful_path(cwd)
  end
  return hostname, cwd
end

return M
