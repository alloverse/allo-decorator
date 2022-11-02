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

    {name = "sounds/416489__tennysonmusic__ghostly-japanese-game-center-left.mp3", volume = 0.3, pos={-2.5, 0.1, 4.5}},
    {name = "sounds/416489__tennysonmusic__ghostly-japanese-game-center-right.mp3", volume = 0.3, pos={2.5, 0.1, -4.5}},

    {name = "sounds/460119__nickmaysoundmusic__air-hockey-arcade-ambience-distant-music-left.mp3", volume = 0.5, pos={-2.5, 0.1, 4.5}},
    {name = "sounds/460119__nickmaysoundmusic__air-hockey-arcade-ambience-distant-music-right.mp3", volume = 0.5, pos={-2.5, 0.1, -4.5}},

    {name = "sounds/gold-saucer-left.mp3", volume = 0.1, pos={-2.5, 0.1, 4.5}},
    {name = "sounds/gold-saucer-right.mp3", volume = 0.1, pos={-2.5, 0.1, -4.5}},
}

local root = nil
local apps = {}

function ArcadeEnv.load()
    if not root then
        root = ui.View()
        local views = loadEnvAssets(root, assets)

        -- Add a red carpet leading to the dome
        local carpetTextureAsset = ui.Asset.File("envs/003-arcade/assets/textures/red-carpet-tiled.png")
        app.assetManager:add(carpetTextureAsset, true)

        local redCarpet = ui.Surface(ui.Bounds( {size=ui.Size(10, 3.6, 0.001), pose=ui.Pose(10,0.1,0) }):rotate(-3.14/2, 1, 0, 0))
        redCarpet:setColor({0.8, 0, 0, 1})
        redCarpet:setTexture(carpetTextureAsset)
        root:addSubview(redCarpet)

        local volumeSlider = root:addSubview(ui.Slider(ui.Bounds(0.5, 0.13, -5.8,  0.45, 0.1, 0.1)))
        volumeSlider.track.color = { 106/255, 42/255, 84/255, 1}
        volumeSlider.knob.color = { 0, 0, 0, 1}
        volumeSlider:minValue(0.0)
        volumeSlider:maxValue(1.0)
        volumeSlider:currentValue(0.1)
        volumeSlider.activate = function(slider, sender, v)
            local left = views["sounds/gold-saucer-left.mp3"]
            local right = views["sounds/gold-saucer-right.mp3"]
            left:setVolume(v)
            right:setVolume(v)
        end
        
        root.bounds.pose
            :rotate(-3.14/2, 0,1,0)
            :move(0, 0.01, -12)
    end

    loadEnvApps(apps, {
        {
            url= "alloapp:http://localhost:8000/flynncade",
            pose=ui.Pose():rotate(3.14*0.11, 0,1,0):move(-1.6, 0, -11.3),
            args= {console="SNES", game="sf2t"}
        },
        {
            url= "alloapp:http://localhost:8000/flynncade",
            pose=ui.Pose():rotate(-3.14*0.11, 0,1,0):move( 2.10, 0, -11.3),
            args= {console="NES", game="spaceinv"}
        }
    })


    app:addRootView(root)

end
function ArcadeEnv.unload()
    root:removeFromSuperview()
    unloadEnvApps(apps)
end

return ArcadeEnv
