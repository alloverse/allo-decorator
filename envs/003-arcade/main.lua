local ArcadeEnv = {}

local assets = {
    path = "envs/003-arcade/assets/",
    
    {name = "dome-12m-withdoor.glb", hasTransparency = true, pos={0,0,0}},
    {name = "arcade-centerpiece.glb", hasTransparency = false, pos={0,0,0}},

    {name = "arcade-sign.glb", hasTransparency = false, pos={6, 3.2, 0}, rot={3.14/2, 0,1,0}},

    {name = "houseplant01.glb", hasTransparency = false, pos={1, 0.1, 5}},
    {name = "houseplant01.glb", hasTransparency = false, pos={-2, 0.1, 5}},

    {name = "houseplant02.glb", hasTransparency = false, pos={1, 0.1, -5}},
    {name = "houseplant02.glb", hasTransparency = false, pos={-2, 0.1, -5}},

    {name = "houseplant03.glb", hasTransparency = false, pos={4.5, 0.1, 2.5}},
    {name = "houseplant03.glb", hasTransparency = false, pos={4.5, 0.1, -2.5}, rot={3.14/3, 0,1,0}}, 

    {name = "sounds/416489__tennysonmusic__ghostly-japanese-game-center-left.mp3", volume = 0.3, pos={2.5, 0.1, 4.5}},
    {name = "sounds/416489__tennysonmusic__ghostly-japanese-game-center-right.mp3", volume = 0.3, pos={2.5, 0.1, -4.5}},

    {name = "sounds/460119__nickmaysoundmusic__air-hockey-arcade-ambience-distant-music-left.mp3", volume = 0.5, pos={-2.5, 0.1, 4.5}},
    {name = "sounds/460119__nickmaysoundmusic__air-hockey-arcade-ambience-distant-music-right.mp3", volume = 0.5, pos={-2.5, 0.1, -4.5}},
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

    -- Add a red carpet leading to the dome
    local redCarpet = ui.Surface(ui.Bounds( {size=ui.Size(10, 2, 0.001), pose=ui.Pose(10,0,0) }):rotate(-3.14/2, 1, 0, 0))
    local carpetTextureAsset = ui.Asset.File("envs/003-arcade/assets/textures/red-carpet-tiled.png")

    print("asset:", carpetTextureAsset)

    redCarpet:setColor({0.8, 0, 0, 1})
    redCarpet:setTexture(carpetTextureAsset)

    root:addSubview(redCarpet)

end
function ArcadeEnv.unload()
    root:removeFromSuperview()
end

return ArcadeEnv
