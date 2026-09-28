# Git LFS File Locking Setup

This project uses the **Git LFS 2** plugin (`Plugins\UEGitPlugin` in this repo, a
fork of Epic's built-in Git plugin maintained by Project Borealis) instead of
Unreal's built-in Git plugin. Reason: Epic's built-in plugin cannot lock binary
files (`.uasset`, `.umap`), so two people editing the same Blueprint or map at
once will silently destroy one person's work on merge. The Git LFS 2 plugin adds
lock/unlock support with padlock icons in the Content Browser.

## Why a script is needed

Epic's built-in plugin and this fork both register a module named
`GitSourceControl`. Having both present causes a module name collision when the
project compiles. Epic's copy lives inside the engine install itself
(`Engine\Plugins\Developer\GitSourceControl\`), not inside this project, so it
has to be disabled once per machine, per installed engine version.

**This affects every project that opens with that engine install on your
machine, not just this one.** If you have other Git-based UE projects on the
same engine version relying on Epic's basic Git status viewer, they'll lose
that until you restore it.

## Setup (run once per machine)

```powershell
.\Disable-EngineGitPlugin.ps1
```

Auto-detects your engine version from the project's `.uproject` file and
disables the matching engine install's plugin. If auto-detection fails, pass
the path explicitly:

```powershell
.\Disable-EngineGitPlugin.ps1 -EnginePath "C:\Program Files\Epic Games\UE_5.8"
```

## Rolling back

If this causes problems (conflicts with another project, team decides against
the locking workflow, etc.), undo it with:

```powershell
.\Restore-EngineGitPlugin.ps1
```

This restores Epic's built-in plugin. Note that if you do this while
`Plugins\UEGitPlugin` is still present in this repo, the project will fail to
compile again (same collision, reversed) - either remove/disable
`Plugins\UEGitPlugin` too, or re-run `Disable-EngineGitPlugin.ps1` afterward.

To fully back out of the Git LFS 2 plugin at the repo level (not just this
machine), find the commit that added `Plugins\UEGitPlugin` and the related
`.uproject`/`.gitattributes` changes, and `git revert` it.
