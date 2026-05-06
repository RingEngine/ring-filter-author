function onReset(ctx)
end

function advance(ctx)
    ctx:runRenderPass("effect", {
        source = ctx:getInput(),
        params = {
            strength = ctx:getParam("strength")
        }
    }, ctx:getOutput())
end
