# Contributing to Permission Denied

Onboarding checklist and pipeline conventions for the team. Read the section(s)
for your role; everyone should read "Everyone" first.

The project is **Blueprint-only** (no C++), so nobody needs a compiler or
Visual Studio to open it. We do **not** use file locking - see "Working
together without locking" below.

## Everyone

1. Get added as a collaborator on `Shadowisp911/Permission-Denied-UVU` (GitHub,
   write access). The repo is public, so cloning needs no login, but pushing
   does need collaborator access.
2. Install **Git** and **Git LFS**, then run `git lfs install` once per machine.
   Without this, cloning gets you broken LFS pointer files instead of real
   assets. (`Tools/Setup-Repo.bat` does this and the clone for you.)
3. Install **Unreal Engine 5.8** via Epic Games Launcher - must match the
   project's `EngineAssociation` exactly.
4. `git clone https://github.com/Shadowisp911/Permission-Denied-UVU.git`
5. Open `Permission_Denied/Permission_Denied.uproject`.

That's it - no plugins to build, no per-machine editor settings.

## Working together without locking

`.uasset` and `.umap` files are binary and **cannot be merged**: if two people
change the same Blueprint or map, one person's changes will be lost. Since
nothing enforces exclusive editing, we do it by habit:

- **Pull before you start working**, and commit + push when you're done. Small,
  frequent commits mean fewer surprises.
- **Say so in team chat before you edit a shared map or Blueprint**, and wait if
  someone else already claimed it. One person per map/Blueprint at a time.
- Levels made in UE5 normally use One File Per Actor (you'll see
  `__ExternalActors__` folders), so two people can edit *different* actors in
  the same level - but the level file itself is still a single file, so still
  tell people before you touch it.
- Do experiments in your own `Content/Developers/<YourName>/` folder (see "Dev
  folders"), not in shared content.
- If you do hit a conflict on a `.uasset`/`.umap`, it can't be merged by hand.
  Keep one person's version (`git checkout --ours <file>` or `--theirs <file>`)
  and the other person redoes their change on top.
- Revision control inside the editor is optional. Epic's built-in Git plugin
  (Edit -> Plugins -> Git) gives status and commit/revert, but **not** locks. You
  can also just use GitHub Desktop or the command line.

## Maya Artists

- Set your Maya scene units to **centimeters** before exporting - Unreal's
  internal unit is always centimeters (fixed, not configurable per-project),
  and matching it in Maya avoids rescaling on every import.
- Export as **FBX**.
- `.fbx`, `.ma`/`.mb`, and texture formats (`.psd` etc.) are already Git-LFS
  tracked per `.gitattributes` - no extra setup needed, they transfer as LFS
  pointers automatically.
- Import into `Content/Developers/<YourName>/` while work is WIP (see "Dev
  folders" below), then move it into shared content once it's approved.

## Blender Artists

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
- `.blend` files are already Git-LFS tracked, so committing native scene files
  (not just exported FBX) is safe and won't bloat the repo.
- Same `Content/Developers/<YourName>/` -> shared content flow as Maya artists.

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
- **Graduate finished assets out of your dev folder** into shared content once
  they're approved - dev folders are a staging step, not a permanent home.
- Never delete another team member's dev subfolder or the parent `Developers`
  folder itself - only your own subfolder underneath it.

## If we ever add C++

Everyone would then need Visual Studio with the "Game development with C++"
workload (VS2022 and VS2026 both built UE 5.8 fine here). Note that the
`VisualStudioTools` plugin throws a hard `RulesError` on the launcher
UE 5.8 install used so far - keep it disabled in the `.uproject`.
