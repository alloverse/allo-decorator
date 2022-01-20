class.Env()
function Env:_init(meta, code, icon)
    self.meta = meta
    self.code = code
    self.icon = icon
end

class.SkyList(ui.View)

function SkyList:_init(bounds)
    self:super(bounds)
    self.inactiveColor = { 34/255, 195/255, 181/255, 0.3}
    self.activeColor =   { 34/255, 195/255, 181/255, 0.8}
    self.grid = self:addSubview(ui.GridView())
end

function SkyList:awake()
    ui.View.awake(self)
    table.insert(skies.listeners, self)
    self:skyboxChanged()
end

function SkyList:sleep()
    ui.View.sleep(self)
    local i = tablex.find(skies.listeners, self)
    table.remove(skies.listeners, i)
end

function SkyList:populate()
    self.grid.bounds = self.bounds:copy():insetEdges(0, 0, 0, self.bounds.size.height/2, 0, 0)

    local helpLabel = self:addSubview(ui.Label{
        bounds= ui.Bounds{size=ui.Size(1.5,0.04,0.01)}
            :move( self.bounds.size:getEdge("bottom", "center", "back") )
            :move( 0.10, 0.05, 0),
        text= "Tap a sky to switch to it.",
        halign= "left",
        color={0.6, 0.6, 0.6, 1}
    })
    
    self.buttons = {}

    local columnCount = 3
    local rowCount = math.max(math.ceil(#skies.skyboxes/columnCount), 1)
    local itemSize = self.grid.bounds.size:copy()
    itemSize.width = itemSize.width / columnCount
    itemSize.height = itemSize.height / rowCount
    for name, desc in pairs(skies.skyboxes) do
        local button = self.grid:addSubview(
            Button(ui.Bounds{size=itemSize:copy()}, desc)
        )
        button:setColor(self.inactiveColor)
        local label = button:addSubview(
            Label{
                bounds= button.bounds:copy()
                    :insetEdges(0,0,button.bounds.size.height-0.04,0, -button.bounds.size.depth,0),
                text= name
            }
        )
        local icon = button:addSubview(ui.Surface(
            ui.Bounds{size=itemSize:copy()}:inset(0.10, 0.10, 0):move(0,0,0.041)
        ))
        icon:setTexture(desc.front)
        button.onActivated = function()
            skies:useSky(name)
        end
        self.buttons[name] = button
    end
    self:layout()
end

function SkyList:skyboxChanged()
    for name, desc in ipairs(skies.skyboxes) do
        local color = name == skies.currentSkyName and self.activeColor or self.inactiveColor
        local button = self.buttons[name]
        button:setColor(color)
    end
end

function SkyList:layout()
    self.grid:layout()
end

return SkyList
