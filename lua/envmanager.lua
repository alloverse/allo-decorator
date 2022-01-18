local json = require "allo.json"

class.EnvManager()
function EnvManager:_init()
    self.envs = {}
    
    local p = io.popen('find envs/* -maxdepth 0')
    for envPath in p:lines() do
        local infojsonstr = readfile(envPath.."/info.json")
        if infojsonstr then
            print("Decorator adding env "..envPath)
            local env = Env(
                json.decode(infojsonstr),
                require(envPath.."/main"),
                ui.Asset.File(envPath.."/icon.glb")
            )
            table.insert(self.envs, env)
            app.assetManager:add(env.icon)
        end
    end
    p:close()
    self.currentEnvIndex = 0
    self.listeners = {}
end

function EnvManager:selectEnvironment(i)
    local prev = self.envs[self.currentEnvIndex]
    local next = self.envs[i]
    self.currentEnvIndex = i

    if prev then
        prev.code:unload()
    end
    if next then
        next.code:load()
    end
    for i, l in ipairs(self.listeners) do
        l:environmentChanged()
    end
end

return EnvManager
