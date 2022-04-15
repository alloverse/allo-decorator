function loadEnvAssets(root, assets)
  print("Loading the assets for env root", root)
  local views = {}
  -- Create assets and views for each
  for _, spec in ipairs(assets) do

    print("Drawing asset:", spec.name)

    local asset = ui.Asset.File(assets.path..spec.name)
    app.assetManager:add(asset, true)

    local view = nil
    if spec.name:match("glb$") then
    
      view = ui.ModelView(nil, asset)
      view.hasTransparency = spec.hasTransparency
      view.customSpecAttributes = {
          material = {
              shader_name = spec.shader or "pbr",
          }
      }

      if spec.backfaceCulling then
          view.customSpecAttributes.material.backfaceCulling = true
      end
    elseif spec.name:match("mp3$") then
      view = ui.Speaker(nil, asset)
      if spec.volume then
        view:setVolume(spec.volume)
      end
    end

    if spec.rot then
        view.bounds:rotate(unpack(spec.rot))
    end
    if spec.pos then
        view.bounds:move(unpack(spec.pos))
    end

    root:addSubview(view)
    views[spec.name] = view
  end
  return views
end
