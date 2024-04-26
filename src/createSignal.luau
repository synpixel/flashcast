local function createConnection<T...>(signal: Signal<T...>, callback: (T...) -> ()): Connection
	local connection = {}
	connection._callback = callback
	connection._once = false
	connection.connected = false

	function connection:disconnect()
		if not connection.connected then
			error("connection was already disconnected")
		end

		connection.connected = false
		connection.Connected = connection.Connected

		local index = table.find(signal._connections, connection)
		if not index then
			error("failed to find connection")
		end

		table.remove(signal._connections, index)
	end

	connection.Connected = connection.connected
	connection.Disconnect = connection.disconnect

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

	-- support for libraries requiring signal-like objects
	signal.Connect = signal.connect
	signal.Once = signal.once
	signal.Fire = signal.fire
	signal.Wait = signal.Wait

	return signal
end

export type Signal<T...> = typeof(createSignal(...))
export type Connection = typeof(createConnection(...))

return createSignal
