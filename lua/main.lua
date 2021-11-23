local vec3 = require("modules.vec3")
local mat4 = require("modules.mat4")
local json = require "allo.json"
local Frame = require("frame")

local client = Client(
    arg[2], 
    "allo-decorator"
)

function readfile(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local s = f:read("*a")
    f:close()
    return s
end



local app = App(client)

local decorations = {} -- [name: asset]
local p = io.popen('find gallery/* -maxdepth 0')
for decoPath in p:lines() do
    local infojsonstr = readfile(decoPath.."/info.json")
    if infojsonstr then
        print("Decorator adding asset "..decoPath)
        local deco = {
            path= decoPath,
            meta= json.decode(infojsonstr),
            asset= ui.Asset.File(decoPath.."/asset.glb"),
            icon= ui.Asset.File(decoPath.."/icon.glb")
        }
        decorations[decoPath] = deco
        app.assetManager:add(deco.asset)
        app.assetManager:add(deco.icon)
    end
end
p:close()


assets = {
    quit = ui.Asset.File("images/quit.png"),
}
app.assetManager:add(assets)

-- Used to show the icon for the decoration, and is drag'n'droppable to place
-- the asset in the world.
class.DecoProxyView(ui.ProxyIconView)
-- desc: table like:
-- {
--     path= str,
--     meta= {
--         display_name= str,
--     },
--     asset= ui.Asset.File,
--     icon= ui.Asset.File,
-- }
function DecoProxyView:_init(bounds, desc)
    self:super(bounds, desc.meta.display_name, desc.icon)
    self.desc = desc
    self.grabOptions = {
        rotation_constraint= {0, 1, 0},
    }
end

function DecoProxyView:onIconDropped(pos, oldIcon)
    local bounds = ui.Bounds{
        pose= ui.Pose(pos),
        size= ui.Size(unpack(self.desc.meta.size))
    }
    local deco = DecoView(bounds, self.desc.asset)
    self.app:addRootView(deco)
    
    
    deco:doWhenAwake(function()
        deco:addPropertyAnimation(ui.PropertyAnimation{
            path= "transform.matrix.scale",
            from= {0,0,0},
            to=   {1,1,1},
            duration = 0.4,
            easing= "elasticOut"
        })
    end)

    return true
end

-- The actual asset as shown in the place once dropped
class.DecoView(ui.ModelView)
function DecoView:_init(bounds, asset)
    self:super(bounds, asset)
    self.grabbable = true
    self.grabOptions = {
        rotation_constraint= {0, 1, 0},
    }
end

function DecoView:onTouchDown(pointer)
    local settings = ui.Cube(ui.Bounds(0,0,0,  0.5, 0.5, 0.1))
    settings:setGrabbable(true)
    settings.color = { 34/255, 195/255, 181/255, 1}
    local scaleSlider = settings:addSubview(ui.Slider(ui.Bounds(0, 0.13, 0.05,  0.45, 0.1, 0.1)))
    scaleSlider.track.color = { 24/255, 175/255, 161/255, 1}
    scaleSlider:minValue(0.1)
    scaleSlider:maxValue(2.0)
    scaleSlider:currentValue(1.0)
    scaleSlider.activate = function(slider, sender, v)
        self:setTransform(mat4.scale(mat4.identity(), mat4.identity(), vec3(v, v, v)))
    end

    local alignButton = settings:addSubview(ui.Button(ui.Bounds(0,  -0.01, 0.05,  0.45, 0.1, 0.1)))
    alignButton:setColor({ 24/255, 175/255, 161/255, 1})
    alignButton.label:setText("Align")
    alignButton.onActivated = function(hand)
        local transform = self:transformFromParent()
        local position = transform * vec3(0,0,0)
        local unrotatedTransform = mat4.translate(mat4.identity(), mat4.identity(), position)
        local newPose = ui.Pose(unrotatedTransform)
        self.bounds.pose = newPose
        self:setTransform(mat4.identity())
    end
    
    local removeButton = settings:addSubview(ui.Button(ui.Bounds(0, -0.15, 0.05,  0.45, 0.1, 0.1)))
    removeButton.label:setText("Remove")
    removeButton.onActivated = function(hand)
        self:removeFromSuperview()
        settings:removeFromSuperview()
    end

    local cancelButton = settings:addSubview(ui.Button(
    ui.Bounds{size=ui.Size(0.12,0.12,0.05)}
        :move( settings.bounds.size:getEdge("top", "right", "front") )
    ))
    cancelButton:setDefaultTexture(assets.quit)
    cancelButton.onActivated = function()
        settings:removeFromSuperview()
    end
    self.app:openPopupNearHand(settings, pointer.hand, 0.8)
end



local columnCount = 3
local rowCount = math.max(math.ceil(#decorations/columnCount), 1)

local mainView = Frame(
    ui.Bounds(0,0,0, 1.5, rowCount*0.5 + 0.12, 0.06)
        :rotate(3.14159/2, 0,1,0)
        :move(-3, 1.6, 2.2),
    0.03
)
mainView:setColor({ 34/255, 195/255, 181/255, 1})
mainView.grabbable = true

local titleLabel = mainView:addSubview(ui.Label{
    bounds= ui.Bounds{size=ui.Size(1.5,0.10,0.01)}
        :move( mainView.bounds.size:getEdge("top", "center", "back") )
        :move( 0, 0.06, 0),
    text= "Allo Decorator",
    halign= "left",
})

local helpLabel = mainView:addSubview(ui.Label{
    bounds= ui.Bounds{size=ui.Size(1.5,0.06,0.01)}
        :move( mainView.bounds.size:getEdge("bottom", "center", "back") )
        :move( 0, -0.10, 0),
    text= "Grab an asset (grip button or right mouse button) \nand drop it somewhere to place it.",
    halign= "left",
    color={0.6, 0.6, 0.6, 1}
})

local grid = mainView:addSubview(
    ui.GridView(ui.Bounds{size=mainView.bounds.size:copy()}:insetEdges(0.06, 0.06, 0.06, 0.06, 0, 0))
)

local itemSize = grid.bounds.size:copy()
itemSize.width = itemSize.width / columnCount
itemSize.height = itemSize.height / rowCount

for _, desc in pairs(decorations) do
    local DecoProxyView = grid:addSubview(
        DecoProxyView(ui.Bounds{size=itemSize:copy()}, desc)
    )
    DecoProxyView.brick:setColor({ 34/255, 195/255, 181/255, 0.3})
end
grid:layout()


local quitButton = mainView:addSubview(ui.Button(
    ui.Bounds{size=ui.Size(0.12,0.12,0.05)}
        :move( mainView.bounds.size:getEdge("top", "right", "front") )
))
quitButton:setDefaultTexture(assets.quit)
quitButton.onActivated = function()
    app:quit()
end

app.mainView = mainView

app:connect()
app:run()
