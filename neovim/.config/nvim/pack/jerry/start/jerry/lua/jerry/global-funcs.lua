
function P(...)
    local objects = vim.tbl_map(vim.inspect, {...})
    print(unpack(objects))
end

if pcall(require, 'plenary') then
  RELOAD = require('plenary.reload').reload_module

  R = function(name)
    RELOAD(name)
    return require(name)
  end
end

S = function(...) require('jerry.term').send(...) end
SV = function() require('jerry.term').send_visual() end
SL = function() require('jerry.term').send(vim.fn.getline('.')) end

RT = function(...) require('jerry.asyncjob').run_to_tab(...) end
RS = function(...) require('jerry.asyncjob').run_to_split(...) end
RV = function(...) require('jerry.asyncjob').run_to_vsplit(...) end

-- vim:et sw=2 ts=2 sts=2
