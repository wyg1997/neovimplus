local dap = require('dap')

dap.adapters.python = {
    type = 'executable';
    command = "python3";
    args = {'-m', 'debugpy.adapter'};
}

dap.configurations.python = {
    {
        type = "python";
        request = "launch";
        name = "launch file";

        program = "${file}";
        pythonPath = function ()
            return "python3"
        end
    },
}
