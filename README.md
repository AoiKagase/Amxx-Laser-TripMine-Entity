[SIZE=6][COLOR=GREEN][B]Laser/TripMine Entity v3.10[/B][/COLOR][/SIZE]

[LIST]
[*][SIZE=4][B]Descliption:[/B][/SIZE]


[LIST]
[*]Each player can set LaserMine on the wall.
[*][COLOR="Red"][B]If get "SZ_GetSpace: overflow on Client Datagram" error of you use old version. Please try v3.05 or later.[/B][/COLOR]
[/LIST]


[*][SIZE=4][B]Installation:[/B][/SIZE]


[LIST]
[*][B]File Locations:[/B]
[LIST]
[*].\[I]cstrike[/I]\addons\amxmodx\scripting\include\lasermine_const.inc
[*].\[I]cstrike[/I]\addons\amxmodx\scripting\include\lasermine_util.inc
[*].\[I]cstrike[/I]\addons\amxmodx\scripting\lasermine.sma
[*].\[I]cstrike[/I]\addons\amxmodx\plugins\lasermine.amxx
[COLOR="Blue"][*].\[I]cstrike[/I]\addons\amxmodx\config\plugins\plugin-lasermine.cfg
[/COLOR][*].\[I]cstrike[/I]\addons\amxmodx\data\lang\lasermine.txt
[/LIST]


[*][B]Modules:[/B][COLOR=red][LIST]
[*][required]: [b]AMXMODX v1.10.0 (In v1.9.0 I get a compile error.)[/b]
[*][required]: [b]Cstrike[/b]
[*][required]: [b]Fakemeta[/b]
[*][required]: [b]Hamsandwich[/b]
[/LIST][/COLOR]

[*][B]Optional:[/B]
[LIST]
[*]If use BIOHAZARD or Zombie Plague Plugin.
Please make re-compile for environment.
line 2,3
[code]
//#define BIOHAZARD_SUPPORT
//#define ZP_SUPPORT
[/code]
[*][COLOR="Red"][B]Non-Steam is not supported.[/B][/COLOR]
[/LIST]
[/LIST]


[*][SIZE=4][B]Usage:[/B][/SIZE][CODE]
[b][color=blue]Admin Console command[/color][/b]
[list]
[*][b]lm_remove <userid>[/b]
[list][*]- remove all mine. target user.[/list]
[*][b]lm_give <userid>[/b]
[list][*]- give mine. target user. (start amount.)[/list]
[/list]
[b][color=blue]Client command[/color][/b]
[list]
[*][b]+setlaser[/b] or [b]+setlm[/b]
[list][*]- ex) bind v +setlaser[*]- can set lasermine on the wall[/list]

[*][b]+dellaser[/b] or [b]+remlm[/b]
[list][*]- ex) bind j +dellaser[*]- can return lasermine in ammo.[/list]

[*][b]buy_lasermine[/b]
[list][*]- ex) bind "F2" "buy_lasermine"[*]- buying lasermine[/list]

[*][b]say "/buy lasermine" or "/lm"[/b]
[list][*]- buying lasermine[/list]

[*][b]say "/lasermine"[/b]
[list][*]- show help[/list]
[/CODE]
[/list]


[*][SIZE=4][B]Cvars: (Ver 3.x)[/B][/SIZE]
[php]
// ================================================================
// Common Settings.
// ================================================================
// lasermine ON/OFF (1 / 0)
amx_ltm_enable 				"1"

// lasermine access level (0 = all, 1 = admin only)
amx_ltm_access 				"0"

// lasermine mode (0 = killing laser, 1 = tripmine)
amx_ltm_mode 				"0"

// lasermine friendly fire. (0 = off, 1 = on)
amx_ltm_friendly_fire 		"0"

// Round start delay time. (5 seconds)
amx_ltm_round_delay 		"5"

// Client command mode. (0 = +USE key, 1 = +setlaser, 2 = each)
amx_ltm_cmd_mode 			"1"


// ================================================================
// Ammo Settings.
// ================================================================
// round start have ammo.
amx_ltm_amount 				"1"

