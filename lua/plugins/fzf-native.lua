return {
  'nvim-telescope/telescope-fzf-native.nvim',
  lazy = true,
  dependencies = { 'nvim-telescope/telescope.nvim' },

  build = function()
    local function run(cmd)
      local output = vim.fn.system(cmd)
      if vim.v.shell_error ~= 0 then
        error(string.format("Command failed: %s\n%s", cmd, output))
      end
      return output
    end

    local os_info = vim.loop.os_uname()
    local os_name = os_info.sysname:lower()
    local is_windows = os_name:find("windows") ~= nil
    local is_wsl = os_name == "linux" and os_info.release:lower():find("microsoft") ~= nil

    -- Ensure required tools are installed
    local function detect_build_tool()
      if vim.fn.executable("cmake") ~= 1 then
        error("CMake is required but not found.")
      end
      if vim.fn.executable("ninja") == 1 then return "ninja" end
      if vim.fn.executable("make") == 1 then return "make" end
      error("Either Ninja or Make is required but neither was found.")
    end

    local build_tool = detect_build_tool()

    -- Clean old build
    if vim.fn.isdirectory("build") == 1 then
      local clean_cmd = is_windows and 'rmdir /s /q build' or 'rm -rf build'
      run(clean_cmd)
    end

    -- Generate appropriate build commands
    local build_cmds
    if is_windows then
      build_cmds = {
        'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release',
        'cmake --build build --config Release',
      }
    elseif build_tool == "ninja" then
      build_cmds = {
        'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -G Ninja',
        'ninja -C build',
      }
    else
      build_cmds = {
        'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release',
        'make -C build',
      }
    end

    -- Execute build commands
    for i, cmd in ipairs(build_cmds) do
      vim.notify(string.format("telescope-fzf-native build %d/%d: %s", i, #build_cmds, cmd), vim.log.levels.INFO)
      local ok, err = pcall(run, cmd)
      if not ok then
        error(string.format("Build failed at step %d:\n%s", i, err))
      end
    end

    vim.notify("telescope-fzf-native built successfully ✅", vim.log.levels.INFO)
  end,

  config = function()
    local ok, telescope = pcall(require, 'telescope')
    if not ok then
      vim.notify("telescope.nvim is required for telescope-fzf-native", vim.log.levels.ERROR)
      return
    end

    telescope.setup({
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        }
      }
    })

    telescope.load_extension('fzf')
  end,
}
