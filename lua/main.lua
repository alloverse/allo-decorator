local vec3 = require("modules.vec3")
local mat4 = require("modules.mat4")
local json = require "allo.json"
local Frame = require("frame")

local client = Client(
    arg[2], 
    "allo-decorator"
)


local app = App(client)

local decorations = {} -- [name: asset]
local p = io.popen('find gallery/* -maxdepth 0')
for decoPath in p:lines() do
    print("Decorator adding asset "..decoPath)
    local asset = ui.Asset.File(decoPath)
    decorations[decoPath] = {
        name= decoPath,
        asset= asset
    }
    app.assetManager:add(asset)
end
p:close()


assets = {
    quit = ui.Asset.File("images/quit.png"),
}
app.assetManager:add(assets)

class.DecoView(ui.ProxyIconView)
function DecoView:_init(bounds, desc)
    self:super(bounds, desc.name, desc.asset)
    self.desc = desc
end

function DecoView:onIconDropped(pos)
    -- todo
end



local columnCount = 3
local rowCount = math.max(math.ceil(#decorations/columnCount), 1)
print("YOOO", rowCount)
local mainView = Frame(
    ui.Bounds(0,0,0, 1.5, rowCount*0.4, 0.06)
        :rotate(3.14159/2, 0,1,0)
        :move(-3, 1.6, 0.5),
    0.03
)
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
    text= "Grab an asset (grip button or right mouse button) and drop it somewhere to place it.",
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
    local decoView = grid:addSubview(
        DecoView(ui.Bounds{size=itemSize:copy()}, desc)
    )
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
