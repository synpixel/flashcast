local RunService = game:GetService("RunService")

--- @type StepCallback (raycast: Raycast, deltaTime: number) -> Vector3 | Result
--- @within Flashcast
--- Takes a Raycast instance and delta time and gives back a new direction or a [Result](/api/Flashcast/#Result)
export type StepCallback = (raycast: Raycast, deltaTime: number) -> Vector3 | number

--- @interface Raycast
--- @within Flashcast
--- .position Vector3
--- .direction Vector3
--- .raycastParams? RaycastParams
--- .results { RaycastResult } -- RaycastResults ordered from earliest to latest
--- .state { lastTick: number, distanceTraveled: number, touched?: RaycastResult, [any]: any } -- for preserving state throughout the raycasting
--- .tick number -- by default the Flashcast instance's tick
export type Raycast = {
	position: Vector3,
	direction: Vector3,
	raycastParams: RaycastParams?,
	results: { RaycastResult },
	state: { lastTick: number, distanceTraveled: number, touched: RaycastResult?, [any]: any },
	tick: number,
}

--- @class Flashcast
local Flashcast = {}

--- @prop Result { Pass, Stop }
--- @within Flashcast
--- Different results (outcomes) of step callbacks
Flashcast.Result = {
	Pass = 1,
	Stop = 2,
}

--- @method worldRoot
--- @within Flashcast
--- @param worldRoot WorldRoot
--- @return Flashcast
--- Overrides the default [WorldRoot](https://create.roblox.com/docs/reference/engine/classes/WorldRoot) ([Workspace](https://create.roblox.com/docs/reference/engine/classes/Workspace))
local function worldRoot(self: Flashcast, worldRoot: WorldRoot)
	self._worldRoot = worldRoot
	return self
end

--- @method tick
--- @within Flashcast
--- @param tick number
--- @return Flashcast
--- Configures the amount of rays cast per second
local function tick(self: Flashcast, tick: number): Flashcast
	self._tick = tick
	return self
end

--- @method beforeStep
--- @within Flashcast
--- @param step StepCallback
--- @return Flashcast
--- Adds a step callback scheduled to run before calculations
local function beforeStep(self: Flashcast, step: StepCallback): Flashcast
	table.insert(self._beforeStepCallbacks, step)
	return self
end

--- @method afterStep
--- @within Flashcast
--- @param step StepCallback
--- @return Flashcast
--- Adds a step callback scheduled to run after calculations
local function afterStep(self: Flashcast, step: StepCallback): Flashcast
	table.insert(self._afterStepCallbacks, step)
	return self
end

--- @method onStepNoTick
--- @within Flashcast
--- @param step (raycast: Raycast) -> ()
--- @return Flashcast
--- Adds a callback scheduled to run on every step regardless of the tick set, should not be used for expensive operations
local function onStepNoTick(self: Flashcast, step: (raycast: Raycast) -> ())
	table.insert(self._onStepNoTickCallbacks, step)
	return self
end

--- @method spatialQuery
--- @within Flashcast
--- @param query (raycast: Raycast, deltaTime: number) -> RaycastResult?
--- @return Flashcast
--- Overrides the default spatial query ([WorldRoot.Raycast](https://create.roblox.com/docs/reference/engine/classes/WorldRoot#Raycast))
local function spatialQuery(self: Flashcast, query: (raycast: Raycast, deltaTime: number) -> RaycastResult?): Flashcast
	self._spatialQuery = query
	return self
end

--- @method cast
--- @within Flashcast
--- @param origin Vector3
--- @param direction Vector3
--- @param raycastParams? RaycastParams
--- @return Raycast
--- @yields
--- This will yield until one of the step callbacks returns Result.Stop
local function cast(self: Flashcast, origin: Vector3, direction: Vector3, raycastParams: RaycastParams?): Raycast
	local raycast = {}
	raycast.position = origin
	raycast.direction = direction
	raycast.raycastParams = raycastParams
	raycast.results = {}
	raycast.state = {
		lastTick = os.clock() - self._tick,
		distanceTraveled = 0,
		touched = nil,
	}
	raycast.tick = self._tick

	local thread = coroutine.running()
	local connection

	local function move(old: Vector3, new: Vector3, deltaTime: number)
		local raycastResult = if self._spatialQuery
			then self._spatialQuery(raycast, deltaTime)
			else self._worldRoot:Raycast(old, (new - old), raycastParams)

		if raycastResult then
			table.insert(raycast.results, raycastResult)
		end

		raycast.position = new
		raycast.state.distanceTraveled += (new - old).Magnitude
		raycast.state.touched = raycastResult
	end

	local function processStepCallbacks(stepCallbacks: { StepCallback }, deltaTime: number)
		for _, callback in stepCallbacks do
			local direction = callback(raycast, deltaTime)

			if direction == Flashcast.Result.Pass then
				continue
			elseif direction == Flashcast.Result.Stop then
				connection:Disconnect()
				task.spawn(thread)
				return Flashcast.Result.Stop
			elseif typeof(direction) == "Vector3" then
				raycast.direction = direction
			else
				error(
					"step callbacks must return a Vector3 or a Flashcast.Result. if you do not wish to change the direction, return Flashcast.Result.Pass."
				)
			end
		end

		return Flashcast.Result.Pass
	end

	connection = RunService.Heartbeat:Connect(function()
		local deltaTime = os.clock() - raycast.state.lastTick

		for _, callback in self._onStepNoTickCallbacks do
			callback(raycast)
		end

		if deltaTime < raycast.tick then
			return
		end

		if processStepCallbacks(self._beforeStepCallbacks, deltaTime) == Flashcast.Result.Stop then
			return
		end

		move(raycast.position, raycast.position + raycast.direction * deltaTime, deltaTime)
		processStepCallbacks(self._afterStepCallbacks, deltaTime)

		raycast.state.lastTick = os.clock()
	end)

	coroutine.yield()
	return table.freeze(raycast)
end

--- @return Flashcast
function Flashcast.new()
	return {
		_worldRoot = workspace,
		_tick = 0,
		_beforeStepCallbacks = {} :: { StepCallback },
		_afterStepCallbacks = {} :: { StepCallback },
		_onStepNoTickCallbacks = {} :: { (raycast: Raycast) -> () },
		_spatialQuery = nil,
		worldRoot = worldRoot,
		tick = tick,
		beforeStep = beforeStep,
		afterStep = afterStep,
		onStepNoTick = onStepNoTick,
		spatialQuery = spatialQuery,
		cast = cast,
	}
end

export type Flashcast = typeof(Flashcast.new(...))

return Flashcast
