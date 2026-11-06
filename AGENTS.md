# AGENTS.md — RobloxATVrides

You are editing a Roblox Luau ATV driving project. Read `tasks/CODEX_ATV_FINISH.md` first.

## Goal and boundaries
- The user already ran `studio/GenerateATV.server.luau` in a locally open Roblox Studio place. The next goal is finishing a playable ATV with the **actual RoPilot model** while minimizing manual steps.
- The uploaded FBX is **not present in this GitHub repository**. Its authoritative geometry is described in `assets/ATV_geometry.json`, and in `docs/BlenderHandoff.md`. Do not claim the mesh is included.
- GitHub commits and Codex cloud code edits **do not modify an already-open Roblox Studio scene** without an explicit sync, plugin or local computer connection. Never claim a play test happened unless you have a real Studio test log.
- Do not invent Luau/Studio APIs. Use supported Roblox APIs and clearly distinguish a raycast chassis with visual suspension from mechanical constraints.
- Current code is an unverified prototype. Diagnose and fix actual bugs, prioritize user-visible playability and stable vehicle behavior, and keep README claims honest.

## Repository workflow
- Entry: `studio/GenerateATV.server.luau` is a self-contained one-paste Studio Edit-mode installer with embedded source. `src/` modules are the authoritative sources. **Keep embedded copies synchronized** when modifying `src/`.
- Imported FBX adapter: `studio/ImportBlenderATV.server.luau`. It expects `Workspace.ATV` as a Studio-imported, separate-mesh Model. Import orientation/scale may require manual correction.
- Keep all driver-affecting forces and replication server-controlled until robust multiplayer tests justify a change.
- Do not require the user to rerun the original generator unless essential. Prefer a **safe upgrade installer** that operates on the existing `Workspace.ZuzuATV` with backup and clear idempotency.
- Preserve / document existing edited vehicle parts when possible. Do not destroy user work silently.
- Use **W/S throttle/braking and A/D steering**, player-friendly controls and visible HUD.

## Checks
Run `python tests/check_source_sync.py` after changing scripts. It checks embedded source consistency, not Luau semantics or Roblox physics. If a Roblox Studio execution environment is unavailable, report this limitation.
