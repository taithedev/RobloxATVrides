# Integration for the supplied RoPilot ATV (version 0.3)

Actual files inspected: `ATV[1].fbx` and `ATV_Package.zip`.
The ZIP includes `ATV.blend`, `ATV.fbx`, `ATV_Collision.fbx`, `ATV_Manifest.json`, `ATV_Hierarchy.txt`, `ATV_README.md`, and 40 texture PNGs. No binary files are stored in this repository.

Measured from the author's manifest:
- Overall dimension 4.1002 × 6.1068 × 3.6186 Blender units, each intended as one Roblox stud.
- Wheel centers Blender units: FL (-1.65,-2.05,1.00), FR (+1.65,-2.05,1.00), RL (-1.65,+2.05,1.00), RR (+1.65,+2.05,1.00).
- Tire diameter is about 1.938 studs (from actual mesh bounds), width about 0.80 studs.
- Front = Blender -Y = Roblox -Z; up = Blender +Z = Roblox +Y.
- Suspension upper shock points: FL (-.58,-2.0,2.12), FR (+.58,-2.0,2.12), RL (-.58,+2.1,2.12), RR (+.58,+2.1,2.12).
- Chassis simulation origin is designed at Blender (0,0,1.65), not the Blender scene origin.

## Step-by-step (Edit mode)
1. Download the ZIP if needed; extract it locally. In Studio's 3D Importer, choose `ATV/ATV.fbx`. Preserve parts as separate MeshParts and maintain Blender dimensions (vehicle length about 6.107 studs). Import into Workspace as a Model named `ATV`.
2. Open Studio **Command Bar** (edit mode) and run the full contents of `studio/GenerateATV.server.luau` (this creates `workspace.ZuzuATV` and its controller/HUD).
3. Run the full contents of `studio/ImportBlenderATV.server.luau` in the same **Command Bar**. It finds `workspace.ATV`, verifies bounding-box dimensions, and clones the meshes onto your generated vehicle.
4. Press Play and sit in `ZuzuATV.DriveSeat`. W/S throttle, A/D steering. Watch Output for errors and observe tire/suspension.
5. Configure the imported MeshParts' `SurfaceAppearance` manually if the FBX importer did not preserve the PBR maps. The ZIP textures are the source, with `*_BaseColor`, `*_Normal`, `*_Roughness`, `*_Metalness` names; Roblox uses their uploaded asset IDs in SurfaceAppearance, not local disk paths.

### Importer behavior
- The importer backs up the raw model under `ServerStorage/ATV_SourceBackup` after cloning.
- Static mesh parts are made non-colliding/massless and welded to the physics hull.
- Tires/rims/fasteners are grouped by wheel ID under the correct wheel-center pivot.
- The front/rear arms, knuckles, shocks and handlebars are separated as animated visual-only MeshParts. They are cosmetically posed based on raycast wheel travel; geometry isn't mechanically articulated by Roblox constraints.
- `ATV_Collision.fbx` is not currently used as the four simulated tire collisions are raycast-driven; a simple physics chassis block collides with world obstacles.
- Re-running the importer overwrites prior attached custom visuals on the generated ATV. Back up before doing so.

### Validation
We have **not** run a Roblox Studio play test here; the scripts are integration-ready but unverified in-engine. Mesh positioning relies on Studio's FBX axis/scale handling. The import command intentionally rejects bounding-box scale mismatches; manually inspect orientation before integration.

### Remaining physical realism work
The original mesh package has authentic arm/shock pivots; the present physics chassis uses independent vertical raycasts, not actual wishbone constraints, tire collision shapes, or fully compressed spring mesh deformation. Detailed real-time rigging, multiplayer driving latency and engine sound need Studio validation.
