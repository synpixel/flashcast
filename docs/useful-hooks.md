---
sidebar_position: 3
---

# Useful Hooks

Here's a small collection of "hooks" for common behavior that you could want to implement on a bullet.

## Max Distance

```lua
local function maxDistance(cap: number)
    return function(raycast: Flashcast.Raycast)
        if raycast.state.distanceTraveled > cap then
            return Flashcast.Result.Stop
        end
        return
    end
end
```

```lua
local cap = 1000
local flashcast = Flashcast.new():beforeStep(maxDistance(cap))
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

## Reflection

```lua
local function reflect(raycast: Flashcast.Raycast, deltaTime: number)
	local touched = raycast.state.touched
	if touched then
		local reflectedDirection = raycast.direction - (2 * raycast.direction:Dot(touched.Normal) * touched.Normal)
		raycast.position = touched.Position
		raycast.direction = reflectedDirection
	end
end
```

```lua
local flashcast = Flashcast.new():afterStep(reflect)
```

## Visualization

```lua
local function visualize(duration: number)
    return function(raycast: Flashcast.Raycast, deltaTime: number)
	    local adornment = Instance.new("ConeHandleAdornment")
        adornment.Adornee = workspace.Terrain
        adornment.Radius = 0.25
        adornment.Color3 = Color3.new()
        adornment.Transparency = 0.5
        adornment.CFrame = CFrame.lookAt(raycast.position, raycast.position + raycast.direction)
        adornment.Height = raycast.direction.Magnitude * deltaTime
        adornment.Parent = workspace.Terrain
        Debris:AddItem(adornment, duration)
    end
end
```

```lua
local duration = 1
local flashcast = Flashcast.new():beforeStep(visualize(duration))
```
