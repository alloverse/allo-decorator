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
skies = SkyManager(app)

function setDefaultEnvironment()
  local presets = {
    ["alloplace://sandbox.places.alloverse.com:21337"] = {
      sky = "devsandbox",
      environmentIndex = 5,
      ambientLightColor = {0.4, 0.4, 0.4}
    },
    ["alloplace://arcade.places.alloverse.com:21337"] = {
      sky = "blueishnight",
      environmentIndex = 3,
      ambientLightColor = {0.5, 0.5, 0.5},
    },
  }
  
  local preset = presets[client.url]
  if preset ~= nil then
      print("==== Preset found for", client.url)
      skies:setAmbientLightColor(preset.ambientLightColor)
      envs:selectEnvironment(preset.environmentIndex)
      skies:useSky(preset.sky)
  else
      print("==== No preset found for", client.url)
      skies:setAmbientLightColor({0.5, 0.5, 0.5})
      envs:selectEnvironment(1)
      skies:useSky("sunset")
  end
end
app.onConnected = setDefaultEnvironment


function makeMainUI()
    local mainView = Frame(
        ui.Bounds(0,0,0,   1.5, 2*0.5 + 0.12, 0.06),
        0.03
    )
    mainView:setColor(Color.alloLightPink())

    frameBg = ui.Surface(mainView.bounds:copy():move(0, 0, -mainView.bounds.size.depth/2)) --move the background surface backwards so it lines up with the b
    frameBg:setColor(Color.alloDark())
    mainView:addSubview(frameBg)

    local tabs = mainView:addSubview(
        ui.TabView(
          mainView.bounds:copy():insetEdges(0.03, 0.03, 0.03, 0, -0.02, 0),
          0,
          Color.alloLightGray(),
          Color.alloWhite()
        )
    )
    
    -- First tab: list of decorations
    local grid = tabs:addTab("Decorations", DecorationsGridView())
    grid:populate()

    -- Second tab: list of environments
    local envlist = tabs:addTab("Templates", EnvList())
    envlist:populate()

    -- Third tab: list of skies
    local skylist = tabs:addTab("Skies", SkyList())
    skylist:populate()

    tabs:switchToTabIndex(2)

    return mainView
end


local mainView = makeMainUI()
mainView.bounds:rotate(3.14159/2, 0,1,0):move(-3, 1.6, 2.4)

-- Extra UI that only goes for the big UI, not for the widget version
local titleLabel = mainView:addSubview(ui.Label{
    bounds= ui.Bounds{size=ui.Size(1.5,0.10,0.01)}
        :move( mainView.bounds.size:getEdge("top", "center", "back") )
        :move( 0, 0.06, 0),
    text= "Decorator",
    halign= "left",
})

local quitButton = mainView:addSubview(ui.Button(
    ui.Bounds{size=ui.Size(0.12,0.12,0.05)}
        :move( mainView.bounds.size:getEdge("top", "right", "front") )
        :move( -0.06, 0.06, 0)
))
quitButton:setDefaultTexture(assets.quit)
quitButton.onActivated = function()
    app:quit()
end


local widgetBounds = ui.Bounds{size=ui.Size(0.12,0.12,0.05)}
    :move( mainView.bounds.size:getEdge("top", "right", "front") )
    :move( -0.22, 0.06, 0)
mainView:addSubview(makeWidgetButton(app, widgetBounds, makeMainUI))

app.mainView = mainView

app.onBeforeQuit = function()
    -- to quit apps etc
    envs:selectEnvironment(1)
    app:runFor(0.2)
end

app:connect()
app:run()
