# RobloxATVrides — ATV physics and Roblox Studio setup

**Version 0.2.0 — untested Studio prototype.** Code has been uploaded to GitHub, but hasn't been executed in Roblox Studio in this session. The finished Blender ATV image is a visual reference; the actual .blend/.fbx geometry wasn't supplied.

## What is included
- Four independent **raycast spring/damper suspensions** applying real forces to the chassis using `VectorForce`.
- Speed-sensitive front-wheel steering using tire force orientation (not a mechanical hinge).
- Throttle smoothing, approximate engine RPM, acceleration, reverse, braking and coasting.
- AWD/RWD power distribution, load-limited traction, lateral slip and material grip.
- Four moving/steering/spinning non-colliding visual wheels.
- Server-controlled physics and a VehicleSeat driver.
- Live HUD showing speed, RPM, D/N/R, drive mode and grounded-wheel count.
- One-paste Studio generator and static hierarchy smoke test.

## Quick start — no external packages
1. Open Roblox Studio and make a Baseplate place.
2. Open the **Command Bar** in Studio's edit mode.
3. Copy all of [studio/GenerateATV.server.luau](studio/GenerateATV.server.luau) into the Command Bar and run once.
4. It creates `workspace.ZuzuATV` and installs the vehicle scripts and `StarterPlayerScripts.ATVClient`.
5. Click **Play**. Sit in `ZuzuATV.DriveSeat`. Drive using **W/S** (throttle/reverse/braking) and **A/D** (steering).
6. Watch Studio **Output** for errors. Run [studio/SmokeTest.server.luau](studio/SmokeTest.server.luau) in the edit-mode Command Bar to check the generated hierarchy. The smoke test is **not** a physical driving test.

## Troubleshooting
- If the ATV sinks, bounces or flies: check that the `Chassis` is unanchored, the generated Baseplate exists, and tune `SuspensionSagFraction`, `SuspensionDampingRatio`, `WheelRadius` and `WheelMounts` in Config.
- If wheels seem disconnected: expected for this raycast system; wheels are non-colliding visuals. Actual vehicle movement comes from the four ground-contact forces.
- If steering appears reversed: test the Roblox VehicleSeat steering sign and adjust it in `VehicleController`, not the engine acceleration sign.
- If a Blender wheel rotates around the wrong origin: fix its pivot at the axle and re-import.
- If the chassis rubs the ground: raise clearance, correct wheel dimensions, or change the collision hull.
- If you rerun the generator, it deletes and replaces the prior `workspace.ZuzuATV`. Back up customizations first.
- If no client HUD appears, check that `StarterPlayer > StarterPlayerScripts > ATVClient` exists and your character is seated.

## Source tree
- `src/ReplicatedStorage/ATV/Config.luau` — tunables
- `src/ServerScriptService/ATV/Engine.luau` — throttle and longitudinal force
- `src/ServerScriptService/ATV/Steering.luau` — steering angle and smoothing
- `src/ServerScriptService/ATV/Suspension.luau` — spring-damper raycasts
- `src/ServerScriptService/ATV/Tires.luau` — friction-circle grip and terrain
- `src/ServerScriptService/ATV/VehicleController.server.luau` — runtime assembly and loops
- `src/StarterPlayerScripts/ATVClient.client.luau` — HUD
- `studio/GenerateATV.server.luau` — one-shot generator embedding exact sources above
- `studio/SmokeTest.server.luau` — static hierarchy assertions
- `docs/BlenderHandoff.md` — attaching RoPilot meshes

The generator embeds copies of the source modules, so if you change a file under `src`, regenerate or update the corresponding embedded source. The repository layout is for code organization; copying the modules directly into the vehicle model is the supported manual install path.

## Realism and testing limits
This is a raycast chassis (physical suspension/tire forces, visual wheels), not a fully articulated mechanical suspension with four physically constrained wheel assemblies. It has no real gearbox, per-wheel angular inertia, advanced collision-tire model, differential, dynamic sounds, custom suspension arm animation, or verified multiplayer performance. Server authority prioritizes validation and resistance to client tampering over maximum local responsiveness.

**There is no claimed Roblox Studio test pass.** Test flat-ground drive, turns, braking, bumps, rough terrain, slope starts, transitions between materials and multiplayer before release. Tuning is intentionally exposed.

## Roblox technical references
- https://create.roblox.com/docs/reference/engine/classes/VectorForce
- https://create.roblox.com/docs/reference/engine/classes/WorldRoot
- https://create.roblox.com/docs/reference/engine/classes/BasePart
- https://create.roblox.com/docs/reference/engine/classes/VehicleSeat
