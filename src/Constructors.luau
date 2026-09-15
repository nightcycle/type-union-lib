--!strict
--!native
-- Types
export type Ok<V> = {
	Type: "Result",
	IsOk: true,
	IsErr: false,
	Value: V,
}
export type Err<E> = {
	Type: "Result",
	IsOk: false,
	IsErr: true,
	Value: E,
}
export type Result<V, E> = Ok<V> | Err<E>
type NestedResult<V, E> =
	Result<V | NestedResult<V, E>, E>
export type Some<V> = {
	Type: "Option",
	IsSome: true,
	IsNone: false,
	Value: V,
}
export type None = {
	Type: "Option",
	IsSome: false,
	IsNone: true,
	Value: nil,
}
export type Option<V> = Some<V> | None
type NestedOption<V> =
	Option<V | NestedOption<V>>

type GetValueError = "Incomplete" | "Canceled"
export type FutureProcess<V, Progress...> = (
	complete: (V) -> (),
	getIfCanceled: () -> boolean,
	cancel: () -> (),
	setProgress: (Progress...) -> ()
) -> ()
export type ToDo<V, Progress...> = {
	Type: "Future",
	IsTodo: true,
	IsDoing: false,
	IsCanceled: false,
	IsDone: false,
	Fn: FutureProcess<V, Progress...>,
}
export type Doing<V, Progress...> = {
	Type: "Future",
	IsTodo: false,
	IsDoing: true,
	IsCanceled: false,
	IsDone: false,
	_Cancel: () -> (),
	_GetProgress: () -> Option<() -> Progress...>,
	_GetValue: () -> Result<V, GetValueError>,
	Fn: FutureProcess<V, Progress...>,
}
export type Canceled<V, Progress...> = {
	Type: "Future",
	IsTodo: false,
	IsDoing: false,
	IsCanceled: true,
	IsDone: false,
	Fn: FutureProcess<V, Progress...>,
}
export type Done<V, Progress...> = {
	Type: "Future",
	IsTodo: false,
	IsDoing: false,
	IsCanceled: false,
	IsDone: true,
	Fn: FutureProcess<V, Progress...>,
	Value: V,
}
export type Future<V, Progress...> = ToDo<V, Progress...> | Doing<V, Progress...> | Canceled<V, Progress...> | Done<V, Progress...>
-- Constants
local RESULT_TYPE: "Result" = "Result"
local OPTION_TYPE: "Option" = "Option"
local NONE: None = table.freeze({
	Type = OPTION_TYPE,
	IsSome = false :: false,
	IsNone = true :: true,
	Value = nil,
})
-- Private Functions
local function ok<V>(value: V): Ok<V>
	return table.freeze({
		Type = RESULT_TYPE,
		IsOk = true :: true,
		IsErr = false :: false,
		Value = value,
	})
end

local function err<E>(value: E): Err<E>
	return table.freeze({
		Type = RESULT_TYPE,
		IsOk = false :: false,
		IsErr = true :: true,
		Value = value,
	})
end

local function flattenResult<V,E>(nestedResult: NestedResult<V,E>): Result<V,E>
	if nestedResult.IsOk then
		if type(nestedResult.Value) == "table" and rawget(nestedResult.Value, "Type") == "Result" then
			return flattenResult(nestedResult.Value)
		else
			return nestedResult :: any
		end
	else
		return nestedResult
	end
end

local function some<V>(value: V): Some<V>
	return table.freeze({
		Type = OPTION_TYPE,
		IsSome = true :: true,
		IsNone = false :: false,
		Value = value,
	})
end

function none(): None
	return NONE
end

local function flattenOption<V,E>(nestedOption: NestedOption<V>): Option<V>
	if nestedOption.IsSome then
		if type(nestedOption.Value) == "table" and rawget(nestedOption.Value, "Type") == "Option" then
			return flattenOption(nestedOption.Value)
		else
			return nestedOption :: any
		end
	else
		return NONE
	end
