--!strict
--!native
-- Services
-- Packages
-- Modules
local Constructors = require(script.Parent.Constructors)
-- Types
export type Ok<V> = Constructors.Ok<V>
export type Err<E> = Constructors.Err<E>
export type Result<V, E> = Constructors.Result<V, E>
export type TryFn<V, E> = (() -> (false, E)) & (() -> (true, V))
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
local Result = {}

Result.ok = Constructors.Result.ok
Result.err = Constructors.Result.err
Result.transpose = Constructors.Result.transpose
Result.flatten = Constructors.Result.flatten

function Result.map<IV, OV, E>(result: Result<IV, E>, fn: (IV) -> OV): Result<OV, E>
	if result.IsOk then
		return Result.ok(fn(result.Value))
	else
		return result
	end
end

function Result.mapErr<V, IE, OE>(result: Result<V, IE>, fn: (IE) -> OE): Result<V, OE>
	if result.IsErr then
		return Result.err(fn(result.Value))
	else
		return result
	end
end

function Result.match<V, E, Out>(result: Result<V, E>, ok: (V) -> Out, err: (E) -> Out): Out
	if result.IsOk then
		return ok(result.Value)
	else
		return err(result.Value)
	end
end

function Result.from<V, E>(success: boolean, value: V | E): Result<V, E>
	if success == true then
		return Result.ok(value :: any)
	else
		return Result.err(value :: any)
	end
end

function Result.try<V, E>(fn: TryFn<V, E>): Result<V, E>
	local success, value = fn()
	return Result.from(success :: boolean, value :: V | E)
end

function Result.asNullable<V, E>(result: Result<V, E>): V?
	return if result.IsOk then result.Value else nil
end

function Result.unwrap<V, E>(result: Result<V, E>): V
	assert(result.IsOk, `result is err: "{result.Value}"`)
	return result.Value
end

function Result.unwrapErr<V, E>(result: Result<V, E>): E
	assert(result.IsErr, `result is ok: "{result.Value}"`)
	return result.Value
end

function Result.pcall<V>(fn: () -> V): Result<V, string>
	local value: V?
	local success, msg = pcall(function()
		value = fn()
	end)
	return if success and value ~= nil
		then Result.ok(value)
		elseif msg then Result.err(msg)
		else Result.err(`fn returned nil`)
end

return Result
