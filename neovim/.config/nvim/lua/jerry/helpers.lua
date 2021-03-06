
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

-- vim:et sw=2 ts=2 sts=2
