local dapui = require("dapui")

dapui.setup({
    icons = { expanded = "", collapsed = "", current_frame = "" },
    mappings = {
        -- Use a table to apply multiple mappings
        expand = { "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = "t",
    },
    layouts = {
        {
            elements = {
                {
                    id = 'scopes',
                    size = 0.35
                },
                {id = "stacks", size = 0.35},
                {id = "watches", size = 0.15},
                {id = "breakpoints", size = 0.15},
            },
            size = 40,
            position = "left",
        },
        {
            elements = {
                "repl"
            },
            size = 5,
            position = "bottom",
        }
    },

    controls = {enabled = true},
    floating = {
        max_height = nil, -- These can be integers or a float between 0 and 1.
        max_width = nil, -- Floats will be treated as percentage of your screen.
        border = "single", -- Border style. Can be "single", "double" or "rounded"
        mappings = {
            close = { "q", "<Esc>" },
        },
    },
    windows = { indent = 1 },
})

local dap = require("dap")
dap.listeners.after.event_initialized["dapui_config"] = function()
    vim.api.nvim_command("call CocAction('diagnosticToggle', 0)")
    dapui.open({})
end

dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close({})
    dap.repl.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close({})
    dap.repl.close()
end
