local ArcadeEnv = {}

local assets = {
    path = "envs/003-arcade/assets/",
    
    {name = "dome.glb", hasTransparency = true, pos={0,0,0}},
    --{name = "arcadesign.glb", hasTransparency = false, pos={15, 0, 0}, rot={3.14/2, 0,1,0}},
}


local root = nil

function ArcadeEnv.load()
    if not root then
        root = ui.View()
        loadEnvAssets(root, assets)
        root.bounds.pose:move(0, 0.01, 0)
    end
    app:addRootView(root)
end
function ArcadeEnv.unload()
    root:removeFromSuperview()
end

return ArcadeEnv
