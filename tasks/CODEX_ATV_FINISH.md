# Codex task: finish the user's working Roblox ATV with minimal actions

**Repository:** `taithedev/RobloxATVrides`
**User situation:** The owner has **already executed** `studio/GenerateATV.server.luau` in an open Roblox Studio place and wants the full detailed RoPilot ATV working. They specifically don't want to repeat manual import/setup steps. Act on the repository as much as technically possible, but **do not falsely claim** you remotely controlled Studio.

## Deliverable
Improve the code into a stable, testable playable ATV using the attached asset's published geometry specification. Where Roblox requires local file selection, permissions, or a plugin, reduce it to a single obvious user action and state that action exactly. If you can operate their local Studio via an authorized local environment, do so; otherwise don't imply cloud edits affect their existing Studio scene.

## Source asset
The actual Blender `ATV[1].fbx` and `ATV_Package.zip` were shared in the user's original ChatGPT conversation but are **not stored in GitHub**. The ZIP has `ATV/ATV.blend`, `ATV/ATV.fbx`, `ATV/ATV_Collision.fbx`, 40 PBR PNG maps, `ATV/ATV_Manifest.json`, `ATV/ATV_Hierarchy.txt`. Do not fabricate access to binary files; if mesh upload is unavailable, implement everything possible and provide a safe import/sync handoff.

Reference measurements and pivot data: `assets/ATV_geometry.json`, `src/ReplicatedStorage/ATV/Config.luau`, `docs/BlenderHandoff.md`.
Model appearance: rusty orange/olive ATV, exposed suspension, four knobby tires.

## Work plan
1. Inspect all existing code critically. Fix syntax issues, incorrect forward/side axes, suspension raycast load/tire contact, throttle/brake signs, yaw steering, wheel spin around axle, anchored-wheel visual replication, player seat/HUD behavior, and importer naming assumptions. Don't assert functionality from code review alone.
2. Create a **single idempotent `studio/UpgradeExistingATV.server.luau`** command-bar script that updates the pre-existing `Workspace.ZuzuATV` without deleting user setup; syncs modules, installs visual rig, fixes wheel groups and HUD; accepts an optional already-imported Workspace.ATV and applies integration. If no asset imported, it should retain a working test chassis and show a clear missing-asset warning.
3. Keep physical suspensions independent. Favor a stable raycast chassis if fully constrained double wishbone physics cannot be validated. Visually rig shocks, arms, and wheels using the exact mesh naming and corner pivots. Distinguish cosmetic arm movement from wheel forces.
4. Audit `studio/ImportBlenderATV.server.luau` for clone/offset/world-origin mistakes and orientation. Add a non-destructive import path; let the user's original ATV source stay available and do not overwrite an existing asset unintentionally.
5. Add deterministic source-sync and geometry contract tests, plus optional Studio smoke checks that print meaningful diagnostics.
6. Keep `src/` files and generated standalone Studio scripts in sync; update README and a very short one-click instructions page.
7. If an accessible Roblox Studio automation/MCP environment truly exists, run tests and capture Output; otherwise explicitly mark physics tests unverified.

## Acceptance
- W/S throttle and reverse, A/D speed-sensitive steering and braking function as code intended.
- Independent raycast wheel force and terrain grip are computed from chassis geometry.
- Dashboard speed/RPM/gear updates for seated player.
- No trust in arbitrary client-provided speed/force values.
- User's current `Workspace.ZuzuATV` can be upgraded without recreating the place.
- The exact RoPilot geometry mapping is retained.
- Code diff, test results, known limitations, and one minimal local user action (if absolutely necessary) are documented.

If you cannot import an FBX or control the owner's Studio, say so, do everything else you can, and do **not** write "done" as though the finished model was installed.
