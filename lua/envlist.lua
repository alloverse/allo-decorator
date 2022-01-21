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
    table.insert(envs.listeners, self)
    self:environmentChanged()
end

function EnvList:sleep()
    ui.View.sleep(self)
    local i = tablex.find(envs.listeners, self)
    table.remove(envs.listeners, i)
end

function EnvList:populate()
    self.grid.bounds = self.bounds:copy():insetEdges(0, 0, 0, self.bounds.size.height/2, 0, 0)

    local helpLabel = self:addSubview(ui.Label{
        bounds= ui.Bounds{size=ui.Size(1.5,0.04,0.01)}
            :move( self.bounds.size:getEdge("bottom", "center", "back") )
            :move( 0.10, -0.11, 0),
        text= "Tap an environment to switch to it.",
        halign= "left",
        color={0.6, 0.6, 0.6, 1}
    })
    
    self.buttons = {}

    local columnCount = 3
    local rowCount = math.max(math.ceil(#envs.envs/columnCount), 1)
    local itemSize = self.grid.bounds.size:copy()
    itemSize.width = itemSize.width / columnCount
    itemSize.height = itemSize.height / rowCount
    for i, desc in ipairs(envs.envs) do
        local button = self.grid:addSubview(
            Button(ui.Bounds{size=itemSize:copy()}, desc)
        )
        button:setColor(self.inactiveColor)
        local label = button:addSubview(
            Label{
                bounds= button.bounds:copy()
                    :insetEdges(0,0,button.bounds.size.height-0.04,0, -button.bounds.size.depth,0),
                text= desc.meta.display_name
            }
        )
        local iconModel = button:addSubview(ui.ModelView(
            ui.Bounds{size=self.bounds.size:copy()},
            desc.icon
        ))
        button.onActivated = function()
            envs:selectEnvironment(i)
        end
        table.insert(self.buttons, button)
    end
    self:layout()
end

function EnvList:environmentChanged()
    for i, env in ipairs(envs.envs) do
        local color = i == envs.currentEnvIndex and self.activeColor or self.inactiveColor
        local button = self.buttons[i]
        button:setColor(color)
    end
end

function EnvList:layout()
    self.grid:layout()
end

return EnvList
