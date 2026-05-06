function onReset(ctx)
end

function advance(ctx)
    local now = ctx:getTimeSeconds()
    local speed = ctx:getParam("speed")

    ctx:runRenderPass("animatedTint", {
        source = ctx:getInput(),
        params = {
            tintColor = ctx:getParam("tintColor"),
            phase = now * speed
        }
    }, ctx:getOutput())
end
