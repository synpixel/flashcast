local RunService = game:GetService("RunService")

export type OnStepCallback = (raycast: Raycast, deltaTime: number) -> Vector3 | number

export type Raycast = {
	position: Vector3,
	direction: Vector3,
	distanceTraveled: number,
	results: { RaycastResult },
	touched: RaycastResult?,
	state: { [any]: any },
}

local Flashcast = {}
Flashcast.Result = {
	Pass = 1,
	Stop = 2,
}

local function onStep(self: Flashcast, callback: OnStepCallback): Flashcast
	table.insert(self._onStepCallbacks, callback)
	return self
end

local function cast(self: Flashcast, origin: Vector3, direction: Vector3, raycastParams: RaycastParams?): Raycast
	local raycast = {}
	raycast.position = origin
	raycast.direction = direction
	raycast.distanceTraveled = 0
	raycast.results = {}
	raycast.touched = nil
	raycast.state = {}

	local thread = coroutine.running()

	local function move(old: Vector3, new: Vector3)
		local raycastResult = workspace:Raycast(old, (new - old), raycastParams)

		if raycastResult then
			table.insert(raycast.results, raycastResult)
		end

		raycast.position = new
		raycast.distanceTraveled += (new - old).Magnitude
		raycast.touched = raycastResult
	end

	local connection
	connection = RunService.Heartbeat:Connect(function(deltaTime)
		move(raycast.position, raycast.position + raycast.direction * deltaTime)

		for _, callback in self._onStepCallbacks do
			local direction = callback(raycast, deltaTime)

			if typeof(direction) ~= "Vector3" and typeof(direction) ~= "number" then
				error(
					"onStep callbacks must return a Vector3 or a Flashcast.Result. if you do not wish to change the direction, return Flashcast.Result.Pass."
				)
			end

			if direction == Flashcast.Result.Pass then
				continue
			elseif direction == Flashcast.Result.Stop then
				task.spawn(thread)
				connection:Disconnect()
				return
			else
				raycast.direction = direction
			end
		end
	end)

	coroutine.yield()

	raycast.touched = nil
	return table.freeze(raycast)
end

function Flashcast.new()
	return {
		_onStepCallbacks = {} :: { OnStepCallback },
		onStep = onStep,
		cast = cast,
	}
end

export type Flashcast = typeof(Flashcast.new(...))

return Flashcast
