---
sidebar_position: 3
---

# Useful Hooks

here's a small collection of "hooks" for common behavior that you could want to implement on a bullet.

## Max Distance

```lua
local function maxDistance(cap: number)
    return function(bullet: Flashcast.Bullet)
        if bullet.distanceTraveled > cap then
            bullet:stop()
        end
    end
end
```

```lua
local cap = 1000
local flashcast = Flashcast.createBehavior():beforeStep(maxDistance(cap))
```

## Acceleration

```lua
local function accelerate(towards: Vector3)
    return function(bullet: Flashcast.Bullet, deltaTime: number)
	    if towards.Magnitude == 0 then
		    return
	    end

	    local parallelComponent = bullet.direction:Dot(towards.Unit) * towards.Unit
	    local perpendicularComponent = bullet.direction - parallelComponent
	    local newDirection = perpendicularComponent + (parallelComponent + towards * deltaTime)
	    bullet.direction = newDirection.Unit * bullet.direction.Magnitude
    end
end
```

```lua
local gravity = Vector3.new(0, -workspace.Gravity, 0)
local flashcast = Flashcast.createBehavior():afterStep(accelerate(gravity))
```

## Reflection

```lua
local function reflect(bullet: Flashcast.Bullet, deltaTime: number)
	if bullet.touched then
		local reflectedDirection = bullet.direction - (2 * bullet.direction:Dot(bullet.touched.Normal) * bullet.touched.Normal)
		bullet.position = bullet.touched.Position
		bullet.direction = reflectedDirection
	end
end
```

```lua
local flashcast = Flashcast.createBehavior():afterStep(reflect)
```

## Visualization

```lua
local function visualize(duration: number)
	return function(bullet: Flashcast.Bullet, deltaTime: number)
		local adornment = Instance.new("ConeHandleAdornment")
		adornment.Adornee = workspace.Terrain
		adornment.Radius = 0.25
		adornment.Color3 = Color3.new()
		adornment.Transparency = 0.5
		adornment.CFrame = CFrame.lookAt(bullet.position, bullet.position + bullet.direction)
		adornment.Height = bullet.direction.Magnitude * deltaTime
		adornment.Parent = workspace.Terrain
		task.delay(duration, function()
			adornment:Destroy()
		end)
	end
end
```

```lua
local duration = 1
local flashcast = Flashcast.createBehavior():beforeStep(visualize(duration))
```
