## Unreleased
## [3.32.0]
### Fixed
- An error occurred in cs_get_user_team.
Due to the use of EntityID instead of player ID in FiendlyFire check during explosion process.

## [3.31.0]
### Added
- amx_ltm_laser_reflect.
### Fixed
- Language for biohazard (NO_ROUND key).
### Changed
- Custom resources available. (JSON files)

## [3.30.0]
### Added
- Custom resources available. (ini files)
### Fixed
- Remove lasermine distance.

## [3.29.0]
### Fixed
- amx_ltm_realistic_detail bug.

## [3.28.0]
### Fixed
- ZP Errors.

## [3.27.0]
### Fixed
- The return value of Native functions.

## [3.26.0]
### Fixed
- Compile error for ZP/BIOHAZARD support.

## [3.25.0]
### Added
- Native and Forward functions.

## [3.23.0]
### Fixed
- Server crash.

## [3.22.0] [YANKED]
### Fixed
- Undefined pev index.(Typo)

## [3.21.0]
### Removed
- The end of support for AMXX v1.8.2.

### Added
- CSX WeaponId.

### Fixed
- Undefined pev index.

## [3.17.0]
### Fixed
- Compile error for 1.8.2.

## [3.16.0]
### Fixed
- Compile error for ZP.

## [3.15.0]
### Removed
- Claymore Logic. (Use the [Mines Platform](https://forums.alliedmods.net/showthread.php?t=324358).)
- +dellaser command. (Use the +use key.)

### Changed
- Zombie mod logic.

## [3.14.0]
### Added
- Effects in water.
- Effects explosion cylinder.
- Explosion decals.
- Laser hit splash.

### Fixed
- Source code refactoring.

## [3.13.0]
### Added
- Indicator glow.

### Fixed
- Deploying position.

## [3.12.0]
### Fixed
- When infected in zombie mode, the team's color does not match the owner.

## [3.11.0a]
### Changed
- Can be compiled with 1.8.2, but required cromchat.inc by OciXCrom and can not use Recycle logic.

## [3.10.0]
### Added
- Deploy Hologram.
- AutoExecConfig Logic.

## [3.09.0]
### Fixed
- Test. Bug where Mines disappears when someone disconnects.

## [3.08.0]
### Added
- Zombie Plague 5.0.8 Trial support.

## [3.07.0]
### Added
- Add Chain Explosion.

### Changed
- Delete amx_ltm_friendly_fire. => use mp_friendlyfire.

### Fixed
- RapidDamage Mode.
- BeamThink Logic.

## [3.06.0]
### Added
- Add Recycle Logic.

### Changed
- Deploy check, ignore player.

## [3.05.0]
### Added
- Laser penetration.

### Fixed
- Can't break of other breakable object.
- Test fix stuck bug.

## [3.04.0]
### Added
- Claymore mode and any cvars.
- amx_ltm_realistic_detail.
- amx_ltm_mine_broken.
- admin command `lm_remove, lm_give`.
- show mine health on hud.

### Changed
- Refactoring.

## [3.03.0]
### Added
- support for multi language. (now english only.)
- amx_ltm_shield_difence.

### Changed
- damage logic replaced. (hamsandwich base.)

## [3.02.0]
### Changed
- Replace Cvars.
    |Before|After|
    |------|-----|
    |amx_ltm|amx_ltm_enable|
    |amx_ltm_acs|amx_ltm_access|
    |amx_ltm_ff|amx_ltm_friendly_fire|
    |amx_ltm_delay|amx_ltm_round_delay|
    |amx_ltm_cmdmode|amx_ltm_cmd_mode|
    |amx_ltm_startammo|amx_ltm_amount|
    |amx_ltm_ammo|amx_ltm_max_amount|
    |amx_ltm_teammax|amx_ltm_team_max|
    |amx_ltm_buymode|amx_ltm_buy_mode|
    |amx_ltm_cbt|amx_ltm_buy_team|
    |amx_ltm_cost|amx_ltm_buy_price|
    |amx_ltm_fragmoney|amx_ltm_frag_money|
    |amx_ltm_line|amx_ltm_laser_visible|
    |amx_ltm_color|amx_ltm_laser_color_mode|
    |amx_ltm_bright|amx_ltm_laser_brightness|
    |amx_ltm_dmg|amx_ltm_laser_damage|
    |amx_ltm_ldmgmode|amx_ltm_laser_damage_mode|
    |amx_ltm_ldmgseconds|amx_ltm_laser_dps|
    |amx_ltm_health|amx_ltm_mine_health|
    |amx_ltm_glow|amx_ltm_mine_glow|
    |amx_ltm_radius|amx_ltm_explode_radius|
    |amx_ltm_rdmg|amx_ltm_explode_damage|

### Added
- amx_ltm_buy_zone.
- amx_ltm_laser_color_t.
- amx_ltm_laser_color_ct.
- amx_ltm_laser_range.
- amx_ltm_mine_glow_color_mode.
- amx_ltm_mine_glow_color_t.
- amx_ltm_mine_glow_color_ct.
- amx_ltm_death_remove.
- amx_ltm_activate_time.
- amx_ltm_allow_pickup.

## [3.01.0]
### Fixed
- amx_ltm_ldmgseconds. 

## [3.00.0]
### Added
- Add ltm_death_remove, ltm_put_wait.

### Changed
- Refactoring source code.
- Required hamsandwich.

### Fixed
- Score bug.
- Buy mode = 0, not check have ammo.

## [2.03.0] [YANKED]
### Added
- amx_ltm_buymode //say cmd buying. 0 is off, 1 is on.

### Fixed
- amx_ltm_startammo.
- Explode message codes.

## [2.02.0] [YANKED]
### Added
- +dellaser

## [2.01.0] [YANKED]
### Added
- amx_ltm_cmdmode.
- Supported unlimited money.

### Changed
- Integrated Biohazard version with 2.1

### Fixed
- mine size.

## [2.00.0] [YANKED]
### Fixed
- Score bug.
- amx_ltm_dmg.

## [2.00.0-RC] [YANKED]
### Changed
- Title changed. "Laser/TripMine Entity"
- Converted ENGINE to FakeMeta.
- All cvars changed. amx_lasermine -> amx_ltm.
- Can apply Cvar immediately.
- Limiter cancellation of Cvar.

## [1.09.0] [YANKED]
### Added
- amx_lasermine_line. 0 is invisible laserline. 1 is visible laserline.
### Changed
- rollback old cvars style.

## [1.08.0] [YANKED]
### Added
- amx_lasermine_think (default 0.01: unlagging value > 0.1)
- All cmdline description.

## [1.07.0] [YANKED]
### Added
- amx_lasermine_ff //set friendly fire. 1 or 0
- amx_lasermine_cbt //set can buy and deploy team. "T" or "CT" or "ALL"
- amx_lasermine_delay //set can buy roundstart +sec. default "15" = 15secs. And now test unlag.

## [1.06.0] [YANKED]
### Added
- All cvarcmds accesslevel is ADMIN_LEVEL_H.
- amx_lasermine_mode //0 is lasermine,1 is tripmine mode.
- amx_lasermine_radius //set detonate radius.
- amx_lasermine_rdmg //set detonate max damage.
- buy_lasermine //bind key buy_lasermine.
### Fixed
- teammax bug.
- The frag is set with Kill by the blast. 

## [1.05.0] [YANKED]
### Added 
- say /buy lasermine //cut underbar
- amx_lasermine_teammax cmd //maximum set in team
 
## [1.05.0-b2] [YANKED]
### Added
- say /buy_lasermine //buying lasermine
- say lasermine //show motd
### Changed
- showammo text "LaserMines: %i" -> "LaserMines Ammo: %i/%i"

---------------------------------------------------------------
## BIOHAZARD VERSION [YANKED]
## [1.02]
### Changed
- Integrated with Mainline 2.1.

## [1.01]
### Fixed
- +grab bug.
### Changed
- Default value change. rdmg and radius.
### Added
- Radius damage kickback, and revision.

## [1.00]
### Added
- bio_ltm_ldmgmode // 0 - damage / frame, 1 - once damage, 2 - damage / seconds.
- bio_ltm_ldmgseconds //ldmgmode 2 only , default 1 (sec)
- bio_ltm_color //0 is team color, 1 is green
- bio_ltm_bright //laser line brightness. default 255.

## [0.09]
### Added
- bio_ltm_acs //1= admin only
- bio_ltm_glow //1 = glowing mine.
### Fixed
- Laser hit system.
- Breakable mine.

## [0.08]
### Fixed
- PrecacheSound Error.

## [0.07]
### Fixed
- Laser Hit system.
- Can't deploy mine.

## [0.06]
### Fixed
- fixed. ltm_dmg bug.
- Code synchronized Mainline 2.0

## [0.05]
### Fixed
- +use used hung up.

## [0.04]
### Fixed
- hung up (Zlib error) fixed.

## [0.02]
### Changed
- change deploy cmd. "+setlaser" -> "+USE" key.
### Added
- bio_ltm_startammo default 1. start set ammo. 0 is off.

## [0.01]
### Changed
- Mainline 2.0RC recoding for Bio, release.
- All cvars changed. bio_ltm_xxx.
