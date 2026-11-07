# NoGrenadeRinging

> [!WARNING]
> **This repository is archived and no longer maintained.**
> Use [GrenadeTweaks](https://github.com/srcdslab/sm-plugin-GrenadeTweaks) instead. Since 2.1.0 it does the same thing on CS:S (and CS:GO), with up-to-date gamedata.

Blocks the ear ringing a player gets when a grenade explodes next to them, by superseding `CCSPlayer::OnDamagedByExplosion` with DHooks.

## Migrating to GrenadeTweaks

1. Remove `plugins/NoGrenadeRinging.smx` and `gamedata/NoGrenadeRinging.games.txt`.
2. Install `GrenadeTweaks.smx` and `gamedata/GrenadeTweaks.games.txt` from the [GrenadeTweaks releases](https://github.com/srcdslab/sm-plugin-GrenadeTweaks/releases).

Neither plugin has cvars or configs, so there is nothing else to change. Running both at once is harmless but redundant.
