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
Future.cancel = Constructors.Future.cancel
Future.poll = Constructors.Future.poll

return Future
