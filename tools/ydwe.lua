require 'filesystem'
local registry = require 'registry'

local function main()
    local key = registry.open [[HKEY_CURRENT_USER\SOFTWARE\Classes\YDWEMap\shell\run_war3\command]]
    if not key then
        print('需要YDWE关联w3x文件')
        return false
    end
    local command = key['']
    if not command then
        print('需要YDWE关联w3x文件')
        return false
    end
    local f, l = command:find('"[^"]*"')
    return fs.path(command:sub(f+1, l-1)):remove_filename()
end
local suc, r = pcall(main)
if not suc or not r then
    return false
end
return r
