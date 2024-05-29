---
sidebar_position: 2
---

# Usage

```lua
local SPEED = 25
local MAX_DISTANCE = 1000
local GRAVITY = Vector3.new(0, -workspace.Gravity, 0)

local function gravity(bullet: Flashcast.Bullet, deltaTime: number)
    local parallelComponent = bullet.direction:Dot(GRAVITY.Unit) * GRAVITY.Unit
    local perpendicularComponent = bullet.direction - parallelComponent
    local newDirection = perpendicularComponent + (parallelComponent + GRAVITY * deltaTime)

    bullet.direction = newDirection.Unit * bullet.direction.Magnitude
end

local function maxDistance(bullet: Flashcast.Bullet)
    if bullet.distanceTraveled > MAX_DISTANCE then
        bullet:stop()
    end
end

local flashcast = Flashcast.new()
local behavior = Flashcast.createBehavior()
    :setDesiredFramerate(10) -- the bullet will move every 1 / 10 seconds
    :beforeStep(maxDistance) -- applies a max distance check before moving the bullet
    :afterStep(gravity) -- applies gravity after moving the bullet

local direction = Random.new():NextUnitVector()
local bullet = flashcast:spawnBullet(
    behavior,
    Vector3.new(0, 10, 0),
    direction * SPEED
)
```

## Examples

- https://www.roblox.com/games/17247702703/Flashcast-Rockets
- https://create.roblox.com/store/asset/17307837568/Flashcast-Rocket-Launcher
