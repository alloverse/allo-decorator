local json = require "allo.json"

class.DecorationsGridView(ui.View)

function DecorationsGridView:_init(bounds)
    self:super(bounds)
    self.grid = self:addSubview(ui.GridView())
end

function DecorationsGridView:populate()
    self.grid.bounds = self.bounds:copy():insetEdges(0, 0, 0, self.bounds.size.height/2, 0, 0)

    local helpLabel = self:addSubview(ui.Label{
        bounds= ui.Bounds{size=ui.Size(1.5,0.04,0.01)}
            :move( self.bounds.size:getEdge("bottom", "center", "back") )
            :move( 0.10, 0.05, 0),
        text= "Grab an asset (grip button or right mouse button) \nand drop it somewhere to place it.",
        halign= "left",
        color={0.6, 0.6, 0.6, 1}
    })

    self.decorations = {}
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
            table.insert(self.decorations, deco)
            app.assetManager:add(deco.asset)
            app.assetManager:add(deco.icon)
        end
    end
    p:close()

    local columnCount = 3
    local rowCount = math.max(math.ceil(#self.decorations/columnCount), 1)
    local itemSize = self.grid.bounds.size:copy()
    itemSize.width = itemSize.width / columnCount
    itemSize.height = itemSize.height / rowCount
    
    for _, desc in ipairs(self.decorations) do
        local proxy = self.grid:addSubview(
            DecoProxyView(ui.Bounds{size=itemSize:copy()}, desc)
        )
        proxy.brick:setColor({ 34/255, 195/255, 181/255, 0.3})
    end
    self.grid:layout()
end

return DecorationsGridView
