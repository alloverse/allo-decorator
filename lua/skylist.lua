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

function slider(text, x, y, parent, func, min, max)
    local margin = 0.02
    local parentWidth = parent.bounds.size.width - margin * 2
    local labelWidth = parentWidth * 0.3 - margin
    local sliderWidth = parentWidth - labelWidth - margin

    local v = View(Bounds(
        x, y, -0.1,
        parentWidth, 0.05, 0.01
    ))
    local l = Label(Bounds(
        -parentWidth / 2 + labelWidth / 2, 0, 0.01,
        labelWidth, v.bounds.size.height, v.bounds.size.depth
    ))
    l:setHalign("right")

    l:setText(text)

    local s = Slider(Bounds(
        -parentWidth / 2 + labelWidth + sliderWidth / 2 + margin, 0, 0.01,
        sliderWidth, v.bounds.size.height, v.bounds.size.depth
    ))

    s.onValueChanged = function (sender, value)
        func(value, v)
    end
    s:minValue(min or 0)
    s:maxValue(max or 1)
    v:addSubview(s)
    v:addSubview(l)
    parent:addSubview(v)
    s.knob:setColor({0.1, 0.1, 0.7, 1})
    v.label = l
    v.slider = s
    s.knob.customSpecAttributes = {
        material = {
            metalness = 0,
            roughness = 1
        }
    }
    s.track.customSpecAttributes = {
        material = {
            metalness = 0.6,
            roughness = 0.6
        }
    }
    return v, s, l
end

function SkyList:populate()
    self.grid = self:addSubview(ui.GridView())
    self.grid.bounds = self.bounds:copy():insetEdges(0, 0, 0, self.bounds.size.height/2, 0, 0)

    local helpLabel = self:addSubview(ui.Label{
        bounds= ui.Bounds{size=ui.Size(1.5,0.04,0.01)}
            :move( self.bounds.size:getEdge("bottom", "center", "back") )
            :move( 0.10, -0.11, 0),
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

    self.grid.bounds = self.bounds:copy():insetEdges(0, 0, 0, self.bounds.size.height/2, 0, 0)


    ----------------------
    --- Light color
    ----------------------

    self.stack = self:addSubview(ui.StackView(
        self.bounds:copy():insetEdges(0, 0.3, self.bounds.size.height/2, 0, 0, 0),
        "v"
    ))
    self.stack:margin(0.01)

    self.stack:addSubview(Label({
        bounds = Bounds(0,0,0, self.stack.bounds.size.width,0.05,0),
        text = "Ambient light color",
        halign = "left",
    }))
    local max = 1
    local applySettings = function()
        local color = { self.r.slider:currentValue(), self.g.slider:currentValue(), self.b.slider:currentValue() }
        skies:setAmbientLightColor(color)
    end
    slider("White", 0, 0, self.stack, function(value, v)
        for i, slider in ipairs({self.r.slider, self.g.slider, self.b.slider}) do
            slider:currentValue(value)
        end
        applySettings()
    end, 0, max)
    self.r = slider("Red", 0, 0, self.stack, function (value, v)
        v.slider.track:setColor({value/v.slider:maxValue(), 0, 0, 1})
        applySettings()
    end, 0, max)
    self.g = slider("Green", 0, 0, self.stack, function (value, v)
        v.slider.track:setColor({0, value/v.slider:maxValue(), 0, 1})
        applySettings()
    end, 0, max)
    self.b = slider("Blue", 0, 0, self.stack, function (value, v)
        v.slider.track:setColor({0, 0, value/v.slider:maxValue(), 1})
        applySettings()
    end, 0, max)
    
    
    self:layout()
end

function SkyList:skyboxChanged()
    for name, desc in ipairs(skies.skyboxes) do
        local color = name == skies.currentSkyName and self.activeColor or self.inactiveColor
        local button = self.buttons[name]
        button:setColor(color)
    end

    local color = skies.ambientLightColor
    self.r.slider.track:setColor({color[1], 0, 0})
    self.g.slider.track:setColor({0, color[2], 0})
    self.b.slider.track:setColor({0, 0, color[3]})
end

function SkyList:layout()
    self.grid:layout()
    self.stack:layout()
end

return SkyList
