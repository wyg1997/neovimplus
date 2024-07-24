local dap_breakpoint_color = {
    breakpoint = {
        ctermbg=0,
        fg='#993939',
        bg='#31353f',
    },
    logpoing = {
        ctermbg=0,
        fg='#61afef',
        bg='#31353f',
    },
    stopped = {
        ctermbg=0,
        fg='#98c379',
        bg='#31353f'
    },
}

vim.api.nvim_set_hl(0, 'DapBreakpoint', dap_breakpoint_color.breakpoint)
vim.api.nvim_set_hl(0, 'DapLogPoint', dap_breakpoint_color.logpoing)
vim.api.nvim_set_hl(0, 'DapStopped', dap_breakpoint_color.stopped)

local dap_breakpoint = {
    error = {
        text = "⛔︎",
        texthl = "DapBreakpoint",
        linehl = "DapBreakpoint",
        numhl = "DapBreakpoint",
    },
    condition = {
        text = '☊',
        texthl = 'DapBreakpoint',
        linehl = 'DapBreakpoint',
        numhl = 'DapBreakpoint',
    },
    rejected = {
        text = "❌",
        texthl = "DapBreakpint",
        linehl = "DapBreakpoint",
        numhl = "DapBreakpoint",
    },
    logpoint = {
        text = '',
        texthl = 'DapLogPoint',
        linehl = 'DapLogPoint',
        numhl = 'DapLogPoint',
    },
    stopped = {
        text = '',
        texthl = 'DapStopped',
        linehl = 'DapStopped',
        numhl = 'DapStopped',
    },
}

vim.fn.sign_define('DapBreakpoint', dap_breakpoint.error)
vim.fn.sign_define('DapBreakpointCondition', dap_breakpoint.condition)
vim.fn.sign_define('DapBreakpointRejected', dap_breakpoint.rejected)
vim.fn.sign_define('DapLogPoint', dap_breakpoint.logpoint)
vim.fn.sign_define('DapStopped', dap_breakpoint.stopped)

-- key mappings

local whichkey = require "which-key"

-- reference: https://alpha2phi.medium.com/neovim-for-beginners-debugging-using-dap-44626a767f57
whichkey.add({
    { "<F10>", "<cmd>lua require'dap'.step_over()<CR>", desc = "Step Over", nowait = false, remap = false },
    { "<F11>", "<cmd>lua require'dap'.step_into()<CR>", desc = "Step Into", nowait = false, remap = false },
    { "<F12>", "<cmd>lua require'dap'.step_out()<cr>", desc = "Step Out", nowait = false, remap = false },
    { "<F5>", "<cmd>lua require'dap'.continue()<CR>", desc = "Continue", nowait = false, remap = false },
    { "<F6>", "<cmd>lua require'dap'.run_to_cursor()<cr>", desc = "Run to Cursor", nowait = false, remap = false },
    { "<F9>", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", desc = "Toggle Breakpoint", nowait = false, remap = false },
    { "<leader>C", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input '[Condition] > ')<cr>", desc = "Conditional Breakpoint", nowait = false, remap = false },
    { "<leader>E", "<cmd>lua require'dapui'.eval(vim.fn.input '[Expression] > ')<cr>", desc = "Evaluate Input", nowait = false, remap = false },
    { "<leader>Q", "<cmd>lua require'dap'.terminate()<CR><cmd>lua require'dapui'.close()<cr>", desc = "Quit", nowait = false, remap = false },
})

whichkey.add({
    mode = {"v"},
    { "<leader>E", "<cmd>lua require'dapui'.eval()<cr>", desc = "Evaluate", nowait = false, remap = false },
})
