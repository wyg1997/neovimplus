-- TODO: move these function to utils dir
local function is_win()
  return package.config:sub(1, 1) == '\\'
end

local function get_path_separator()
  if is_win() then
    return '\\'
  end
  return '/'
end

local function get_current_script_path()                                       
  local str = debug.getinfo(2, 'S').source:sub(2)                  
  if is_win() then                                                 
    str = str:gsub('/', '\\')                                      
  end                                                              
  return str:match('(.*' .. get_path_separator() .. ')')           
end

local function load_lua_files(dir, recursion)
  local script_path = get_current_script_path()
  local full_dir = vim.loop.fs_realpath(script_path .. '/' .. dir)

  for _, file in ipairs(vim.fn.readdir(full_dir)) do
    local full_path = full_dir .. '/' .. file
    if vim.fn.isdirectory(full_path) == 0 and file:match('%.lua$') then
      require(dir .. '/' .. string.gsub(file, '%.lua$', ''))
    elseif recursion and vim.fn.isdirectory(full_path) == 1 then
      load_lua_files(dir .. '/' .. file, recursion)
    end
  end
end

-- 主题设置
vim.opt.background = "dark"
vim.g.onedark_termcolors = 256
vim.cmd("colorscheme onedark")

-- load plugin configs
load_lua_files('plugin_configs', true)
