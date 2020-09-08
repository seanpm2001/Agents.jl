export step!, dummystep

"""
    step!(model, agent_step!, n::Int = 1)
    step!(model, agent_step!, model_step!, n::Int = 1, agents_first::Bool=true)

Update agents `n` steps according to the stepping function `agent_step!`.
Agents will be activated as specified by the `model.scheduler`.
`model_step!` is triggered _after_ every scheduled agent has acted, unless
the argument `agents_first` is `false` (which then first calls `model_step!` and then
activates the agents).

    step!(model, agent_step!, model_step!, n::Function, agents_first::Bool=true)

In this version `n` is a function.
Then `step!` runs the model until `n(model, s)` returns `true`, where `s` is the
current amount of steps taken, starting from 0.
For this method of `step!`, `model_step!` must be provided always (use [`dummystep`](@ref)
if you have no model stepping dynamics).
"""
function step! end

"""
    dummystep(model)

Ignore the model dynamics. Use instead of `model_step!`.
"""
dummystep(model) = nothing
"""
    dummystep(agent, model)

Ignore the agent dynamics. Use instead of `agent_step!`.
"""
dummystep(agent, model) = nothing

until(ss, n::Int, model) = ss < n
until(ss, n, model) = !n(model, ss)

step!(model::ABM, agent_step!, n::Int=1, agents_first::Bool=true) = step!(model, agent_step!, dummystep, n, agents_first)

function step!(model::ABM, agent_step!, model_step!, n = 1, agents_first=true)
  s = 0
  while until(s, n, model)
    !agents_first && model_step!(model)
    activation_order = model.scheduler(model)
    for index in activation_order
      haskey(model.agents, index) || continue
      agent_step!(model.agents[index], model)
    end
    agents_first && model_step!(model)
    s += 1
  end
end
