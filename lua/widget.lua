function makeWidgetButton(app, bounds, makeUI)
    -- Button to add wrist widget
    local widgetifyButton = ui.Button(bounds)

    widgetifyButton:setDefaultTexture(assets.widget)
    widgetifyButton.onActivated = function(hand)
        -- widget is just a button to call up a miniature decorator.
        local callupButton = ui.Button(
            ui.Bounds{size=ui.Size(0.025,0.025,0.02)}
        )
        callupButton:setColor({ 34/255, 195/255, 181/255, 0.8})
        local icon = callupButton:addSubview(ui.ModelView(ui.Bounds(0, 0, 0.1), assets.icon))
        icon.transform = mat4.scale(mat4.new(), mat4.new(), vec3.new(0.1, 0.1, 0.1))

        local currentGrid = nil
        function removeUI()
            currentGrid:addPropertyAnimation(ui.PropertyAnimation{
                path= "transform.matrix",
                from= mat4.scale(mat4.new(), currentGrid.bounds.pose.transform, vec3.new(0,0,0)),
                to=   mat4.new(currentGrid.bounds.pose.transform),
                duration = 0.2,
                easing= "quadIn"
            })
            local g = currentGrid
            currentGrid = nil
            app:scheduleAction(0.5, false, function()
                g:removeFromSuperview()
            end)
        end
        function showUI()
            currentGrid = makeUI()
            currentGrid.bounds:move(0, 0.5, 0):scale(0.1, 0.1, 0.1)

            local hideButton = currentGrid:addSubview(ui.Button(
                ui.Bounds{size=ui.Size(0.12,0.12,0.05)}
                    :move( currentGrid.bounds.size:getEdge("top", "right", "front") )
            ))
            hideButton:setDefaultTexture(assets.quit)
            hideButton.onActivated = function()
                removeUI()
            end
            local removeWidgetButton = currentGrid:addSubview(ui.Button(
                ui.Bounds{size=ui.Size(0.70,0.12,0.05)}
                    :move( currentGrid.bounds.size:getEdge("top", "right", "front") )
                    :move( -0.50, 0, 0)
            ))
            removeWidgetButton.label:setText("Remove widget")
            removeWidgetButton.onActivated = function()
                removeUI()
                callupButton:removeFromSuperview()
            end
            currentGrid.transform = mat4.scale(mat4.new(), mat4.new(), vec3.new(0,0,0))
            callupButton:addSubview(currentGrid)
            currentGrid:doWhenAwake(function()
                currentGrid:addPropertyAnimation(ui.PropertyAnimation{
                    path= "transform.matrix",
                    to= mat4.scale(mat4.new(), currentGrid.bounds.pose.transform, vec3.new(0,0,0)),
                    from=   mat4.new(currentGrid.bounds.pose.transform),
                    duration = 0.2,
                    easing= "quadOut"
                })
            end)
        end


        -- clicking it shows the mini decorator.
        callupButton.onActivated = function ()
            if currentGrid then
                removeUI()
            else
                showUI()
            end
        end

        -- add it, and animate on failure and success.
        app:addWristWidget(hand, callupButton, function(ok)
            if not ok then
                ui.StandardAnimations.addFailureAnimation(widgetifyButton, 0.03)
                return
            end
            ui.StandardAnimations.addSpawnAnimation(callupButton)
        end)
    end

    return widgetifyButton
end

return makeWidgetButton
