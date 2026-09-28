# Git LFS File Locking Setup

This project uses the **Git LFS 2** plugin (`Plugins\UEGitPlugin` in this repo, a
fork of Epic's built-in Git plugin maintained by Project Borealis) instead of
Unreal's built-in Git plugin. Reason: Epic's built-in plugin cannot lock binary
files (`.uasset`, `.umap`), so two people editing the same Blueprint or map at
once will silently destroy one person's work on merge. The Git LFS 2 plugin adds
lock/unlock support with padlock icons in the Content Browser.

## No per-machine setup required

Earlier versions of this doc had you disable Epic's built-in `GitSourceControl`
plugin in your engine install, because both plugins originally declared the same
internal module name (`GitSourceControl`), which collided at compile time.

That's fixed now: this repo's copy of the plugin has been renamed internally to
module `GitLFS2` (see the diff in the commit that added `Plugins\UEGitPlugin` if
you want the details - `.uplugin`, `.Build.cs`, `IMPLEMENT_MODULE`, and the
`GITLFS2_API` export macro, plus ~10 self-referential `FModuleManager` lookups
across `Source\GitSourceControl\`). Epic's built-in plugin and this fork can now
both be enabled at the same time with no collision. **You do not need to touch
your engine install at all.**

## Setup (per machine)

1. `git pull` this repo - the plugin arrives with the rest of the project.
2. Open `PermissionDenied_UVU.uproject`. First time only, it'll prompt to
   rebuild missing modules (compiles `GitLFS2`) - click Yes. Requires Visual
   Studio with the C++/Unreal workload, same as building the project itself.
3. Edit -> Editor Preferences -> Source Control:
   - Provider: **Git LFS 2**
   - Check **"Uses Git LFS 2 File Locking workflow"**
   - Set your username to match your Git username

That's it. No engine files, no scripts.

## One known unrelated issue

`VisualStudioTools` (Microsoft's IDE-integration plugin, unrelated to Git) is
disabled in this project's `.uproject` - it throws a `RulesError` on this UE 5.8
install even on a freshly-verified engine (confirmed via Epic Games Launcher's
Verify/repair, which didn't fix it). Not investigated further since it's
unrelated to source control; if you want VS navigation features back, that's a
separate issue to chase down.
