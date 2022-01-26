local vec3 = require("modules.vec3")
local mat4 = require("modules.mat4")
local Frame = require("frame")
local DecoView = require("decoview")
local DecoProxyView = require("decoproxy")
local DecorationsGridView = require("decolist")
local EnvList = require("envlist")
local EnvManager = require("envmanager")
local SkyList = require("skylist")
local SkyManager = require("skymanager")
require("env")

local makeWidgetButton = require("widget")

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

app = App(client)


assets = {
    quit = ui.Asset.File("images/quit.png"),
    widget = ui.Asset.File("images/widget.png"),
    icon = ui.Asset.File("icon.glb")
}
app.assetManager:add(assets)

envs = EnvManager()
envs:selectEnvironment(2)
skies = SkyManager(app)
skies:setAmbientLightColor({0.5, 0.5, 0.5})


function makeMainUI()
    local mainView = Frame(
        ui.Bounds(0,0,0,   1.5, 2*0.5 + 0.12, 0.06),
        0.03
    )
    mainView:setColor({ 34/255, 195/255, 181/255, 1})

    local tabs = mainView:addSubview(
        ui.TabView(mainView.bounds:copy():insetEdges(0.10, 0.10, 0.06, 0.06, -0.02, 0))
    )
    
    -- First tab: list of decorations
    local grid = tabs:addTab("Decorations", DecorationsGridView())
    grid:populate()    

    -- Second tab: list of environments
    local envlist = tabs:addTab("Environments", EnvList())
    envlist:populate()

    -- Third tab: list of skies
    local skylist = tabs:addTab("Skies", SkyList())
    skylist:populate()

    return mainView
end


local mainView = makeMainUI()
mainView.bounds:rotate(3.14159/2, 0,1,0):move(-3, 1.6, 2.4)
mainView.grabbable = true

-- Extra UI that only goes for the big UI, not for the widget version
local titleLabel = mainView:addSubview(ui.Label{
    bounds= ui.Bounds{size=ui.Size(1.5,0.10,0.01)}
        :move( mainView.bounds.size:getEdge("top", "center", "back") )
        :move( 0, 0.06, 0),
    text= "Allo Decorator",
    halign= "left",
})

local quitButton = mainView:addSubview(ui.Button(
    ui.Bounds{size=ui.Size(0.12,0.12,0.05)}
        :move( mainView.bounds.size:getEdge("top", "right", "front") )
))
quitButton:setDefaultTexture(assets.quit)
quitButton.onActivated = function()
    app:quit()
end


local widgetBounds = ui.Bounds{size=ui.Size(0.12,0.12,0.05)}
    :move( mainView.bounds.size:getEdge("top", "right", "front") )
    :move( -0.22, 0, 0)
mainView:addSubview(makeWidgetButton(app, widgetBounds, makeMainUI))

app.mainView = mainView

app:connect()
app:run()
