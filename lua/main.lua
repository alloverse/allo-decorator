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

function DecoProxyView:onIconDropped(pos)
    local bounds = ui.Bounds{
        pose= ui.Pose(pos),
        size= ui.Size(unpack(self.desc.meta.size))
    }
    local deco = DecoView(bounds, self.desc.asset)
    self.app:addRootView(deco)
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

function DecoView:onTouchDown()
    self:removeFromSuperview()
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
