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

function loadEnvApps(apps, descs)
  for i, desc in ipairs(descs) do
    app.client:launchApp(desc.url, desc.pose, desc.args, function(ok, errOrId)
      if not ok then
        print("Failed to launch env app:", errOrId)
      else
        table.insert(apps, errOrId)
      end
    end)
  end
  
end

function unloadEnvApps(apps)
  for i, aid in ipairs(apps) do
    print("Asking app", aid, "to quit")
    app.client:sendInteraction({
      receiver_entity_id = aid,
      body = {
          "quit"
      }
    }, function(resp, body)
      if body[2] ~= "ok" then
        print("Failed to quit env app: ", body[3])
      end
    end)
  end
end
