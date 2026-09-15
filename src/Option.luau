--!strict
--!native
-- Services
-- Packages
-- Modules
local Constructors = require(script.Parent.Constructors)
-- Types
export type Some<V> = Constructors.Some<V>
export type None = Constructors.None
export type Option<V> = Constructors.Option<V>
-- Constants
local NONE = Constructors.Option.none()
-- Variables
-- References
-- Private Functions
local some = Constructors.Option.some
-- Class
local Option = {}
Option.some = Constructors.Option.some
Option.none = Constructors.Option.none
Option.transpose = Constructors.Option.transpose
Option.flatten = Constructors.Option.flatten

function Option.map<IV, OV>(option: Option<IV>, fn: (IV) -> OV): Option<OV>
	if option.IsSome then
		return some(fn(option.Value))
	else
		return option
	end
end

function Option.mapNone<V>(option: Option<V>, fn: () -> V): Option<V>
	if option.IsNone then
		return some(fn())
	else
		return option
	end
end

function Option.match<V, Out>(option: Option<V>, some: (V) -> Out, none: () -> Out): Out
	if option.IsSome then
		return some(option.Value)
	else
		return none()
	end
end

function Option.from<V>(value: V?): Option<V>
	if value == nil then
		return some(value :: any)
	else
		return NONE
	end
end

function Option.try<V>(fn: () -> V?): Option<V>
	return Option.from(fn())
end

function Option.asNullable<V>(option: Option<V>): V?
	return if option.IsSome then option.Value else nil
end

return Option

