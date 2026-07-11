local mt = {}

mt.info = {
    name = '资源保护',
    version = 1.0,
    author = '最萌小汐',
    description = '没有资源目录时，将模型替换为步兵。'
}

local function should_replace_model(w2l, has_resource_dir, model, ignore)
    local lower_model = model:lower()
    if ignore[lower_model] then
        return false
    end
    if not has_resource_dir then
        return true
    end
    if w2l:file_load('resource', model) then
        return false
    end
    if w2l:mpq_load(model) then
        return false
    end
    return true
end

function mt:on_full(w2l)
    if w2l.input_mode == 'lni' and (w2l.setting.mode == 'obj' or w2l.setting.mode == 'slk') then
        local has_resource_dir = fs.exists(w2l.setting.input / 'resource')
        
        local ignore = {
            [".mdx"] = true,
            [".mdl"] = true,
            ["model\\dummy.mdl"] = true,
        }
        
        for id, u in pairs(w2l.slk.unit) do
            if u.file and should_replace_model(w2l, has_resource_dir, u.file, ignore) then
                u.file = [[units\human\Footman\Footman.mdx]]
                if u.art then
                    u.art = [[ReplaceableTextures\CommandButtons\BTNFootman.blp]]
                end
            elseif u.art and not has_resource_dir then
                u.art = [[ReplaceableTextures\CommandButtons\BTNFootman.blp]]
            end
        end
    end
    if w2l.setting.mode == 'lni' then
        local file_save = w2l.file_save
        function w2l:file_save(type, name, buf)
            if type == 'resource' or type == 'sound' then
                return
            end
            file_save(self, type, name, buf)
        end
    end
end

return mt
