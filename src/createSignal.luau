local function createConnection<T...>(signal: Signal<T...>, callback: (T...) -> ()): Connection
	local connection = {}
	connection._callback = callback
	connection._once = false
	connection.disconnected = false

	function connection:disconnect()
		if connection.disconnected then
			error("connection was already disconnected")
		end

		connection.disconnected = true

		local index = table.find(signal._connections, connection)
		if not index then
			error("failed to find connection")
		end

		table.remove(signal._connections, index)
	end

	return connection
end

local function createSignal<T...>(): Signal<T...>
	--- @class Signal
	local signal = {}
	signal._connections = {}
	signal._yieldedThreads = {}

	--- @within Signal
	function signal:connect(callback: (T...) -> ()): Connection
		local connection = createConnection(signal, callback)
		table.insert(signal._connections, connection)
		return connection
	end

	--- @within Signal
	function signal:once(callback: (T...) -> ()): Connection
		local connection = createConnection(signal, callback)
		connection._once = true
		table.insert(signal._connections, connection)
		return connection
	end

	--- @within Signal
	function signal:fire(...: T...)
		for index, connection in signal._connections do
			if connection._once then
				connection:disconnect()
			end

			task.spawn(connection._callback, ...)
		end
	end

	--- @within Signal
	function signal:wait(): T...
		local thread = coroutine.running()
		signal._yieldedThreads[thread] = true

		signal:once(function(...)
			signal._yieldedThreads[thread] = nil
			task.spawn(thread, ...)
		end)

		return coroutine.yield()
	end

	return signal
end

export type Signal<T...> = typeof(createSignal(...))
export type Connection = typeof(createConnection(...))

return createSignal
