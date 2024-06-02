--!strict

local RunService = game:GetService("RunService")

--- @interface FlashcastOptions
--- .worldRoot? WorldRoot -- default: Workspace
--- .event? RBXScriptSignal -- default: RunService.PostSimulation
--- @within Flashcast
export type FlashcastOptions = {
	worldRoot: WorldRoot?,
	event: RBXScriptSignal?,
}

--- @class Bullet

--- @prop behavior Behavior
--- @within Bullet

--- @prop position Vector3
--- @within Bullet

--- @prop direction Vector3
--- @within Bullet

--- @prop raycastParams? RaycastParams
--- @within Bullet

--- @prop distanceTraveled number
--- @within Bullet

--- @prop raycastResults { RaycastResult }
--- @within Bullet

--- @prop desiredFramerate number
--- @within Bullet
--- the desired framerate which you want the bullet to move at, by default the behavior's desired framerate (you can modify this)

--- @prop lastTick number
--- @within Bullet
--- the bullet's last resumption step

--- @prop touched RaycastResult?
--- @within Bullet
--- the current RaycastResult, set every frame by flashcast

--- @prop data { [any]: any }
--- @within Bullet
--- empty table for state

--- @method move
--- @param position Vector3
--- @within Bullet
--- moves the bullet, raycasting from the position to the goal

--- @method stop
--- @within Bullet
--- stops the bullet

--- @method isStopped
--- @within Bullet
--- gets whether or not the bullet has been stopped

export type Bullet = {
	behavior: Behavior,
	position: Vector3,
	direction: Vector3,
	raycastParams: RaycastParams?,
	distanceTraveled: number,
	raycastResults: { RaycastResult },
	desiredFramerate: number,
	lastTick: number,
	touched: RaycastResult?,
	data: { [any]: any },
	move: (self: Bullet, position: Vector3) -> (),
	stop: (self: Bullet) -> (),
	isStopped: (self: Bullet) -> boolean,
}

export type BehaviorStepCallback = (bullet: Bullet, deltaTime: number) -> ()

--- @class Behavior

--- @method setDesiredFramerate
--- @param desiredFramerate number
--- @return Behavior
--- @within Behavior
--- sets a desired framerate for the behavior

--- @method beforeStep
--- @param callback BehaviorStepCallback
--- @return Behavior
--- @within Behavior
--- adds a step callback scheduled to run before moving the bullet

--- @method afterStep
--- @param callback BehaviorStepCallback
--- @return Behavior
--- @within Behavior
--- adds a step callback scheduled to run after moving the bullet

local function createBehavior()
	local beforeStepCallbacks: { BehaviorStepCallback } = {}
	local afterStepCallbacks: { BehaviorStepCallback } = {}

	local behavior = {}
	behavior._beforeStepCallbacks = beforeStepCallbacks
	behavior._afterStepCallbacks = afterStepCallbacks
	behavior.desiredFramerate = math.huge

	function behavior.setDesiredFramerate(self: Behavior, desiredFramerate: number): Behavior
		behavior.desiredFramerate = desiredFramerate
		return behavior
	end

	function behavior.beforeStep(self: Behavior, callback: BehaviorStepCallback): Behavior
		table.insert(beforeStepCallbacks, callback)
		return behavior
	end

	function behavior.afterStep(self: Behavior, callback: BehaviorStepCallback): Behavior
		table.insert(afterStepCallbacks, callback)
		return behavior
	end

	return behavior
end

--- @class Flashcast

--- @function new
--- @param options? FlashcastOptions
--- @within Flashcast
--- creates a new flashcast instance

--- @function createBehavior
--- @return Behavior
--- @within Flashcast
--- creates a new behavior

--- @method getBullets
--- @return { Bullet }
--- @within Flashcast
--- gets every bullet in the instance

--- @method spawnBullet
--- @param behavior Behavior
--- @param origin Vector3
--- @param direction Vector3
--- @param raycastParams? RaycastParams
--- @return Bullet
--- @within Flashcast
--- spawns a bullet with a behavior

--- @method stepBullet
--- @param bullet Bullet
--- @param deltaTime number
--- @within Flashcast
--- advances a bullet by one step
--- :::info
--- calling this method will not update the bullet's lastTick property

--- @method step
--- @within Flashcast
--- used internally to advance every bullet by one step

--- @method clear
--- @within Flashcast
--- clears all bullets in the instance

--- @method destroy
--- @within Flashcast
--- enables the instance to be garbage collected (also clears all bullets)

local function createFlashcast(options: FlashcastOptions?)
	local patchedOptions: FlashcastOptions = options or {}

	local bullets: { Bullet } = {}
	local scheduler: RBXScriptConnection = nil

	local flashcast = {}
	flashcast.worldRoot = patchedOptions.worldRoot or workspace
	flashcast.event = patchedOptions.event or RunService.PostSimulation

	function flashcast.getBullets(self: Flashcast): { Bullet }
		return bullets
	end

	function flashcast.spawnBullet(
		self: Flashcast,
		behavior: Behavior,
		origin: Vector3,
		direction: Vector3,
		raycastParams: RaycastParams?
	): Bullet
		local bullet = {}
		bullet.behavior = behavior
		bullet.position = origin
		bullet.direction = direction
		bullet.raycastParams = raycastParams

		bullet.distanceTraveled = 0
		bullet.raycastResults = {}
		bullet.desiredFramerate = behavior.desiredFramerate
		bullet.lastTick = os.clock() - 1 / bullet.desiredFramerate
		bullet.data = {}

		function bullet.move(self: Bullet, position: Vector3)
			local direction = position - bullet.position

			local raycastResult = flashcast.worldRoot:Raycast(bullet.position, direction, bullet.raycastParams)
			if raycastResult then
				table.insert(bullet.raycastResults, raycastResult)
			end

			bullet.position = position
			bullet.distanceTraveled += direction.Magnitude
			bullet.touched = raycastResult
		end

		function bullet.stop(self: Bullet)
			local index = table.find(bullets, bullet)
			if index ~= nil then
				table.remove(bullets, index)
			end
		end

		function bullet.isStopped(self: Bullet)
			return table.find(bullets, bullet) == nil
		end

		table.insert(bullets, bullet)

		return bullet
	end

	function flashcast.stepBullet(self: Flashcast, bullet: Bullet, deltaTime: number)
		task.spawn(function()
			for _, callback in bullet.behavior._beforeStepCallbacks do
				callback(bullet, deltaTime)
			end

			bullet:move(bullet.position + bullet.direction * deltaTime)

			for _, callback in bullet.behavior._afterStepCallbacks do
				callback(bullet, deltaTime)
			end
		end)
	end

	function flashcast.step(self: Flashcast)
		for _, bullet in bullets do
			local deltaTime = os.clock() - bullet.lastTick

			if deltaTime < 1 / bullet.desiredFramerate then
				continue
			end

			bullet.lastTick = os.clock()
			flashcast:stepBullet(bullet, deltaTime)
		end
	end

	function flashcast.clear(self: Flashcast)
		for _, bullet in bullets do
			bullet:stop()
		end
	end

	function flashcast.destroy(self: Flashcast)
		scheduler:Disconnect()
		flashcast:clear()
	end

	scheduler = flashcast.event:Connect(function()
		flashcast:step()
	end)

	return flashcast
end

export type Flashcast = typeof(createFlashcast(...))
export type Behavior = typeof(createBehavior(...))

return {
	new = createFlashcast,
	createBehavior = createBehavior,
}
