"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[914],{28530:e=>{e.exports=JSON.parse('{"functions":[{"name":"new","desc":"creates a new flashcast instance\\r","params":[{"name":"options?","desc":"","lua_type":"FlashcastOptions"}],"returns":[],"function_type":"static","source":{"line":150,"path":"src/init.luau"}},{"name":"createBehavior","desc":"creates a new behavior\\r","params":[],"returns":[{"desc":"","lua_type":"Behavior"}],"function_type":"static","source":{"line":155,"path":"src/init.luau"}},{"name":"getBullets","desc":"gets every bullet in the instance\\r","params":[],"returns":[{"desc":"","lua_type":"{ Bullet }"}],"function_type":"method","source":{"line":160,"path":"src/init.luau"}},{"name":"spawnBullet","desc":"spawns a bullet with a behavior\\r","params":[{"name":"behavior","desc":"","lua_type":"Behavior"},{"name":"origin","desc":"","lua_type":"Vector3"},{"name":"direction","desc":"","lua_type":"Vector3"},{"name":"raycastParams?","desc":"","lua_type":"RaycastParams"}],"returns":[{"desc":"","lua_type":"Bullet"}],"function_type":"method","source":{"line":169,"path":"src/init.luau"}},{"name":"step","desc":"used internally to advance every bullet by one step\\r","params":[],"returns":[],"function_type":"method","source":{"line":173,"path":"src/init.luau"}},{"name":"clear","desc":"clears all bullets in the instance\\r","params":[],"returns":[],"function_type":"method","source":{"line":177,"path":"src/init.luau"}},{"name":"destroy","desc":"enables the instance to be garbage collected (also clears all bullets)\\r","params":[],"returns":[],"function_type":"method","source":{"line":181,"path":"src/init.luau"}}],"properties":[],"types":[{"name":"FlashcastOptions","desc":"","fields":[{"name":"worldRoot?","lua_type":"WorldRoot","desc":"default: Workspace"},{"name":"event?","lua_type":"RBXScriptSignal","desc":"default: RunService.Heartbeat"}],"source":{"line":9,"path":"src/init.luau"}}],"name":"Flashcast","desc":"","source":{"line":145,"path":"src/init.luau"}}')}}]);