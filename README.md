# Laser/TripMine Entity
## Description
<ul>
   <li>Each player can set LaserMine on the wall.</li>
   <li><font color="red"><b>If get "SZ_GetSpace: overflow on Client Datagram" error of you use old version. Please try v3.05 or later.</b></font></li>
   <li><font color="red"><b>Non-Steam is not supported.</b></font></li>
</ul>

## Installation
### 1. File Locations:
#### Config FIles:
* cstrike\addons\amxmodx\configs\plugins\lasermine\
  * ltm_cvars.cfg
  * zp_ltm_cvars.cfg (Zombie Plague)
  * bh_ltm_cvars.cfg (BioHazard)
  * resources.json
#### Language FIles:
* cstrike\addons\amxmodx\data\lang
  * lasermine.txt

#### Script FIles:
* cstrike\addons\amxmodx\scripting\include\
  * beams.inc
  * lasermine_const.inc
  * lasermine_util.inc
  * lasermine_zombie.inc
  * lasermine.inc
* cstrike\addons\amxmodx\scripting\
  * lasermine.sma

#### Compiled
* cstrike\addons\amxmodx\plugins\
  * lasermine.amxx

### 2. Write Plugins.ini
* lasermine.amxx

### 3. If using Custom Resources.
* Modify resources.json. example.
```JSON
{
	"model": "models/[YOUR MINES MODELS PATH/MODEL NAME].mdl",
	"sprite": {
		"laser":[
         "sprites/[YOUR LASER SPRITE PATH/SPRITE NAME].spr",
         "sprites/[YOUR LASER SPRITE PATH/SPRITE NAME].spr"
      ],
		"explosion_a":[],
		"explosion_b":[],
		"explosion_water":[],
		"explosion_blast":[],
		"explosion_smoke":[],
		"explosion_bubble":[],
		"laser_hit_blood_splash":[],
		"laser_hit_blood_spray":[]
	},
	"sound":{
		"deploy":[
         "[YOUR DEPLOY SOUND PATH/SOUND NAME].wav"
      ],
		"charge":[
         "[YOUR DEPLOY SOUND PATH/SOUND NAME].wav"
      ],
		"activate":[
         "[YOUR DEPLOY SOUND PATH/SOUND NAME].wav"
      ],
		"pickup":[
         "[YOUR DEPLOY SOUND PATH/SOUND NAME].wav"
      ],
		"laser_hit":[
         "[YOUR DEPLOY SOUND PATH/SOUND NAME].wav",
         "[YOUR DEPLOY SOUND PATH/SOUND NAME].wav",
         "[YOUR DEPLOY SOUND PATH/SOUND NAME].wav",
         "[YOUR DEPLOY SOUND PATH/SOUND NAME].wav",
      ],
		"shield_hit":[],
		"break":[]
	}
}
```
* Attention: 
  1. Only one Model file.
  2. If multiple Sprite and Sound files are specified, they will be played at random.
  3. Sound files can only be specified under the sound/ directory.
## Modules:
* **[required]**: AMXMODX v1.9.0 or Higher.(The end of support for v1.8.2.)
  * If you want to compile with 1.8.2, you can use `cromchat.inc` (by OciXCrom) is required. And no recycle logic is available.
* **[required]**: Cstrike
* **[required]**: Fakemeta
* **[required]**: Hamsandwich

## Optional:
* If use BIOHAZARD or Zombie Plague Plugin.
* Please make re-compile for environment.
```C
//#define BIOHAZARD_SUPPORT
//#define ZP_SUPPORT
```

## Usage:
### Admin Console command.
|Command  |Parameter|Description|
|---------|---------|-----------|
|lm_remove|`userid` |Remove all mine. target user.|
|lm_give  |`userid` |Give mine. target user. (start amount.)|

### Client command.
|Command  |Description|Example|
|---------|-----------|-------|
|+setlaser|Lasermine deploy on wall.|bind v +setlaser|
|+setlm   |Lasermine deploy on wall.|bind v +setlm|
|+dellaser|Return lasermine to the ammo. <br>`Less than v3.14 (From v3.15, the USE key.)`|bind j +dellaser|
|+remlm   |Return lasermine to the ammo. <br> `Less than v3.14 (From v3.15, the USE key.)`|bind j +remlm|
|buy_lasermine|Buying lasermine.|bind "F2" "buy_lasermine"|
|say "/buy lasermine"|Buying lasermine|
|say "/lm"|Buying lasermine|
|say "/lasermine"|Show help motd.|

### Cvar settings.
#### Common.
|Cvar|Value|Default|Description|
|----|-----|-------|-----------|
|amx_ltm_enable|`0` or `1`|`1`|**[COMMON]** Enable plugin. [0 = Disable, 1 = Enable]|
|amx_ltm_access|`0` or `1`|`0`|**[COMMON]** Player can use plugin this access level. [0 = ALL, 1 = ADMIN_ACCESS_LEVEL_H]|
|amx_ltm_mode|`0` or `1`|`0`|**[COMMON]** Mines Mode. [0 = Lasermine, 1 = Tripmine]
|amx_ltm_round_delay|`Seconds`|`5.0`|**[COMMON]** Delay at start of round.|
#### Ammo.
|Cvar|Value|Default|Description|
|----|-----|-------|-----------|
|amx_ltm_amount|`int`|`1`|**[AMMO]** Number of mines in your possession at the start of the round.|
|amx_ltm_max_amount|`int`|`2`|**[AMMO]** The largest number of mines you can carry.|
|amx_ltm_team_max|`int`|`10`|**[AMMO]** Maximum number of mines that can be deployed in a team.|

