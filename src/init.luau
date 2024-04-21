local RunService = game:GetService("RunService")

export type OnStepCallback = (raycast: Raycast, deltaTime: number) -> Vector3 | number

export type Raycast = {
	position: Vector3,
	direction: Vector3,
	results: { RaycastResult },
	state: { lastTick: number, distanceTraveled: number, touched: RaycastResult?, [any]: any },
}

local Flashcast = {}
Flashcast.Result = {
	Pass = 1,
	Stop = 2,
}

local function tick(self: Flashcast, tick: number): Flashcast
	self._tick = tick
	return self
end

local function onStep(self: Flashcast, callback: OnStepCallback): Flashcast
	table.insert(self._onStepCallbacks, callback)
	return self
end

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
		if deltaTime < self._tick then
			return
		end

		move(raycast.position, raycast.position + raycast.direction * deltaTime)

		for _, callback in self._onStepCallbacks do
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
					"onStep callbacks must return a Vector3 or a Flashcast.Result. if you do not wish to change the direction, return Flashcast.Result.Pass."
				)
			end
		end

		raycast.state.lastTick = os.clock()
	end)

	coroutine.yield()
	return table.freeze(raycast)
end

function Flashcast.new()
	return {
		_tick = 0,
		_onStepCallbacks = {} :: { OnStepCallback },
		tick = tick,
		onStep = onStep,
		cast = cast,
	}
end

export type Flashcast = typeof(Flashcast.new(...))

return Flashcast
