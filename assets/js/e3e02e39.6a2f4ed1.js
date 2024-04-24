"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[914],{28530:e=>{e.exports=JSON.parse('{"functions":[{"name":"worldRoot","desc":"Overrides the default [WorldRoot](https://create.roblox.com/docs/reference/engine/classes/WorldRoot) ([Workspace](https://create.roblox.com/docs/reference/engine/classes/Workspace))\\r","params":[{"name":"worldRoot","desc":"","lua_type":"WorldRoot"}],"returns":[{"desc":"","lua_type":"Flashcast"}],"function_type":"method","source":{"line":45,"path":"src/init.luau"}},{"name":"tick","desc":"Configures the amount of rays cast per second\\n:::info\\nIf the tick passed is a callback, it will run every frame. This is not for expensive operations.\\r","params":[{"name":"tick","desc":"","lua_type":"number | (raycast: Raycast) -> number"}],"returns":[{"desc":"","lua_type":"Flashcast"}],"function_type":"method","source":{"line":57,"path":"src/init.luau"}},{"name":"beforeStep","desc":"Adds a step callback scheduled to run before calculations\\r","params":[{"name":"step","desc":"","lua_type":"StepCallback"}],"returns":[{"desc":"","lua_type":"Flashcast"}],"function_type":"method","source":{"line":67,"path":"src/init.luau"}},{"name":"afterStep","desc":"Adds a step callback scheduled to run after calculations\\r","params":[{"name":"step","desc":"","lua_type":"StepCallback"}],"returns":[{"desc":"","lua_type":"Flashcast"}],"function_type":"method","source":{"line":77,"path":"src/init.luau"}},{"name":"spatialQuery","desc":"Overrides the default spatial query ([WorldRoot.Raycast](https://create.roblox.com/docs/reference/engine/classes/WorldRoot#Raycast))\\r","params":[{"name":"query","desc":"","lua_type":"(worldRoot: WorldRoot, origin: Vector3, direction: Vector3, raycast: Raycast) -> RaycastResult?"}],"returns":[{"desc":"","lua_type":"Flashcast"}],"function_type":"method","source":{"line":87,"path":"src/init.luau"}},{"name":"cast","desc":"","params":[{"name":"origin","desc":"","lua_type":"Vector3"},{"name":"direction","desc":"","lua_type":"Vector3"},{"name":"raycastParams?","desc":"","lua_type":"RaycastParams"},{"name":"defaultState?","desc":"","lua_type":"{ [any]: any }"}],"returns":[{"desc":"","lua_type":"Raycast"}],"function_type":"method","source":{"line":107,"path":"src/init.luau"}},{"name":"clear","desc":"Stops all active raycasts\\r","params":[],"returns":[],"function_type":"method","source":{"line":151,"path":"src/init.luau"}},{"name":"destroy","desc":"Enables the Flashcast instance to be garbage collected\\r","params":[],"returns":[],"function_type":"method","source":{"line":160,"path":"src/init.luau"}},{"name":"new","desc":"","params":[],"returns":[{"desc":"","lua_type":"Flashcast"}],"function_type":"static","source":{"line":229,"path":"src/init.luau"}}],"properties":[{"name":"Result","desc":"Different results (outcomes) of step callbacks\\r","lua_type":"{ Stop }","source":{"line":36,"path":"src/init.luau"}}],"types":[{"name":"StepCallback","desc":"Takes a Raycast instance and delta time and gives back a [Result](/api/Flashcast/#Result)\\r","lua_type":"(raycast: Raycast, deltaTime: number) -> Result?","source":{"line":7,"path":"src/init.luau"}},{"name":"Raycast","desc":"","fields":[{"name":"position","lua_type":"Vector3","desc":""},{"name":"direction","lua_type":"Vector3","desc":""},{"name":"raycastParams?","lua_type":"RaycastParams","desc":""},{"name":"results","lua_type":"{ RaycastResult }","desc":"RaycastResults ordered from earliest to latest"},{"name":"state","lua_type":"{ lastTick: number, distanceTraveled: number, touched?: RaycastResult, [any]: any }","desc":"for preserving state throughout the raycasting"},{"name":"tick","lua_type":"number | (raycast: Raycast) -> number","desc":"by default the Flashcast instance\'s tick"},{"name":"stopped","lua_type":"Signal<()>","desc":""},{"name":"stop","lua_type":"(self: Raycast) -> ()","desc":""}],"source":{"line":19,"path":"src/init.luau"}}],"name":"Flashcast","desc":"","source":{"line":31,"path":"src/init.luau"}}')}}]);