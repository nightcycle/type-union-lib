--!strict
--!native
-- Services
-- Packages
-- Modules
local Constructors = require(script.Parent.Constructors)
-- Types
export type Future<V, Progress...> = Constructors.Future<V, Progress...>
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
local Future = {}

Future.toDo = Constructors.Future.toDo
Future.await = Constructors.Future.await
Future.timeout = function<V, Progress...>(
	future: Constructors.ToDo<V, Progress...> | Constructors.Doing<V, Progress...>,
	duration: number
): Constructors.Done<V, Progress...> | Constructors.Canceled<V, Progress...>
	local pollFuture = Constructors.Future.poll(future)
	local startTick = tick()
	while pollFuture.IsDoing and tick() - startTick <= duration do
		task.wait()
		pollFuture = Constructors.Future.poll(pollFuture)
	end
	if pollFuture.IsDoing then
		pollFuture = Constructors.Future.cancel(pollFuture)
	end
	assert(pollFuture.IsDoing == false, `expected IsDoing to be false, received true`)
	return pollFuture
end
Future.cancel = Constructors.Future.cancel
Future.poll = Constructors.Future.poll
Future.progress = Constructors.Future.progress

return Future
