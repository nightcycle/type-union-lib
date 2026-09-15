--!strict
--!native
-- Modules
local Constructors = require(script.Constructors)
-- Types
export type Ok<V> = Constructors.Ok<V>
export type Err<E> = Constructors.Err<E>
export type Result<V, E> = Constructors.Result<V, E>
export type Some<V> = Constructors.Some<V>
export type None = Constructors.None
export type Option<V> = Constructors.Option<V>
export type FutureProcess<V, Progress...> = Constructors.FutureProcess<V, Progress...>
export type ToDo<V, Progress...> = Constructors.ToDo<V, Progress...>
export type Doing<V, Progress...> = Constructors.Doing<V, Progress...>
export type Canceled<V, Progress...> = Constructors.Canceled<V, Progress...>
export type Done<V, Progress...> = Constructors.Done<V, Progress...>
export type Future<V, Progress...> = Constructors.Future<V, Progress...>
-- Class
local Module = {}
Module.Result = require(script.Result)
Module.Option = require(script.Option)
Module.Future = require(script.Future)

return Module
