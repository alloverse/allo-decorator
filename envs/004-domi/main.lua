local DomiEnv = {}

local assets = {
    path = "envs/004-domi/assets/",
    
    {name = "dome.glb", hasTransparency = true},
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

local root = nil
local apps = {}

function DomiEnv.load()
    if not root then
        root = ui.View()
        load(root, assets)
        root.bounds.pose:move(0, 0.01, 0)
    end

    loadEnvApps(apps, {
        {
            url= "alloapp:http://localhost:8000/allo-fileviewer",
            pose=ui.Pose():rotate(3.14*0.15, 0,1,0):move(-2.0, 2, -3.0),
            args= {}
        },
        {
            url= "alloapp:http://localhost:8000/allo-fileviewer",
            pose=ui.Pose():rotate(-3.14*0.05, 0,1,0):move(2.0, 2, -3.5),
            args= {}
        },
        {
            url= "alloapp:http://localhost:8000/allo-whiteboard",
            pose=ui.Pose():rotate(-3.14*0.25, 0,1,0):move(4.8, 2, -1.5),
            args= {}
        },
        {
            url= "alloapp:http://localhost:8000/allo-todo",
            pose=ui.Pose():rotate(-3.14*0.5, 0,1,0):move(5.5, 1.3, 1.0),
            args= {}
        },
    })

    app:addRootView(root)
end
function DomiEnv.unload()
    unloadEnvApps(apps)
    root:removeFromSuperview()
end

return DomiEnv
