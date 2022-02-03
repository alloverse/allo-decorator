local ArcadeEnv = {}

local assets = {
    path = "envs/003-arcade/assets/",
    
    {name = "dome-12m-withdoor.glb", hasTransparency = true, pos={0,0,0}},
    {name = "arcade-centerpiece.glb", hasTransparency = false, pos={0,0,0}},

    --{name = "arcadesign.glb", hasTransparency = false, pos={12, 0, 0}, rot={3.14/2, 0,1,0}},

    {name = "houseplant01.glb", hasTransparency = false, pos={1, 0.1, 5}},
    {name = "houseplant01.glb", hasTransparency = false, pos={-2, 0.1, 5}},

    {name = "houseplant02.glb", hasTransparency = false, pos={1, 0.1, -5}},
    {name = "houseplant02.glb", hasTransparency = false, pos={-2, 0.1, -5}},

    {name = "houseplant03.glb", hasTransparency = false, pos={4.5, 0.1, 2.5}},
    {name = "houseplant03.glb", hasTransparency = false, pos={4.5, 0.1, -2.5}, rot={3.14/3, 0,1,0}}, 


    --{name = "NES.glb", hasTransparency = false,         pos={-4, 1, 0}},
    -- {name = "SNES.glb", hasTransparency = false,        pos={0, 0.1, 1}},
    -- {name = "Megadrive.glb", hasTransparency = false,   pos={0, 0.1, 2}},
}

local root = nil

function ArcadeEnv.load()
    if not root then
        root = ui.View()
        loadEnvAssets(root, assets)
        root.bounds.pose
            :rotate(-3.14/2, 0,1,0)
            :move(0, 0.01, -6.3)
    end
    app:addRootView(root)
end
function ArcadeEnv.unload()
    root:removeFromSuperview()
end

return ArcadeEnv