end
local function transposeResult<V, E>(result: Result<V, E>): Option<V>
	return if result.IsOk then some(result.Value) else NONE
end

local function transposeOption<V, E>(option: Option<V>, e: E): Result<V, E>
	return if option.IsSome then ok(option.Value) else err(e)
end

local function toDo<V, Progress>(fn: FutureProcess<V, Progress>): ToDo<V, Progress>
	return table.freeze({
		Type = "Future" :: "Future",
		IsTodo = true :: true,
		IsDoing = false :: false,
		IsCanceled = false :: false,
		IsDone = false :: false,
		Fn = fn,
	})
end

local function doing<V, Progress...>(future: ToDo<V, Progress...>): Doing<V, Progress...>
	local progress: Option<() -> (Progress...)> = none()
	local valueRes: Result<V, GetValueError> = err("Incomplete" :: GetValueError) :: Err<GetValueError>
	local fn = future.Fn
	task.spawn(function()
		fn(function(value)
			if valueRes.IsErr and valueRes.Value == "Incomplete" then
				valueRes = ok(value)
			end
		end, function()
			return if valueRes.IsErr then valueRes.Value == "Canceled" else false
		end, function()
			valueRes = err("Canceled" :: GetValueError) :: Err<GetValueError>
		end, function(...: Progress...)
			local args: any = table.pack(...)
			progress = some(function(): Progress...
				return table.unpack(args)
			end)
		end)
	end)
	return table.freeze({
		Type = "Future" :: "Future",
		IsTodo = false :: false,
		IsDoing = true :: true,
		IsCanceled = false :: false,
		IsDone = false :: false,
		_Cancel = function()
			valueRes = err("Canceled" :: GetValueError) :: Err<GetValueError>
		end,
		_GetProgress = function(): Option<() -> (Progress...)>
			return progress
		end,
		_GetValue = function(): Result<V, GetValueError>
			return valueRes
		end,
		Fn = fn,
	})
end

local function done<V, Progress...>(future: Doing<V, Progress...>, value: V): Done<V, Progress...>
	return table.freeze({
		Type = "Future" :: "Future",
		IsTodo = false :: false,
		IsDoing = false :: false,
		IsCanceled = false :: false,
		IsDone = true :: true,
		Value = value,
		Fn = future.Fn,
	})
end

local function cancel<V, Progress...>(future: Doing<V, Progress...>): Canceled<V, Progress...>
	return table.freeze({
		Type = "Future" :: "Future",
		IsTodo = false :: false,
		IsDoing = false :: false,
		IsCanceled = true :: true,
		IsDone = false :: false,
		Fn = future.Fn,
	})
end

local function poll<V, Progress...>(
	future: Doing<V, Progress...> | ToDo<V, Progress...>
): Doing<V, Progress...> | Done<V, Progress...> | Canceled<V, Progress...>
	local doingFuture: Doing<V, Progress...> = if future.IsDoing then future else doing(future)
	local valueRes = doingFuture._GetValue()
	if valueRes.IsOk then
		return done(doingFuture, valueRes.Value)
	else
		if valueRes.Value == "Canceled" then
			return cancel(doingFuture)
		else
			return doingFuture
		end
	end
end

local function await<V, Progress...>(future: ToDo<V, Progress...> | Doing<V, Progress...>): Done<V, Progress...> | Canceled<V, Progress...>
	local pollFuture = poll(future)
	while pollFuture.IsDoing do
		task.wait()
		pollFuture = poll(pollFuture)
	end
	assert(pollFuture.IsDoing == false, `expected IsDoing to be false, received true`)
	return pollFuture
end

return {
	Result = {
		err = err,
		ok = ok,
		transpose = transposeResult,
		flatten = flattenResult,
	},
	Option = {
		none = none,
		some = some,
		transpose = transposeOption,
		flatten = flattenOption,
	},
	Future = {
		toDo = toDo,
		await = await,
		cancel = cancel,
		poll = poll,
	},
}
