local json = require "allo.json"

class.DecorationsGridView(ui.GridView)

function DecorationsGridView:_init(bounds)
    self:super(bounds)
end

function DecorationsGridView:populate()
    self.decorations = {} -- [name: asset]
    local p = io.popen('find gallery/* -maxdepth 0')
    for decoPath in p:lines() do
        local infojsonstr = readfile(decoPath.."/info.json")
        if infojsonstr then
            print("Decorator adding asset "..decoPath)
            local deco = {
                path= decoPath,
                meta= json.decode(infojsonstr),
                asset= ui.Asset.File(decoPath.."/asset.glb"),
                icon= ui.Asset.File(decoPath.."/icon.glb")
            }
            self.decorations[decoPath] = deco
            app.assetManager:add(deco.asset)
            app.assetManager:add(deco.icon)
        end
    end
    p:close()

    local columnCount = 3
    local rowCount = math.max(math.ceil(#self.decorations/columnCount), 1)
    local itemSize = self.bounds.size:copy()
    itemSize.width = itemSize.width / columnCount
    itemSize.height = itemSize.height / rowCount
    
    for _, desc in pairs(self.decorations) do
        local DecoProxyView = self:addSubview(
            DecoProxyView(ui.Bounds{size=itemSize:copy()}, desc)
        )
        DecoProxyView.brick:setColor({ 34/255, 195/255, 181/255, 0.3})
    end
    self:layout()
end

return DecorationsGridView
