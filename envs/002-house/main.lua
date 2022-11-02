local HouseEnv = {}

-- All the assets
local house = {
    path = "envs/002-house/assets/house/",
    
    -- Walls
    {name = "house_shell_sidewings_v06.glb", },
    {name = "bkd_carpet_main room.glb", },
    {name = "bkd_main room_shell.glb", },
    
    -- Transparent details are limited to same-plane surfaces as we can only sort by model, 
    -- so here's all the windows of the house
    {name = "windows_facade_back.glb", hasTransparency = true, },
    {name = "windows_facade_front-door01.glb", hasTransparency = true, },
    {name = "windows_facade_front-door02.glb", hasTransparency = true, },
    {name = "windows_facade_front.glb", hasTransparency = true, },
    {name = "windows_front_01 v2.glb", hasTransparency = true, },
    {name = "windows_front_01-open.glb", hasTransparency = true, },
    {name = "windows_front_door01.glb", hasTransparency = true, },
    {name = "windows_front_door02.glb", hasTransparency = true, },
    {name = "windows_wingL_01.glb", hasTransparency = true, },
    {name = "windows_wingL_02.glb", hasTransparency = true, },
    {name = "windows_wingR_01.glb", hasTransparency = true, },
    {name = "windows_wingR_02.glb", hasTransparency = true, },
    {name = "bkd_balcony_backGlass_ext.glb", hasTransparency = true, },
    {name = "bkd_balcony_sideGlass_ext.glb", hasTransparency = true, },
    {name = "bkd_balcony_sideGlass_int.glb", hasTransparency = true, },
}


local decorations = {
    path = 'envs/002-house/assets/decorations/',

    -- {name = "chandelier.glb", hasTransparency = true },
    {name = "tv_TV_stand_v05.glb",  },
    {name = "wall_divider_with_plants_v05.glb",  },
    {name = "plants_pot_floor_v05.glb",  },
    {name = "podium_v05.glb",  },
    {name = "lamp_v02.glb", hasTransparency = true },
    {name = "bkd_chairs conf table.glb",  },
    {name = "bkd_coffee_table.glb",  },
    {name = "couch01_v05.glb",  },
    {name = "couch02_v05.glb",  },
    {name = "couch_chairs_v05.glb",  },
    {name = "couch_wall_v05.glb",  },
}

local root = nil
local apps = {}

function HouseEnv.load()
    if not root then
        root = ui.View()
        loadEnvAssets(root, house)
        loadEnvAssets(root, decorations)
        root.bounds.pose:move(0, 0.01, 0)

        -- Something fun for the TV
        local tvScreen = ui.Surface(ui.Bounds(0, 0, 0,  1.29, 0.76, 0.01):rotate(-3.141/2, 0,1,0):move(12.59, 1.12, -2.895))
        local teamImage = ui.Asset.File("envs/002-house/assets/alloteam.jpg")
        app.assetManager:add(teamImage)
        tvScreen:setTexture(teamImage)
        root:addSubview(tvScreen)
    end

    loadEnvApps(apps, {
        {
            url= "alloapp:http://localhost:8000/allo-clock",
            pose=ui.Pose():rotate(3.14*0.5, 0,1,0):rotate(-0.35, 0,0,1):move(-2.4, 3.4, -3.0),
            args= {}
        },
    })
    
    app:addRootView(root)
end
function HouseEnv.unload()
    root:removeFromSuperview()
    unloadEnvApps(apps)
end

return HouseEnv
