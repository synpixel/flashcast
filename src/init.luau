local RunService = game:GetService("RunService")

--- @type StepCallback (raycast: Raycast, deltaTime: number) -> Vector3 | Result
--- @within Flashcast
export type StepCallback = (raycast: Raycast, deltaTime: number) -> Vector3 | number

--- @interface Raycast
--- @within Flashcast
--- .position Vector3
--- .direction Vector3
--- .results { RaycastResult } -- RaycastResults ordered from earliest to latest
--- .state { lastTick: number, distanceTraveled: number, touched?: RaycastResult, [any]: any } -- for preserving state throughout the raycasting
--- .tick number -- by default the Flashcast instance's tick
export type Raycast = {
	position: Vector3,
	direction: Vector3,
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

--- @method tick
--- @within Flashcast
--- @param tick number
--- @return Flashcast
--- Configures the amount of rays cast per second
local function tick(self: Flashcast, tick: number): Flashcast
	self._tick = tick
	return self
end

--- @method onStep
--- @within Flashcast
--- @param step StepCallback
--- @return Flashcast
--- Adds a step callback to the schedule
local function onStep(self: Flashcast, step: StepCallback): Flashcast
	table.insert(self._stepCallbacks, step)
	return self
end

--- @method cast
--- @within Flashcast
--- @param origin Vector3
--- @param direction Vector3
--- @param raycastParams? RaycastParams
--- @return Raycast
local function cast(self: Flashcast, origin: Vector3, direction: Vector3, raycastParams: RaycastParams?): Raycast
	local raycast = {}
	raycast.position = origin
	raycast.direction = direction
	raycast.results = {}
	raycast.state = {
		lastTick = os.clock() - self._tick,
		distanceTraveled = 0,
		touched = nil,
	}
	raycast.tick = self._tick

	local thread = coroutine.running()

	local function move(old: Vector3, new: Vector3)
		local raycastResult = workspace:Raycast(old, (new - old), raycastParams)

		if raycastResult then
			table.insert(raycast.results, raycastResult)
		end

		raycast.position = new
		raycast.state.distanceTraveled += (new - old).Magnitude
		raycast.state.touched = raycastResult
	end

	local connection
	connection = RunService.Heartbeat:Connect(function()
		local deltaTime = os.clock() - raycast.state.lastTick
		if deltaTime < raycast.tick then
			return
		end

		for _, callback in self._stepCallbacks do
			local direction = callback(raycast, deltaTime)

			if direction == Flashcast.Result.Pass then
				continue
			elseif direction == Flashcast.Result.Stop then
				connection:Disconnect()
				task.spawn(thread)
				return
			elseif typeof(direction) == "Vector3" then
				raycast.direction = direction
			else
				error(
					"step callbacks must return a Vector3 or a Flashcast.Result. if you do not wish to change the direction, return Flashcast.Result.Pass."
				)
			end
		end

		move(raycast.position, raycast.position + raycast.direction * deltaTime)
		raycast.state.lastTick = os.clock()
	end)

	coroutine.yield()
	return table.freeze(raycast)
end

--- @return Flashcast
function Flashcast.new()
	return {
		_tick = 0,
		_stepCallbacks = {} :: { StepCallback },
		tick = tick,
		onStep = onStep,
		cast = cast,
	}
end

export type Flashcast = typeof(Flashcast.new(...))

return Flashcast
