# RobloxATVrides — Real RoPilot ATV geometry + raycast physics

**Version 0.3.0 (integration draft, not Studio-tested).**

The attached `ATV[1].fbx` and `ATV_Package.zip` were inspected. The package has 165 visual meshes and 66,904 triangles, a 4.10-stud width, 6.107-stud length, 3.619-stud height, four 1.938-stud-diameter tires, and suspension/steering attachment positions. Those exact measurements now drive `Config.luau`.

The repository contains the Lua source and importer scripts; the binary Blender/FBX model and 40 textures **are not committed here**. Use the ZIP supplied in the ChatGPT conversation.

## Install in Roblox Studio
1. Unzip `ATV_Package.zip` on your PC.
2. Open Roblox Studio > a Baseplate place. Open **View > Command Bar** (Edit mode).
3. Copy and run **[studio/GenerateATV.server.luau](studio/GenerateATV.server.luau)** in the Command Bar. It creates the physics ATV, HUD, and all required scripts.
4. Open **3D Importer**, import `ATV/ATV.fbx` as a **Model named ATV** under Workspace, keeping all MeshParts separate. Import orientation must have vehicle front toward Roblox -Z. Model size should be about **4.100 X / 3.619 Y / 6.107 Z studs**.
5. Copy and run **[studio/ImportBlenderATV.server.luau](studio/ImportBlenderATV.server.luau)** in the Command Bar. It validates scale, attaches body meshes, mounts four wheel visual groups, and tags moving suspension visuals. The source asset moves to `ServerStorage.ATV_SourceBackup`.
6. Optionally run **[studio/SmokeTest.server.luau](studio/SmokeTest.server.luau)** in Edit mode for static structural checks.
7. Press Play, sit in the ATV's physical seat, and drive with W/S/A/D. Use Output to identify script exceptions and watch the suspension react to ground. **A real play test is required before release**.

## What the scripts implement
- Physics chassis using 4 independent spring/damper ground contacts, vertical weight transfer, and velocity-based damping.
- Four tire contact forces, surface-dependent grip, lateral slip, and a combined friction cap.
- AWD/RWD drive force, approximate RPM, throttle smoothing, reverse, braking, and coasting.
- Speed-sensitive steering applying tire forces using the steered front tire orientations.
- Wheel mesh suspension/travel/rotation and limited cosmetic arm/shock/handlebar articulation from imported mesh pivots.
- Server-authoritative driving with VehicleSeat; HUD with km/h, RPM, gear, drive mode and wheel contact.

## What is NOT implemented or verified
- Actual double wishbone constraint rig/physically articulated hub assemblies.
- Full spring stretching/deformation, steering linkage rig and CV shaft dynamics.
- Verified tire collision/contact patches, engine gearbox simulation or multiplayer prediction.
- Textures loaded automatically from local filenames; set SurfaceAppearance maps using Roblox asset IDs if import didn't preserve them.
- A validated Roblox Studio driving test or guarantee of no errors. Iterate on test findings.

## Source files
`src/ReplicatedStorage/ATV/Config.luau`: imported geometry, tuning, pivot coordinates.
`src/ServerScriptService/ATV/Engine.luau`: engine forces/RPM approximation.
`src/ServerScriptService/ATV/Steering.luau`: steering control.
`src/ServerScriptService/ATV/Suspension.luau`: wheel contact and forces.
`src/ServerScriptService/ATV/Tires.luau`: tire traction.
`src/ServerScriptService/ATV/VisualRig.luau`: cosmetic movable mesh articulation.
`src/ServerScriptService/ATV/VehicleController.server.luau`: main server loop.
`src/StarterPlayerScripts/ATVClient.client.luau`: HUD.
`studio/GenerateATV.server.luau`: stand-alone code generator, bundled from module sources.
`studio/ImportBlenderATV.server.luau`: asset integration with imported FBX.
`studio/SmokeTest.server.luau`: structural tests.
`docs/BlenderHandoff.md`: import measurements, textures and limitations.

## Debugging
- If the model is scaled/rotated incorrectly, correct FBX import settings first. The importer intentionally stops on XYZ size mismatch.
- If the spring chassis wobbles, tune sag and damping and verify the tire radius 0.969 matches your imported model.
- The visual shock rods and coils follow approximate pivots; inspect closely for intersection/overlap during travel.
- Static body meshes are welded/massless, wheel visuals anchored non-colliding. Keep their distinction.
- The generator replaces `Workspace.ZuzuATV` when rerun. Back up any custom work first.
- If the ATV HUD is blank, ensure a human is seated in `DriveSeat`, and Studio Output has no errors.

Physics docs: https://create.roblox.com/docs/reference/engine/classes/VectorForce
