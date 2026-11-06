# RoPilot / Blender model handoff

The screenshot of the finished ATV shows the target art style, **not** the actual Blender object names, origins or dimensions. This code has not been fitted to the Blender export yet.

## Coordinate system
The chassis model's local **-Z is forward**, +Y is up, and +X is right. The vehicle pivot is the chassis center. These are Roblox-space coordinates, which must be converted from Blender's axes on export.

Default wheel mounting positions, in Roblox studs relative to the chassis center:
- FL (-2.35, 0.0, -2.15)
- FR (+2.35, 0.0, -2.15)
- RL (-2.35, 0.0, +2.15)
- RR (+2.35, 0.0, +2.15)

Wheel radius 1.32 studs and width 0.85 studs. Override Config if the Blender asset is larger or smaller.

## Visual mesh integration
1. Import the FBX using Roblox Studio 3D Importer; preserve separate wheels, chassis and body.
2. Weld visual chassis/body/engine/fenders to the physics `Chassis`, with **Massless=true, CanCollide=false, Anchored=false**.
3. Keep four wheel visuals named `Wheel_FL`, `Wheel_FR`, `Wheel_RL`, `Wheel_RR` inside the generated `Wheels` folder.
4. Wheel visuals should be anchored and non-colliding, and their **Model pivot** must coincide with the axle center. The script calls `Model:PivotTo` / changes the BasePart CFrame for visual motion each Heartbeat.
5. The four raycasts produce physical chassis forces: no wheel mesh collision required. Visual suspension arms/shocks are not implemented; create those as a separate, geometry-specific follow-up.
6. Delete placeholder wheel parts only after replacing them with your own matching named Models.
7. If wheel spin or steering appears reversed, adjust the visual CFrame composition in VehicleController; do not change the engine force sign blindly.
8. Do not weld animated wheels to the chassis and do not anchor anything welded to the chassis.

## What the system already calculates
Four independent suspension contacts, spring and damping loads, load-dependent tire grip, terrain friction, throttle response, AWD/RWD, forward/reverse, engine braking/coast resistance, steering angle, wheel mesh rotation, driver seat input, HUD.

## Known realism limits
The raycasts treat tires as point contacts; narrow obstacles/curbs, high-frequency terrain and rollover contact aren't modeled like full physical tires. No independent articulated wishbones, shock visuals, true engine gear ratios, drivetrain differential or validated multiplayer interpolation. This is the physics code for a test rig, not a verified vehicle release.

## Send to ChatGPT for an exact mesh integration
Blender hierarchy, model dimensions, four tire center coordinates, axle orientation, and photos from front/side/top. These details cannot be determined from the rendered screenshot alone.
