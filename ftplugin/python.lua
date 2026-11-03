local dap = require('dap')
local python = vim.g.python3_host_prog
if not python or python == '' or vim.fn.executable(python) == 0 then
    python = 'python3'
end

dap.adapters.python = {
    type = 'executable';
    command = python;
    args = {'-m', 'debugpy.adapter'};
}

dap.configurations.python = {
    {
        type = "python";
        request = "launch";
        name = "launch file";

        program = "${file}";
        pythonPath = function ()
            return python
        end
    },
}
