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

function DomiEnv.load()
    if not root then
        root = ui.View()
        load(root, assets)
        root.bounds.pose:move(0, 0.01, 0)
    end
    app:addRootView(root)
end
function DomiEnv.unload()
    root:removeFromSuperview()
end

return DomiEnv
