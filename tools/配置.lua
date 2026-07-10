local ydwe = require 'tools.ydwe'
local process = require 'process'
if not ydwe then
    return
end
print('YDWE:', ydwe:string())
local p = process()
local app = ydwe / 'bin' / 'ydweconfig.exe'
if not p:create(app, ('"%s"'):format(app:string()), ydwe / 'bin') then
    print('启动YDWE配置失败')
end
