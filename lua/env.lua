function loadEnvAssets(root, assets)
    print("Loading the assets for env root", root)
    -- Create assets and views for each
    for _, spec in ipairs(assets) do

      print("Drawing asset:", spec.name)

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
      if spec.rot then
          view.bounds:rotate(unpack(spec.rot))
      end
      if spec.pos then
          view.bounds:move(unpack(spec.pos))
      end

      root:addSubview(view)
    end
end