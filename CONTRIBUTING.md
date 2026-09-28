# Contributing to Permission Denied

Onboarding checklist and pipeline conventions for the team. Read the section(s)
for your role; everyone should read "Everyone" first.

## Everyone

1. Get added as a collaborator on `Shadowisp911/Permission-Denied-UVU` (GitHub, write access).
2. Install **Git** and **Git LFS**, then run `git lfs install` once per machine.
   Without this, cloning gets you broken LFS pointer files instead of real assets.
3. Install **Unreal Engine 5.8** via Epic Games Launcher - must match the
   project's `EngineAssociation` exactly.
4. `git clone https://github.com/Shadowisp911/Permission-Denied-UVU.git`
5. Open `Game Files/PermissionDenied_UVU/PermissionDenied_UVU.uproject`. First
   time only, it prompts to rebuild missing modules (compiles the `GitLFS2`
   plugin, a few minutes) - click Yes. Requires a C++ compiler, see
   "Compiler toolchain" below - this applies to every role, not just programmers,
   since this is a C++ project and the editor won't open without one.
6. Editor -> Edit -> Editor Preferences -> Source Control:
   - Provider: **Git LFS 2**
   - Check **"Uses Git LFS 2 File Locking workflow"**
   - Username: your **GitHub username, exactly** (not your local git config
     name - these can differ and it breaks lock ownership detection if they
     don't match)
7. **Locking workflow** (the reason all this is set up): before editing any
   `.uasset` or `.umap`, right-click it in the Content Browser -> **Check Out**.
   Red padlock = locked by you. Blue padlock = locked by someone else (hover to
   see who) - do not attempt to edit, you'll be blocked at push time even if you
   find a way to edit it locally. When done and pushed, **Check In** to release
   the lock for the next person.
8. If you ever lock a file and the editor still won't let you edit it, check
   that your username in step 6 exactly matches your GitHub username - this is
   the most common cause.

### Compiler toolchain

Any recent Visual Studio with the **"Game development with C++"** workload
works - confirmed working with both VS2022 and VS2026 on this project. No need
to install a specific year; whatever's easiest for you to get is fine. The
team hasn't standardized on one version, since both are known to build cleanly.

### Known issue: VisualStudioTools is disabled

The `VisualStudioTools` plugin (Microsoft's editor <-> Visual Studio jump-to-source
integration) is intentionally disabled in the `.uproject`. It throws a hard
`RulesError` on this specific engine install, confirmed to persist even after a
full Epic Games Launcher Verify/repair and a `-ForceRulesCompile` UBT override -
this is a real packaging gap (the plugin was added to the engine install after
its precompiled build-rules snapshot was baked, so UBT can never resolve it on
this machine's install). Not something fixable on our end. Impact: you lose
one-click jump-to-source between the editor and Visual Studio. Everything else
- IntelliSense, F12 go-to-definition inside VS, breakpoints, debugging - works
normally without it.

## C++ Programmers

- Same setup as "Everyone" above, plus make sure your Visual Studio install
  includes the C++ workload (see "Compiler toolchain").
- The Git plugin's internal module is named `GitLFS2` (renamed from the
  upstream `GitSourceControl` to avoid colliding with Epic's built-in plugin of
  the same name - see `Plugins/UEGitPlugin` if you ever need to touch its
  source). Not relevant to day-to-day gameplay/systems work, only if you're
  debugging source-control plugin code itself.
- C++ files (`.cpp`/`.h`) merge normally through Git, no locking needed. Any
  Blueprint or data asset you touch through the editor does need the lock
  workflow (step 7 above).

## Maya Artists

- Same "Everyone" setup, including the compiler toolchain requirement (needed
  to open the editor at all, even though you won't be writing C++).
- Set your Maya scene units to **centimeters** before exporting - Unreal's
  internal unit is always centimeters (fixed, not configurable per-project),
  and matching it in Maya avoids rescaling on every import.
- Export as **FBX** into
  `Assets & Working Files (Not in Game Yet)/3D Art/` (Props, Prop Kits, Level
  Kits, or Other - matching what you're making). This is a staging folder for
  source files, not the same as the in-engine `Content/` folder.
- `.fbx`, `.ma`/`.mb`, and texture formats (`.psd` etc.) are already Git-LFS
  tracked per `.gitattributes` - no extra setup needed, they transfer as LFS
  pointers automatically.
- Import into `Content/Developers/<YourName>/` while work is WIP (see "Dev
  folders" below). Once approved, move it into the shared
  `Content/Permission_Denied/Assets/3D_Art/` location.
- Once an asset exists in `Content/` as a `.uasset`, it's lockable - check it
  out before re-importing/updating it.

## Blender Artists

- Same "Everyone" setup, including the compiler toolchain requirement.
- **Export settings that are confirmed working for this project** (verified:
  1 meter in Blender = 1 meter in Unreal, exactly):
  - File -> Export -> FBX, expand the **Transform** section
  - **Forward**: `-Z Forward`
  - **Up**: `Y Up`
  - Consider saving these as a named export preset (the "+" next to the preset
    dropdown at the top of the export panel) so you don't have to reset them
    every time.
  - Apply all transforms before exporting (`Ctrl+A` -> All Transforms) - the
    most common cause of unexpected rotation/scale after import.
- Same collision/LOD naming conventions Unreal's FBX importer recognizes
  automatically, if you use them: `UCX_<MeshName>` for custom collision
  proxies, `<MeshName>_LOD0`/`_LOD1`/etc. for LOD chains.
- Export into `Assets & Working Files (Not in Game Yet)/3D Art/` - same
  staging convention as Maya, so nobody has to guess which folder to check
  based on which tool made the asset.
- `.blend` files are already Git-LFS tracked, so committing native scene files
  (not just exported FBX) is safe and won't bloat the repo.
- Same `Content/Developers/<YourName>/` -> shared `Content/` graduation flow
  as Maya artists, and same locking rules once assets are in `Content/`.

## Dev folders

`Content/Developers/<YourName>/` is Unreal's built-in convention for
work-in-progress content:
- Hidden from other people's Content Browser view by default (toggle: Content
  Browser filters -> "Hide Developer Content" - uncheck to see everyone's; also
  check "Show Empty Folders" if a freshly-created, still-empty dev folder isn't
  showing up).
- Excluded from cooking/packaging by default, so WIP test content never
  accidentally ships.
- Rename/move your own subfolder from inside the editor's Content Browser
  (right-click), not through Windows Explorer directly, so Unreal can update
  any internal references correctly.
- **Graduate finished assets out of your dev folder** into the shared
  `Content/Permission_Denied/` structure once they're approved - dev folders
  are a staging step, not a permanent home. If everything stays in personal
  dev folders, nobody else can find it.
- Never delete another team member's dev subfolder or the parent `Developers`
  folder itself - only your own subfolder underneath it.

## Project structure reference

```
Content/
  Developers/<name>/          WIP-only, hidden by default, not shipped
  Permission_Denied/
    Assets/2D_Art, 3D_Art/    Finished, in-engine assets
    Audio/Audio_Mixers, SFX, Soundtrack/
    Blueprint/Actors, Player_Character, System/
    Levels/Persistent_Data, Testing/

Assets & Working Files (Not in Game Yet)/
  2D Art/, 3D Art/, Audio/, Dev Folders/, Other/
                               Source files pending import - not yet in Content/
```