// max have ammo and max deploy count.
// but if buymode=0 can not use this setting.
amx_ltm_max_amount 			"2"

// max deployed count in team.
// Warning: The HL engine supports up to 128 laser.
//          So the maximum number per team is limited to 64.
//			Claymore mode displays three lasers per piece, so you are limited to 20 per team.
amx_ltm_team_max 			"10"

// ================================================================
// Buy system Settings.
// ================================================================
// can say cmd buying. 0 is off, 1 is on . (/buy lasermine or /lm)
amx_ltm_buy_mode 			"1"

// lasermine can buying and deploying team.("ALL", "T" or "TR", "CT")
amx_ltm_buy_team 			"ALL"

// buying lasermine cost.
amx_ltm_buy_price 			"2500"

// stay buyzone can buying.
amx_ltm_buy_zone			"1"

// kill enemy +money
amx_ltm_frag_money 			"300"


// ================================================================
// Laser beam design Settings.
// ================================================================
// Laser line visiblilty (0 is invisible, 1 is visible)
amx_ltm_laser_visible 		"1"

// Laser line color mode. (0 is team color (T=RED, CT=BLUE), 1 is GREEN)
amx_ltm_laser_color_mode 	"0"

// Team-Color for Terrorist. default:red (R,G,B)
amx_ltm_laser_color_t		"255,0,0"
// Team-Color for Counter-Terrorist. default:blue (R,G,B)
amx_ltm_laser_color_ct		"0,0,255"

// Laser line brightness. (0 to 255)
amx_ltm_laser_brightness 	"255"

// Laser line width. (0 to 255)
amx_ltm_laser_width 	"5"

// Laser hit damage. (Float value!)
amx_ltm_laser_damage		"1000.0"

// Laser hit damage mode. (0 is frame dmg, 1 is seconds dmg)
amx_ltm_laser_damage_mode 	"0"

// Laser hit Cool Time. (laser_damage_mode=1 only, dmg/sec default 1 sec)
amx_ltm_laser_dps			"1"

// Laser beam lange (float range.)
amx_ltm_laser_range			"8192.0"

// ================================================================
// Laser mine design Settings.
// ================================================================
// Lasermines health. over 1000 is very hard mine :)
amx_ltm_mine_health				"500"

// glowing lasermine. (0 is off, 1 is on)
amx_ltm_mine_glow				"1"

// Mine glow coloer 0 = team color, 1 = green.
amx_ltm_mine_glow_color_mode	"0"
amx_ltm_mine_glow_color_t		"255,0,0"
amx_ltm_mine_glow_color_ct		"0,0,255"

// Can Broken Mines. 0 = Mine, 1 = Team, 2 = Enemy.
amx_ltm_mine_broken				"0"		


// Lasermine explosion radius. (Float value!)
amx_ltm_explode_radius 			"320.0"

// Lasermine explosion damage. (on center)
amx_ltm_explode_damage			"100"

// ================================================================
// Misc Settings.
// ================================================================
// Dead Player remove lasermine. 0 = off, 1 = on.
amx_ltm_death_remove			"0"

// Waiting for put lasermine. (int:seconds. 0 = no progress bar.)
amx_ltm_activate_time			"1"

// allow pickup mine. (0 = disable, 1 = it's mine, 2 = allow friendly mine, 3 = allow enemy mine!)
amx_ltm_allow_pickup			"1"

// allow shield difence.
amx_ltm_shield_difence          "1"

// Spark Effect.
amx_ltm_realistic_detail        "0"

// ================================================================
// Claymore Settings.
// ================================================================
// wire range.
amx_ltm_cm_wire_range			"300"

// wire width.
amx_ltm_cm_wire_width			"2"

// wire area zone.
// 		pitch:down 0, back 90, up 180, forward 270(-90)
// 		yaw  :left 90, right -90 
//
// wire area center pitch.
amx_ltm_cm_wire_center_pitch	"220,290"

// wire area center yaw.
amx_ltm_cm_wire_center_yaw		"-25,25"

// wire area left pitch.
amx_ltm_cm_wire_left_pitch		"260,290"

// wire area left yaw.
amx_ltm_cm_wire_left_yaw		"30,60"

