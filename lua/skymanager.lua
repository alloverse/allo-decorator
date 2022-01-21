class.Environment(View)
function Environment:_init(bounds)
    bounds = bounds or Bounds(0,0,0,10,10,10)
    self:super(bounds)
    self.effectCube = Cube(Bounds({size = self.bounds.size:copy(), pose = Pose()}))
    self.effectCube:setColor({1, 1, 1, 0.1})
    self.bounds.size = self.effectCube.bounds.size
    -- self.effectCube.hasCollider = true

    self.ambientLight = {0.5, 0.5, 0.5}
    self.skybox = nil
    -- self:addSubview(self.effectCube)
end

function Environment:setSkybox(skybox)
    local box = {}
    for side,asset in pairs(skybox) do
        box[side] = asset:id()
    end
    self.skybox = box
    self:markAsDirty("environment")
end

function Environment:specification()
    local spec = View.specification(self)
    spec.environment = {
        ambient = {
            light = {
                color = self.ambientLight
            }
        }
    }
    if self.skybox then
        spec.environment.skybox = self.skybox
    end
    return spec
end

class.SkyManager()
function SkyManager:_init(app)
    self.env = Environment()
    self.listeners = {}
    self.skyboxes = {
        sunset = {
            left = ui.Asset.File('skies/sunset/left.png'),
            right = ui.Asset.File('skies/sunset/right.png'),
            top = ui.Asset.File('skies/sunset/top.png'),
            bottom = ui.Asset.File('skies/sunset/bottom.png'),
            back = ui.Asset.File('skies/sunset/back.png'),
            front = ui.Asset.File('skies/sunset/front.png'),
        },
        sakura = {
            left = ui.Asset.File('skies/sakura/left.png'),
            right = ui.Asset.File('skies/sakura/right.png'),
            top = ui.Asset.File('skies/sakura/top.png'),
            bottom = ui.Asset.File('skies/sakura/bottom.png'),
            back = ui.Asset.File('skies/sakura/back.png'),
            front = ui.Asset.File('skies/sakura/front.png'),
        },
        blueishnight = {
            left = ui.Asset.File('skies/blueishnight/left.png'),
            right = ui.Asset.File('skies/blueishnight/right.png'),
            top = ui.Asset.File('skies/blueishnight/top.png'),
            bottom = ui.Asset.File('skies/blueishnight/bottom.png'),
            back = ui.Asset.File('skies/blueishnight/back.png'),
            front = ui.Asset.File('skies/blueishnight/front.png'),
          }
    }
    app:addRootView(self.env)
    app.assetManager:add(self.skyboxes.sunset, true)
    app.assetManager:add(self.skyboxes.sakura, true)
end

function SkyManager:useSky(name)
    self.currentSkyName = name
    self.env:setSkybox(self.skyboxes[name])
    for i, l in ipairs(self.listeners) do
        l:skyboxChanged()
    end
end

return SkyManager
