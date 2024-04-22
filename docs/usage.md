---
sidebar_position: 2
---

# Usage

```lua
local SPEED = 25
local MAX_DISTANCE = 1000
local GRAVITY = Vector3.new(0, -workspace.Gravity, 0)

local function gravity(raycast: Flashcast.Raycast, deltaTime: number)
    local parallelComponent = raycast.direction:Dot(GRAVITY.Unit) * GRAVITY.Unit
    local perpendicularComponent = raycast.direction - parallelComponent
    local newDirection = perpendicularComponent + (parallelComponent + GRAVITY * deltaTime)

    raycast.direction = newDirection.Unit * raycast.direction.Magnitude
end

local function maxDistance(raycast: Flashcast.Raycast)
    if raycast.state.distanceTraveled > MAX_DISTANCE then
        return Flashcast.Result.Stop
    end
end

local flashcast = Flashcast.new()
    :beforeStep(maxDistance)
    :afterStep(gravity)

local direction = Random.new():NextUnitVector()
local raycast = flashcast:cast(Vector3.new(0, 10, 0), direction * SPEED)
```

## Examples

- https://www.roblox.com/games/17247702703/Flashcast-Rockets
