
-- The actual asset as shown in the place once dropped
class.DecoView(ui.ModelView)
function DecoView:_init(bounds, asset)
    self:super(bounds, asset)
    self.grabbable = true
    self.grabOptions = {
        rotation_constraint= {0, 1, 0},
    }
end

function DecoView:onTouchDown(pointer)
    local settings = ui.Cube(ui.Bounds(0,0,0,  0.5, 0.5, 0.1))
    settings:setGrabbable(true)
    settings.color = { 34/255, 195/255, 181/255, 1}
    local scaleSlider = settings:addSubview(ui.Slider(ui.Bounds(0, 0.13, 0.05,  0.45, 0.1, 0.1)))
    scaleSlider.track.color = { 24/255, 175/255, 161/255, 1}
    scaleSlider:minValue(0.1)
    scaleSlider:maxValue(2.0)
    scaleSlider:currentValue(1.0)
    scaleSlider.activate = function(slider, sender, v)
        self:setTransform(mat4.scale(mat4.identity(), mat4.identity(), vec3(v, v, v)))
    end

    local alignButton = settings:addSubview(ui.Button(ui.Bounds(0,  -0.01, 0.05,  0.45, 0.1, 0.1)))
    alignButton:setColor({ 24/255, 175/255, 161/255, 1})
    alignButton.label:setText("Align")
    alignButton.onActivated = function(hand)
        local transform = self:transformFromParent()
        local position = transform * vec3(0,0,0)
        local unrotatedTransform = mat4.translate(mat4.identity(), mat4.identity(), position)
        local newPose = ui.Pose(unrotatedTransform)
        self.bounds.pose = newPose
        self:setTransform(mat4.identity())
    end
    
    local removeButton = settings:addSubview(ui.Button(ui.Bounds(0, -0.15, 0.05,  0.45, 0.1, 0.1)))
    removeButton.label:setText("Remove")
    removeButton.onActivated = function(hand)
        self:removeFromSuperview()
        settings:removeFromSuperview()
    end

    local cancelButton = settings:addSubview(ui.Button(
    ui.Bounds{size=ui.Size(0.12,0.12,0.05)}
        :move( settings.bounds.size:getEdge("top", "right", "front") )
    ))
    cancelButton:setDefaultTexture(assets.quit)
    cancelButton.onActivated = function()
        settings:removeFromSuperview()
    end
    self.app:openPopupNearHand(settings, pointer.hand, 0.8)
end

return DecoView
