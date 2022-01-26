-- Used to show the icon for the decoration, and is drag'n'droppable to place
-- the asset in the world.
class.DecoProxyView(ui.ProxyIconView)
-- desc: table like:
-- {
--     path= str,
--     meta= {
--         display_name= str,
--     },
--     asset= ui.Asset.File,
--     icon= ui.Asset.File,
-- }
function DecoProxyView:_init(bounds, desc)
    self:super(bounds, desc.meta.display_name, desc.icon)
    self.desc = desc
    self.grabOptions = {
        rotation_constraint= {0, 1, 0},
    }
end

function DecoProxyView:onIconDropped(pos, oldIcon)
    local bounds = ui.Bounds{
        pose= ui.Pose(pos),
        size= ui.Size(unpack(self.desc.meta.size))
    }
    local deco = DecoView(bounds, self.desc.asset)
    if self.desc.hasTransparency then
        deco.hasTransparency = true
    end
    self.app:addRootView(deco)
    
    
    deco:doWhenAwake(function()
        deco:addPropertyAnimation(ui.PropertyAnimation{
            path= "transform.matrix.scale",
            from= {0,0,0},
            to=   {1,1,1},
            duration = 0.4,
            easing= "elasticOut"
        })
    end)

    return true
end

return DecoProxyView
