local NoEnv = {}

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

function load(root, assets)
    -- Create assets and views for each
    for _, spec in ipairs(assets) do
        local asset = ui.Asset.File(assets.path..spec.name)
        app.assetManager:add(asset, true)

        local view = ui.ModelView(nil, asset)
        view.hasTransparency = spec.hasTransparency
        view.customSpecAttributes = {
            material = {
                shader_name = spec.shader or "pbr",
            }
        }

        if spec.backfaceCulling then
            view.customSpecAttributes.material.backfaceCulling = true
        end
        root:addSubview(view)
    end
end

local root = ui.View()

function NoEnv.load()
    load(root, house)
    load(root, decorations)

    root.bounds.pose:move(0, 0.01, 0)

    -- Something fun for the TV
    local tvScreen = ui.Surface(ui.Bounds(0, 0, 0,  1.29, 0.76, 0.01):rotate(-3.141/2, 0,1,0):move(12.59, 1.12, -2.895))
    local teamImage = ui.Asset.File("envs/002-house/assets/alloteam.jpg")
    app.assetManager:add(teamImage)
    tvScreen:setTexture(teamImage)
    root:addSubview(tvScreen)

    app:addRootView(root)
end
function NoEnv.unload()
    root:removeFromSuperview()
end

return NoEnv
