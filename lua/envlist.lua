local json = require "allo.json"

currentEnvIndex = 0
envlists = {}

class.Env()
function Env:_init(meta, code, icon)
    self.meta = meta
    self.code = code
    self.icon = icon
end

class.EnvList(ui.View)

function EnvList:_init(bounds)
    self:super(bounds)
    self.inactiveColor = { 34/255, 195/255, 181/255, 0.3}
    self.activeColor =   { 34/255, 195/255, 181/255, 0.8}
    self.grid = self:addSubview(ui.GridView())
end

function EnvList:awake()
    ui.View.awake(self)
    table.insert(envlists, self)
    self:updateButtonLooks()
end

function EnvList:sleep()
    ui.View.sleep(self)
    local i = tablex.find(envlists, self)
    table.remove(envlists, i)
end

function EnvList:populate()
    self.grid.bounds = self.bounds:copy():insetEdges(0, 0, 0, self.bounds.size.height/2, 0, 0)

    local helpLabel = self:addSubview(ui.Label{
        bounds= ui.Bounds{size=ui.Size(1.5,0.04,0.01)}
            :move( self.bounds.size:getEdge("bottom", "center", "back") )
            :move( 0.10, 0.05, 0),
        text= "Tap an environment to switch to it.",
        halign= "left",
        color={0.6, 0.6, 0.6, 1}
    })
    
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

    local columnCount = 3
    local rowCount = math.max(math.ceil(#self.envs/columnCount), 1)
    local itemSize = self.grid.bounds.size:copy()
    itemSize.width = itemSize.width / columnCount
    itemSize.height = itemSize.height / rowCount
    for i, desc in ipairs(self.envs) do
        desc.button = self.grid:addSubview(
            Button(ui.Bounds{size=itemSize:copy()}, desc)
        )
        desc.button:setColor(self.inactiveColor)
        local label = desc.button:addSubview(
            Label{
                bounds= desc.button.bounds:copy()
                    :insetEdges(0,0,desc.button.bounds.size.height-0.04,0, -desc.button.bounds.size.depth,0),
                text= desc.meta.display_name
            }
        )
        local iconModel = desc.button:addSubview(ui.ModelView(
            ui.Bounds{size=self.bounds.size:copy()},
            desc.icon
        ))
        desc.button.onActivated = function()
            self:selectEnvironment(i)
        end
    end
    self:layout()
end

function EnvList:selectEnvironment(i)
    local prev = self.envs[currentEnvIndex]
    local next = self.envs[i]
    currentEnvIndex = i

    if prev then
        prev.code:unload()
    end
    if next then
        next.code:load()
        
    end
    for _, l in ipairs(envlists) do
        l:updateButtonLooks()
    end
end

function EnvList:updateButtonLooks()
    for i, env in ipairs(self.envs) do
        local color = i == currentEnvIndex and self.activeColor or self.inactiveColor
        env.button:setColor(color)
    end
end

function EnvList:layout()
    self.grid:layout()
end

return EnvList
