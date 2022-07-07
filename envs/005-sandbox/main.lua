local SandboxEnv = {}

local root = nil

function SandboxEnv.load()
    if not root then
        root = ui.View()
        
        root.bounds.pose:move(0, 0.01, 0)

        -- adds a floor to the place
        local floorplate = ui.Surface(ui.Bounds(0,0,0, 16, 16, 0.001):rotate(-3.1412/2, 1, 0, 0))
        
        -- sets the texture of the floorplate to be assets/floor.png
        --floorplate.material.texture = ui.Asset.File("assets/floor.png")

        local floorTexture = ui.Asset.File("envs/005-sandbox/assets/floor.png")
        app.assetManager:add(floorTexture)
        floorplate:setTexture(floorTexture)
        


        root:addSubview(floorplate)

    end
    app:addRootView(root)
end
function SandboxEnv.unload()
    root:removeFromSuperview()
end

return SandboxEnv
