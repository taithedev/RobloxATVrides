# RobloxATVrides

A modular **constraint-driven ATV prototype** for Roblox Studio. RoPilot builds the visual meshes in Blender; this repository contains the Luau driving logic and a Studio-generated test chassis.

## Status
Code is uploaded but **not tested in Roblox Studio**. This is a working-oriented prototype, not a validated production vehicle. Suspension and handling require tuning against your imported model.

## Quick start
1. Open a new Roblox Studio baseplate.
2. Open **View > Command Bar**. Paste and run `studio/GenerateATV.server.luau` **in the Command Bar while editing**. It creates the ATV and its server scripts in the place.
3. Copy `src/StarterPlayerScripts/ATVClient.client.luau` into **StarterPlayer > StarterPlayerScripts** as a LocalScript named ATVClient.
4. Press Play, sit in the ATV seat, use W/S to drive and A/D to steer. R resets throttle/steering input locally (not the vehicle).
5. The test rig uses four physical wheels and independent vertical spring suspensions. Replace the visible parts with the Blender meshes only after confirming the physics rig works.

## Blender/RoPilot handoff
Export separate wheel meshes, chassis, body and moving suspension parts. Wheel mesh pivots must be at axle centers. Keep visual meshes Massless and CanCollide=false; attach them to the corresponding physics parts with WeldConstraints. Do not weld wheels to the chassis. Match the imported geometry to the four wheel positions in the generated test chassis.

## Architecture
- `src/ReplicatedStorage/ATV/Config.luau`: tuning values
- `src/ServerScriptService/ATV/Engine.luau`: throttle smoothing and torque
- `src/ServerScriptService/ATV/Steering.luau`: front steering target angles
- `src/ServerScriptService/ATV/VehicleController.server.luau`: seat controls, constraints, network ownership
- `src/StarterPlayerScripts/ATVClient.client.luau`: speed/RPM HUD
- `studio/GenerateATV.server.luau`: run-once Studio builder

The builder installs copies of the three server modules into the vehicle, so you can test immediately. For source-controlled production workflows, use Rojo and replace the embedded builder copies with the files under `src`.

## Limitations
This prototype uses Roblox wheel-ground contact and constraint motors, not a custom Pacejka tire solver. It has simple RPM estimation, no validated gearbox, no terrain-dependent friction, and no automated multiplayer test. The suspension is spring-guided vertical travel rather than full modeled double-wishbone linkage. Those features require iterative Studio testing and the final Blender geometry. Do not claim real-world physics accuracy.

## Safety
No untrusted client remote events control the engine; VehicleSeat input is read on the server. Server assigns network ownership only to the seated driver.

## Tuning
Adjust spring stiffness/damping to match vehicle mass and wheel travel. Values in Config are **Roblox physics units**, not SI N/m. Begin with a flat baseplate and gradually test bumps, slopes and turns.
