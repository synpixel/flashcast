---
sidebar_position: 3
---

# Useful Hooks

Here's a small collection of "hooks" for common behavior that you could want to implement on a bullet.

## Max Distance

```lua
local function maxDistance(distance: number)
    return function(raycast: Flashcast.Raycast)
        if raycast.state.distanceTraveled > distance then
            return Flashcast.Result.Stop
        end
        return
    end
end
```

```lua
local flashcast = Flashcast.new():beforeStep(maxDistance(1000))
```

## Acceleration

```lua
local function accelerate(towards: Vector3)
    return function(raycast: Flashcast.Raycast, deltaTime: number)
	    if towards.Magnitude == 0 then
		    return
	    end

	    local parallelComponent = raycast.direction:Dot(towards.Unit) * towards.Unit
	    local perpendicularComponent = raycast.direction - parallelComponent
	    local newDirection = perpendicularComponent + (parallelComponent + towards * deltaTime)
	    raycast.direction = newDirection.Unit * raycast.direction.Magnitude
    end
end
```

```lua
local gravity = Vector3.new(0, -workspace.Gravity, 0)
local flashcast = Flashcast.new():afterStep(accelerate(gravity))
```