// wire area right pitch.
amx_ltm_cm_wire_right_pitch		"260,290"

// wire area right yaw.
amx_ltm_cm_wire_right_yaw		"-30,-60"

// wire trial frequency.
amx_ltm_cm_wire_trial_freq		"3"

// Mine glow coloer 0 = team color, 1 = green.
amx_ltm_cm_wire_color_mode		"0"

// Team-Color for Terrorist. default:red (R,G,B)
amx_ltm_cm_wire_color_t			"20,0,0"

// Team-Color for Counter-Terrorist. default:blue (R,G,B)
amx_ltm_cm_wire_color_ct		"0,0,20"



// Lasermine Configuration File
echo Executing Lasermine Configuration File


// Bio version : amx_ltm -> bio_ltm
[/php]



[*][SIZE=4][B]Credits:[/B][/SIZE]
[CODE]
[LIST]
[*][URL="https://forums.alliedmods.net/member.php?u=7779"]ArkShine[/URL]		: Laser/Tripmine for weaponmod
[*]Vexd,Buzz_KIll	: Vexd_TripMine
[*][URL="https://forums.alliedmods.net/member.php?u=941"]Cheap_Suit[/URL]	: [url=http://forums.alliedmods.net/showthread.php?t=55700]Radius_Damage[/url]
[*][URL="https://forums.alliedmods.net/member.php?u=30753"]GameGuard[/URL]	: /lm, amx_ltm_ff,cbt,delay ideas.
[*][URL="https://forums.alliedmods.net/member.php?u=30474"]s3r[/URL]			: unlagging tests.
[*][URL="https://forums.alliedmods.net/member.php?u=11101"]DevconeS[/URL]		: [URL="https://forums.alliedmods.net/showthread.php?t=42644"]Weaponmod[/URL] [URL="https://forums.alliedmods.net/showthread.php?t=306369&highlight=DevconeS"](Mirror)[/URL]
[*][URL="https://forums.alliedmods.net/member.php?u=299340"]rian18[/URL] 		: Feedback
[*][URL="https://forums.alliedmods.net/member.php?u=299345"]elmariolo[/URL]		: Feedback
[*][URL="https://forums.alliedmods.net/member.php?u=258015"]ZaX[/URL]			: Feedback, Recycling Logic.
[*]and more...
[/LIST]
[/CODE]



[*][SIZE=3][b]Translation Request.[/b][/SIZE]
[B][url]https://forums.alliedmods.net/showthread.php?t=323127[/url][/B]



[*][SIZE=3][b]Known issues.[/b][/SIZE]
[list]
[*][s]Can't break of other breakable object.[/s]
[*][s]Recycling a Damaged Lasermine.[/s]
[*][s]Stuck of very near deployed.[/s]
[*][s]Can't stop when you deploy C4.[/s]
[*]Bug where Mines disappears when someone disconnects. (Waiting for reappearance.)
[*]Using an array for my enum, so when I try to compile with 1.9.0 I get an error.
   [COLOR="Red"]"array sizes do not match, or destination array is too small"[/COLOR]
    [url]https://forums.alliedmods.net/showthread.php?t=313946[/url]
[/LIST]
[/LIST]


[CENTER][IMG]https://f.easyuploader.app/eu-prd/upload/20200320165239_494b3167306261614b32.jpg[/IMG][IMG]https://f.easyuploader.app/eu-prd/upload/20200411134644_616f63483773416f7264.jpg[/IMG][/CENTER]



[spoiler=Changelog]
[b]VERSION3.11 Alpha Test[/b]
[list]
[*]Can be compiled with 1.8.2, but required cromchat.inc by OciXCrom and can not use Recycle logic.
[/list]
[b]VERSION3.10[/b]
[list]
[*]Deploy Hologram.
[*]AutoExecConfig Logic.
[/list]
[b]VERSION3.09[/b]
[list]
[*]Test. Bug where Mines disappears when someone disconnects.
[/list]
[b]VERSION3.08[/b]
[list]
[*][s]Fixed. Bug where Mines disappears when someone disconnects.[/s]
[*]Zombie Plague 5.0.8 Trial support.
[/list]
[b]VERSION3.07[/b]
[list]
[*]Fixed RapidDamage Mode.
[*]Fixed BeamThink Logic.
[*]Delete amx_ltm_friendly_fire. => use mp_friendlyfire
[*]Add Chain Explosion.
[/list]
[b]VERSION3.06[/b]
[list]
[*]Add Recycle Logic.
[*]Deploy check, ignore player.
[/list]
[b]VERSION3.05[/b]
[list]
[*]Fixed of can't break of other breakable object.
[*]Laser penetration.
[*]Test fix stuck bug.
[/list]
[b]VERSION3.04[/b]
[list]
[*]add claymore mode and any cvars.
[*]add amx_ltm_realistic_detail.
[*]add amx_ltm_mine_broken.
[*]add admin command[lm_remove, lm_give].
[*]show mine health on hud.
[*]refactoring.
[/list]
[b]VERSION3.03[/b]
[list]
[*]support for multi language. (now english only.)
[*]add amx_ltm_shield_difence.
[*]damage logic replaced. (hamsandwich base.)
[/list]
[b]VERSION3.02[/b]
[list]
Replace Cvars.
[list]
[*]amx_ltm 			=> amx_ltm_enable.
[*]amx_ltm_acs 		=> amx_ltm_access.
[*]amx_ltm_ff		=> amx_ltm_friendly_fire.
[*]amx_ltm_delay		=> amx_ltm_round_delay.
[*]amx_ltm_cmdmode	=> amx_ltm_cmd_mode.
[*]amx_ltm_startammo	=> amx_ltm_amount.
[*]amx_ltm_ammo		=> amx_ltm_max_amount
[*]amx_ltm_teammax	=> amx_ltm_team_max.
[*]amx_ltm_buymode	=> amx_ltm_buy_mode.
[*]amx_ltm_cbt		=> amx_ltm_buy_team.
[*]amx_ltm_cost		=> amx_ltm_buy_price.
[*]amx_ltm_fragmoney	=> amx_ltm_frag_money.
[*]amx_ltm_line		=> amx_ltm_laser_visible.
[*]amx_ltm_color		=> amx_ltm_laser_color_mode.
[*]amx_ltm_bright		=> amx_ltm_laser_brightness.
[*]amx_ltm_dmg		=> amx_ltm_laser_damage.
[*]amx_ltm_ldmgmode	=> amx_ltm_laser_damage_mode.
[*]amx_ltm_ldmgseconds=> amx_ltm_laser_dps.
[*]amx_ltm_health		=> amx_ltm_mine_health.
[*]amx_ltm_glow		=> amx_ltm_mine_glow.
[*]amx_ltm_radius		=> amx_ltm_explode_radius.
[*]amx_ltm_rdmg		=> amx_ltm_explode_damage.
[/list]
[*]Add Cvars.
[list]
[*]amx_ltm_buy_zone.
[*]amx_ltm_laser_color_t.
[*]amx_ltm_laser_color_ct.
[*]amx_ltm_laser_range.
[*]amx_ltm_mine_glow_color_mode.
[*]amx_ltm_mine_glow_color_t.
[*]amx_ltm_mine_glow_color_ct.
[*]amx_ltm_death_remove.
[*]amx_ltm_activate_time.
[*]amx_ltm_allow_pickup.
[/list]
[/list]

[b]VERSION3.01[/b]
[list]
[*]fixed amx_ltm_ldmgseconds. 
[/list]

[b]VERSION3.00[/b]
[list]
[*]Refactoring source code.
[*]fixed. socore bug.
[*]buy mode 0, not check have ammo.
[*]add ltm_death_remove, ltm_put_wait.
[*]required hamsandwich.
[/list]

[b]VERSION2.3[/b]
[list]
[*]add ltm_buymode //say cmd buying. 0 is off, 1 is on.
[*]fixed. ltm_startammo.
[*]fixed. explode message codes.
[/list]

[b]VERSION2.2[/b]
[list]
[*]add +dellaser
[/list]

[b]VERSION2.1[/B]
[list]
[*]I integrated Bio with 2.1
[*]add ltm_cmdmode.
[*]supported unlimited money.
[*]fixed. mine size.
[/list]

[B]VERSION2.0[/B]
[list]
[*]fixed. score bug.
[*]fixed. ltm_dmg.
[/list]

[B]VERSION2.0 Release Candidate[/B]
[list]
[*]title changed. "Laser/TripMine Entity"
[*]converted engine to fakemeta.
[*]all cvars changed. amx_lasermine -> amx_ltm.
[*]can apply Cvar immediately.
[*]Limiter cancellation of Cvar.
[/list]

[B]VERSION1.9 Alpha[/B]
[list]
[*]add amx_lasermine_line. 0 is invisible laserline. 1 is visible laserline.
[*]rollback old cvars style.
[/list]

[B]VERSION1.8[/B]
[list]
[*]add amx_lasermine_think (default 0.01: unlagging value > 0.1)
[*]add all cmdline description.
[/list]

[B]VERSION1.7[/B]
[list]
[*]add amx_lasermine_ff //set friendly fire. 1 or 0
[*]add amx_lasermine_cbt //set can buy and deploy team. "T" or "CT" or "ALL"
[*]add amx_lasermine_delay //set can buy roundstart +sec. default "15" = 15secs.
[*]and now test unlag.
[/list]
 
[B]VERSION1.6[/B]
[list]
[*]All cvarcmds accesslevel is ADMIN_LEVEL_H.
[*]add amx_lasermine_mode //0 is lasermine,1 is tripmine mode.
[*]add amx_lasermine_radius //set detonate radius.
[*]add amx_lasermine_rdmg //set detonate max damage.
[*]add buy_lasermine //bind key buy_lasermine.
[*]fix teammax bug.
[*]The frag is set with Kill by the blast. 
[*]sorry for poor English...
[/list]
 
[B]VERSION1.5[/B]
[list]
[*]say /buy lasermine //cut underbar
[*]add amx_lasermine_teammax cmd //maximum set in team
[/list]
 
[B]VERSION1.2Beta2[/B]
[list]
[*]say /buy_lasermine //buying lasermine
[*]say lasermine //show motd
[*]showammo text "LaserMines: %i" -> "LaserMines Ammo: %i/%i"
[/list]
---------------------------------------------------------------
[color=orange]
[b]BIOHAZARD VERSION 1.2[/B]
I integrated Bio with 2.1
add ltm_cmdmode.
supported unlimited money.
fixed. mine size.

[b]BIOHAZARD VERSION 1.1[/B]
fixed. +grab bug.
default value change. rdmg and radius.
add radius damage kickback, and revision.

[B]BIOHAZARD VERSION 1.0[/B]
add bio_ltm_ldmgmode // 0 - damage / frame, 1 - once damage, 2 - damage / seconds.
add bio_ltm_ldmgseconds //ldmgmode 2 only , default 1 (sec)
add bio_ltm_color //0 is team color, 1 is green
add bio_ltm_bright //laser line brightness. default 255.

[B]BIOHAZARD VERSION 0.9[/B]
add bio_ltm_acs //1= admin only
add bio_ltm_glow //1 = glowing mine.
fixed. laser hit system.
fixed. breakable mine.

[B]BIOHAZARD VERSION 0.8[/B]
fixed. PrecacheSound Error.

[B]BIOHAZARD VERSION 0.7[/B]
fixed. laser Hit system.
fixed. can't deploy mine.

[B]BIOHAZARD VERSION 0.6[/B]
fixed. ltm_dmg bug.
code synchronized v2.0

[B]BIOHAZARD VERSION 0.5[/B]
fixed +use used hungup.

[B]BIOHAZARD VERSION 0.4[/B]
hungup(Zlib error) fixed.

[B]BIOHAZARD VERSION 0.2[/B]
change deploy cmd. "+setlaser" -> "+USE" key.
add "bio_ltm_startammo" default 1. start set ammo. 0 is off.

[B]BIOHAZARD VERSION 0.1[/B]
ver2.0RC recoding for Bio, release.
all cvars changed. bio_ltm_xxx.[/color]
[/spoiler]
