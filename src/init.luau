local RunService = game:GetService("RunService")
local createSignal = require(script.createSignal)

--- @type StepCallback (raycast: Raycast, deltaTime: number) -> Result?
--- @within Flashcast
--- Takes a Raycast instance and delta time and gives back a [Result](/api/Flashcast/#Result)
export type StepCallback = (raycast: Raycast, deltaTime: number) -> number?

--- @interface Raycast
--- @within Flashcast
--- .position Vector3
--- .direction Vector3
--- .raycastParams? RaycastParams
--- .results { RaycastResult } -- RaycastResults ordered from earliest to latest
--- .state { lastTick: number, distanceTraveled: number, touched?: RaycastResult, [any]: any } -- for preserving state throughout the raycasting
--- .tick number | (raycast: Raycast) -> number -- by default the Flashcast instance's tick
--- .stopped Signal<()>
--- .stop (self: Raycast) -> ()
export type Raycast = {
	position: Vector3,
	direction: Vector3,
	raycastParams: RaycastParams?,
	results: { RaycastResult },
	state: { lastTick: number, distanceTraveled: number, touched: RaycastResult?, [any]: any },
	tick: number | (raycast: Raycast) -> number,
	stopped: createSignal.Signal<()>,
	stop: (self: Raycast) -> (),
}

--- @class Flashcast
local Flashcast = {}

--- @prop Result { Stop }
--- @within Flashcast
--- Different results (outcomes) of step callbacks
Flashcast.Result = {
	Stop = 1,
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
--- @param tick number | (raycast: Raycast) -> number
--- @return Flashcast
--- Configures the amount of rays cast per second
--- :::info
--- If the tick passed is a callback, it will run every frame. This is not for expensive operations.
local function tick(self: Flashcast, tick: number | (raycast: Raycast) -> number): Flashcast
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

--- @method spatialQuery
--- @within Flashcast
--- @param query (worldRoot: WorldRoot, origin: Vector3, direction: Vector3, raycast: Raycast) -> RaycastResult?
--- @return Flashcast
--- Overrides the default spatial query ([WorldRoot.Raycast](https://create.roblox.com/docs/reference/engine/classes/WorldRoot#Raycast))
local function spatialQuery(
	self: Flashcast,
	query: (
		worldRoot: WorldRoot,
		origin: Vector3,
		direction: Vector3,
		raycast: Raycast
	) -> RaycastResult?
): Flashcast
	self._spatialQuery = query
	return self
end

--- @method event
--- @within Flashcast
--- @param event RBXScriptSignal
--- @return Flashcast
--- Overrides the default lifecycle event ([RunService.Heartbeat](https://create.roblox.com/docs/reference/engine/classes/RunService#Heartbeat))
local function event(self: Flashcast, event: RBXScriptSignal): Flashcast
	self._event = event
	return self
end

--- @method cast
--- @within Flashcast
--- @param origin Vector3
--- @param direction Vector3
--- @param raycastParams? RaycastParams
--- @param defaultState? { [any]: any }
--- @return Raycast
local function cast(
	self: Flashcast,
	origin: Vector3,
	direction: Vector3,
	raycastParams: RaycastParams?,
	defaultState: { [any]: any }?
): Raycast
	local raycast = {}
	raycast.position = origin
	raycast.direction = direction
	raycast.raycastParams = raycastParams
	raycast.results = {}
	raycast.tick = self._tick
	raycast.stopped = createSignal()
	raycast.state = {
		distanceTraveled = 0,
		touched = nil,
	}

	if defaultState then
		for key, value in defaultState do
			raycast.state[key] = value
		end
	end

	raycast.state.lastTick = os.clock()
		- (if typeof(raycast.tick) == "function" then raycast.tick(raycast) else raycast.tick)

	function raycast:stop()
		raycast.stopped:fire()
	end

	raycast.stopped:connect(function()
		table.remove(self._raycasts, table.find(self._raycasts, raycast))
	end)

	table.insert(self._raycasts, raycast)

	return raycast
end

--- @method clear
--- @within Flashcast
--- Stops all active raycasts
local function clear(self: Flashcast)
	for _, raycast in self._raycasts do
		raycast:stop()
	end
end

--- @method destroy
--- @within Flashcast
--- Enables the Flashcast instance to be garbage collected
local function destroy(self: Flashcast)
	self:clear()
	self._scheduler:Disconnect()
end

local function startScheduler(self: Flashcast): RBXScriptConnection
	local function moveRaycast(raycast: Raycast, deltaTime: number)
		local direction = raycast.direction * deltaTime

		local raycastResult = if self._spatialQuery
			then self._spatialQuery(self._worldRoot, raycast.position, direction, raycast)
			else self._worldRoot:Raycast(raycast.position, direction, raycast.raycastParams)

		if raycastResult then
			table.insert(raycast.results, raycastResult)
		end

		raycast.position += direction
		raycast.state.distanceTraveled += direction.Magnitude
		raycast.state.touched = raycastResult
	end

	local function processStepCallbacks(stepCallbacks: { StepCallback }, ...)
		for _, callback in stepCallbacks do
			local result = callback(...)

			if result == Flashcast.Result.Stop then
				return result
			end
		end

		return
	end

	local function stepRaycast(raycast: Raycast)
		local deltaTime = os.clock() - raycast.state.lastTick

		if deltaTime < (if typeof(raycast.tick) == "function" then raycast.tick(raycast) else raycast.tick) then
			return
		end

		if processStepCallbacks(self._beforeStepCallbacks, raycast, deltaTime) == Flashcast.Result.Stop then
			return Flashcast.Result.Stop
		end

		moveRaycast(raycast, deltaTime)

		if processStepCallbacks(self._afterStepCallbacks, raycast, deltaTime) == Flashcast.Result.Stop then
			return Flashcast.Result.Stop
		end

		raycast.state.lastTick = os.clock()
		return
	end

	local function step(raycast: Raycast)
		if stepRaycast(raycast) == Flashcast.Result.Stop then
			raycast:stop()
		end
	end

	return self._event:Connect(function()
		for _, raycast in self._raycasts do
			task.spawn(step, raycast)
		end
	end)
end

--- @return Flashcast
function Flashcast.new()
	local self = {
		_worldRoot = workspace,
		_tick = 0,
		_beforeStepCallbacks = {} :: { StepCallback },
		_afterStepCallbacks = {} :: { StepCallback },
		_spatialQuery = nil,
		_event = RunService.Heartbeat,
		_raycasts = {} :: { Raycast },
		worldRoot = worldRoot,
		tick = tick,
		beforeStep = beforeStep,
		afterStep = afterStep,
		spatialQuery = spatialQuery,
		event = event,
		cast = cast,
		clear = clear,
		destroy = destroy,
	}

	self._scheduler = startScheduler(self)

	return self
end

export type Flashcast = typeof(Flashcast.new(...))

return Flashcast