#### Buy System.
|Cvar|Value|Default|Description|
|----|-----|-------|-----------|
|amx_ltm_buy_mode|`0` or `1`|`1`|**[BUY SYSTEM]** Make them buy to use. [0 = Disable, 1 = Enable]|
|amx_ltm_buy_team|`TR`,`CT`,`ALL`|`ALL`|**[BUY SYSTEM]** Teams that are allowed to buy. [TR / CT / ALL. (BIOHAZARD: Z = Zombie, H = human)]|
|amx_ltm_buy_price|`int`|`2500`|**[BUY SYSTEM]**- The price of mines|
|amx_ltm_buy_zone|`0` or `1`|`1`|**[BUY SYSTEM]**- Purchases are made through Buy zone only. [0 = Disable, 1 = Enable]|
|amx_ltm_frag_money|`int`|`300`|**[BUY SYSTEM]**- Kill reward money.|
#### Laser Design.
|Cvar|Value|Default|Description|
|----|-----|-------|-----------|
|amx_ltm_laser_visible|`0` or `1`|`1`|**[LASER]** Laser line visibility. [0 = No, 1 = YES]|
|amx_ltm_laser_color_mode|`0` or `1`|`0`|**[LASER]** Laser line Color mode. [0 = Teams, 1 = Green]|
|amx_ltm_laser_color_t|`R,G,B`|`255,0,0`|**[LASER]** Team-Color for Terrorist. [R,G,B]|
|amx_ltm_laser_color_ct|`R,G,B`|`0,0,255`|**[LASER]** Team-Color for Counter-Terrorist. [R,G,B]|
|amx_ltm_laser_brightness|`0 - 255`|`255`|**[LASER]** Laser line Brightness. [0 - 255]|
|amx_ltm_laser_width|`0 - 255`|`2`|**[LASER]** Laser line width. [0 - 255]|
|amx_ltm_laser_damage_mode|`0 - 2`|`0`|**[LASER]** Damage mode. [0 = Frame, 1 = Once, 2 = Second repeat]|
|amx_ltm_laser_damage|`Damage`|`60.0`|**[LASER]** Damage.|
|amx_ltm_laser_dps|`Seconds`|`1.0`|**[LASER]** Damage mode = 2, Damage/Seconds [Seconds]|
|amx_ltm_laser_range|`Float`|`8192.0`|**[LASER]** Laser line range.|
|amx_ltm_laser_fence|`0` or `1`|`1`|**[LASER]** Laser hit the body bounces back.|
#### Mines Design.
|Cvar|Value|Default|Description|
|----|-----|-------|-----------|
|amx_ltm_mine_health|`Health`|`500.0`|**[MINE]** Health.|
|amx_ltm_mine_glow|`0` or `1`|`1`|**[MINE]** Glowing. [0 = Disable, 1 = Enable]|
amx_ltm_mine_glow_color_mode|`0` - `2`|`0`|**[MINE]** Glow color mode. [0 = Team, 1 = Green, 2 = Health Indicator(Green to Red)]|
|amx_ltm_mine_glow_color_t|`R,G,B`|`255,0,0`|**[MINE]** Glow color mode = 0, for Terrorist.[R,G,B]|
|amx_ltm_mine_glow_color_ct|`R,G,B`|`0,0,255`|**[MINE]** Glow color mode = 0, for Counter-Terrorist.[R,G,B]|
|amx_ltm_mine_broken|`0` - `2`|`0`|**[MINE]** Can broken.[0 = Owner, 1 = Team, 2 = and Enemy]|
|amx_ltm_explode_radius|`Float`|`320.0`|**[MINE]** Explosion radius.|
|amx_ltm_explode_damage|`Damage`|`100.0`|**[MINE]** Explosion radius damage.|
#### Misc.
|Cvar|Value|Default|Description|
|----|-----|-------|-----------|
|amx_ltm_death_remove|`0` or `1`|`1`|**[MISC]** Dead player remove mines. [0 = Disable, 1 = Enable]|
|amx_ltm_activate_time|`Seconds`|`1.0`|**[MISC]** Waiting for put mines. [Seconds, 0 = no progress bar]|
|amx_ltm_allow_pickup|`0` - `3`|`1`|**[MISC]** Allow pickup mines. [0 = Disable, 1 = Owner, 2 = Allow Friendly, 3 = and Allow Enemy]|
|amx_ltm_shield_difence|`0` or `1`|`1`|**[MISC]** Allow Shield difence. [0 = Disable, 1 = Enable]|
|amx_ltm_realistic_detail|`0` or `1`|`0`|**[MISC]** Show hit sparks on wall. [0 = Disable, 1 = Enable]|

* For Biohazard, replace amx_ltm with bio_ltm.
* For ZombiePlague, replace amx_ltm with zp_ltm.

## Creadits
|Name       |Thanks                        |
|-----------|------------------------------|
|ArkShine|Laser/Tripmine for weaponmod|
|Vexd,Buzz_KIll|Vexd_TripMine|
|Cheap_Suit|Radius_Damage|
|GameGuard|/lm, amx_ltm_ff,cbt,delay ideas.|
|s3r|unlagging tests.|
|DevconeS|Weaponmod|
|rian18|Feedback|
|elmariolo|Feedback|
|ZaX|Feedback, Recycling Logic.|
and more...

#
### Translation Request.
https://forums.alliedmods.net/showthread.php?t=323127


### Known issues.
- [x] Can't break of other breakable object.
- [x] Recycling a Damaged Lasermine.
- [x] Stuck of very near deployed.
- [x] Can't stop when you deploy C4.
- [ ] Bug where Mines disappears when someone disconnects. (Waiting for reappearance.)
- [x] Using an array for my enum, so when I try to compile with 1.9.0 I get an error.
"array sizes do not match, or destination array is too small"
https://forums.alliedmods.net/showthread.php?t=313946

