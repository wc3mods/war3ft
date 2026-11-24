/* AMX Mod X
*   Warcraft 3 Frozen Throne
*
*  by Geesu
*  http://www.war3ft.com
*
*  This program is free software; you can redistribute it and/or modify it
*  under the terms of the GNU General Public License as published by the
*  Free Software Foundation; either version 2 of the License, or (at
*  your option) any later version.
*
*  This program is distributed in the hope that it will be useful, but
*  WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
*  General Public License for more details.
*
*  You should have received a copy of the GNU General Public License
*  along with this program; if not, write to the Free Software Foundation,
*  Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*
*  In addition, as a special exception, the author gives permission to
*  link the code of this program with the Half-Life Game Engine ("HL
*  Engine") and Modified Game Libraries ("MODs") developed by Valve,
*  L.L.C ("Valve"). You must obey the GNU General Public License in all
*  respects for all of the code used other than the HL Engine and MODs
*  from Valve. If you modify this file, you may extend this exception
*  to your version of the file, but you are not obligated to do so. If
*  you do not wish to do so, delete this exception statement from your
*  version.
*/

#pragma tabsize			0
//#pragma semicolon		1

new const WC3NAME[]		=	"Warcraft 3 Frozen Throne";
new const WC3AUTHOR[]	=	"Geesu, Avanderik & YamiKaitou";
new const WC3VERSION[]	=	"3.0.1";
new const WC3DATE[]		=	__DATE__;

// Let AMX X know that we NEED these modules (as of amx x 1.75)
#pragma reqclass	xstats
#pragma reqlib		engine
#pragma reqlib		fun
#pragma reqlib		fakemeta
#pragma reqlib		cstrike
#pragma reqlib		dodfun
#pragma loadlib		sqlite
#pragma loadlib		mysql

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fun>
#include <fakemeta>
#include <cstrike>
#include <dodfun>
#include <dodx>
#include <dbi>
#include <sqlx>
#include <hamsandwich>

// Header files that contain function declarations and variables
#include "war3ft/constants.inl"
#include "war3ft/db/db_common.h"
#include "war3ft/db/db_mysqlx.h"
#include "war3ft/db/db_sqlite.h"
#include "war3ft/items.h"
#include "war3ft/dod_h.inl"
#include "war3ft/XP.h"
#include "war3ft/war3ft.h"
#include "war3ft/cstrike.h"
#include "war3ft/menus.h"
#include "war3ft/shared.h"
#include "war3ft/ultimates.h"

// Source Code
#include "war3ft/cvar.inl"

#include "war3ft/race_undead.inl"           // Undead Scourge   - 1
#include "war3ft/race_human.inl"			// Human Alliance	- 2
#include "war3ft/race_orc.inl"				// Orcish Horde		- 3
#include "war3ft/race_elf.inl"				// Night Elf		- 4
#include "war3ft/race_blood.inl"			// Blood Mage		- 5
#include "war3ft/race_shadow.inl"			// Shadow Hunter	- 6
#include "war3ft/race_warden.inl"           // Warden           - 7
#include "war3ft/race_crypt.inl"			// Crypt Lord       - 8
#include "war3ft/race_chameleon.inl"		// Chameleon		- 9

#include "war3ft/forwards.inl"
#include "war3ft/effects.inl"
#include "war3ft/XP.inl"
#include "war3ft/db/db_mysqlx.inl"
#include "war3ft/db/db_sqlite.inl"
#include "war3ft/db/db_common.inl"
#include "war3ft/war3ft.inl"
#include "war3ft/events.inl"
#include "war3ft/clientCommands.inl"
#include "war3ft/items.inl"
#include "war3ft/stocks.inl"
#include "war3ft/shared.inl"
#include "war3ft/menus.inl"
#include "war3ft/motd.inl"
#include "war3ft/language.inl"
#include "war3ft/admin.inl"
#include "war3ft/ultimates.inl"
#include "war3ft/util.inl"
#include "war3ft/skill_manager.inl"

#include "war3ft/cstrike.inl"
#include "war3ft/dod.inl"

public plugin_init()
{
	register_plugin( WC3NAME, WC3VERSION, WC3AUTHOR );
	
	WC3_DetermineGame();

	gmsgDeathMsg		= get_user_msgid( "DeathMsg"	);
	gmsgScreenFade		= get_user_msgid( "ScreenFade"	);
	gmsgScreenShake		= get_user_msgid( "ScreenShake"	);
	gmsgScoreInfo		= get_user_msgid( "ScoreInfo"	);
	
	register_concmd( "war3_version"		, "CMD_Handler"		, -1 );
	register_concmd( "playerskills"		, "CMD_Handler"		, -1 );

	register_clcmd( "debug"				, "CMD_Handler"		, -1 );
	register_clcmd( "levitation"		, "CMD_Handler"		, -1 );
	register_clcmd( "war3menu"			, "CMD_Handler"		, -1 );
	register_clcmd( "changerace"		, "CMD_Handler"		, -1 );
	register_clcmd( "selectskill"		, "CMD_Handler"		, -1 );
	register_clcmd( "skillsinfo"		, "CMD_Handler"		, -1 );
	register_clcmd( "resetskills"		, "CMD_Handler"		, -1 );
	register_clcmd( "resetxp"			, "CMD_Handler"		, -1 );
	register_clcmd( "itemsinfo"			, "CMD_Handler"		, -1 );
	register_clcmd( "itemsinfo2"		, "CMD_Handler"		, -1 );
	register_clcmd( "shopmenu"			, "CMD_Handler"		, -1 );
	register_clcmd( "shopmenu2"			, "CMD_Handler"		, -1 );
	register_clcmd( "ability"			, "CMD_Handler"		, -1 );
	register_clcmd( "ankh"				, "CMD_Handler"		, -1 );
	register_clcmd( "amulet"			, "CMD_Handler"		, -1 );
	register_clcmd( "boots"				, "CMD_Handler"		, -1 );
	register_clcmd( "claws"				, "CMD_Handler"		, -1 );
	register_clcmd( "cloak"				, "CMD_Handler"		, -1 );
	register_clcmd( "chameleon"			, "CMD_Handler"		, -1 );
	register_clcmd( "frost"				, "CMD_Handler"		, -1 );
	register_clcmd( "gloves"			, "CMD_Handler"		, -1 );
	register_clcmd( "health"			, "CMD_Handler"		, -1 );
	register_clcmd( "helm"				, "CMD_Handler"		, -1 );
	register_clcmd( "mask"				, "CMD_Handler"		, -1 );
	register_clcmd( "mole"				, "CMD_Handler"		, -1 );
	register_clcmd( "necklace"			, "CMD_Handler"		, -1 );
	register_clcmd( "rings"				, "CMD_Handler"		, -1 );
	register_clcmd( "socks"				, "CMD_Handler"		, -1 );
	register_clcmd( "scroll"			, "CMD_Handler"		, -1 );
	register_clcmd( "tome"				, "CMD_Handler"		, -1 );
	register_clcmd( "level"				, "CMD_Handler"		, -1 );
	register_clcmd( "say"				, "cmd_Say"			, -1 );
	register_clcmd( "say_team"			, "cmd_Say"			, -1 );
	register_clcmd( "war3help"			, "CMD_Handler"		, -1 );
	register_clcmd( "ultimate"			, "cmd_Ultimate"	, -1 );
	register_clcmd( "fullupdate"		, "cmd_fullupdate"	, -1 );
	register_clcmd( "drop"				, "on_Drop"			, -1 );
	register_clcmd( "jointeam"			, "cmd_Jointeam"	, -1 );

	// Admin Commands
	register_concmd( "wc3_givexp"		, "ADMIN_Handler"		, -1 , " -- Gives XP to players"				);
	register_concmd( "wc3_setlevel"	    , "ADMIN_Handler"		, -1 , " -- Sets a player's level"				);
	register_concmd( "wc3_giveitem"		, "ADMIN_Handler"		, -1 , " -- Gives an item to a player"			);
	register_concmd( "wc3_enable"		, "ADMIN_Handler"		, -1 , " -- Enables war3ft"						);
	register_concmd( "wc3_disable"		, "ADMIN_Handler"		, -1 , " -- Disables war3ft"					);

	// Depreciated Admin Commands
	register_concmd( "amx_givexp"		, "ADMIN_Handler"		, -1 , " -- Gives XP to players"				);

	// Server Admin Commands (used by external plugins)
	register_srvcmd( "amx_takexp"		, "ADMIN_ServerHandler"	);
	register_srvcmd( "changexp"			, "ADMIN_ServerHandler"	);

	// Register forwards (from fakemeta)
	register_forward( FM_TraceLine		, "TRIGGER_TraceLine"	);

	register_event( "DeathMsg"			, "on_DeathMsg"		, "a"								);
	register_event( "CurWeapon"			, "on_CurWeapon"	, "be"	, "1=1"						);
	register_event( "HideWeapon"		, "on_CurWeapon"	, "b"								);
//	register_event( "ResetHUD"			, "on_ResetHud"		, "b"								);
	register_event( "TextMsg"			, "on_GameRestart"	, "a"	, "2&#Game_will_restart_in" );
	register_event( "HLTV"				, "EVENT_NewRound"	, "a"	, "1=0"	,			"2=0"	);

	register_dictionary( "war3FT.txt");

	RegisterHam( Ham_TakeDamage, "player", "EVENT_TakeDamage" );
	RegisterHam( Ham_Spawn, "player", "EVENT_Spawn", 1);

	// Game Specific Initialization
	if ( g_MOD == GAME_CSTRIKE || g_MOD == GAME_CZERO )
	{
		gmsgBarTime			= get_user_msgid( "BarTime"		);
		gmsgStatusText		= get_user_msgid( "StatusText"	);
		gmsgStatusIcon		= get_user_msgid( "StatusIcon"	);

		register_logevent( "on_PlayerAction"		, 3		, "1=triggered"								);
		register_logevent( "on_FreezeTimeComplete"	, 2		, "0=World triggered"	, "1=Round_Start"	);
		register_logevent( "on_EndRound"			, 2		, "0=World triggered"	, "1=Round_End"		);

		register_event( "SendAudio"		, "on_TerroristWin"		, "a"	, "2=%!MRAD_terwin"					);
		register_event( "SendAudio"		, "on_CTWin"			, "a"	, "2=%!MRAD_ctwin"					);
		register_event( "ArmorType"		, "on_ArmorType"		, "be"										);
		register_event( "Battery"		, "on_Battery"			, "be"										);
		register_event( "WeapPickup"	, "on_WeapPickup"		, "b"										); 
		register_event( "StatusValue"	, "on_ShowStatus"		, "be"	, "1=2"		,"2!0"					);
		register_event( "StatusValue"	, "on_HideStatus"		, "be"	, "1=1"		,"2=0"					);
		register_event( "SetFOV"		, "on_Zoom"				, "be"										);
		register_event( "BarTime"		, "on_BombPlanting"		, "be"	, "1=3"								);
		register_event( "BarTime"		, "on_BombStopPlanting"	, "b"	, "1=0"								);

		// Old Style
		register_menucmd( register_menuid( "BuyItem" )	, (1<<3)	, "cmd_hegren"	);

		// VGUI
		register_menucmd( -34	, (1<<3)	, "cmd_hegren"	);

		// Steam
		register_clcmd( "hegren"	, "cmd_hegren"	);
		
		// Old style menu (now its jointeam client command)
		register_menucmd( register_menuid( "Team_Select" , 1 )	, (1<<0)|(1<<1)|(1<<4)	, "cmd_Teamselect" );

		// Condition Zero
		if ( g_MOD == GAME_CZERO )
		{
			register_event("TextMsg", "on_GameRestart", "a", "2&#Game_Commencing")
		}
		// Counter-Strike
		else
		{
			register_event("TextMsg", "on_GameRestart", "a", "2&#Game_C")
		}
	}
	else if ( g_MOD == GAME_DOD )
	{
		gmsgHudText = get_user_msgid( "HudText" );

		register_statsfwd( XMF_SCORE	);
		register_statsfwd( XMF_DAMAGE	);

		register_event( "RoundState"	, "EVENT_DOD_EndRound"		, "a"	, "1=3"	, "1=4"	);
	}

	// Plugin initialization procedures
	WC3_Init();

	register_concmd( "test", "test" );
	register_concmd( "test2", "test2" );
	
}

public test2(id)
{
	/*WC3_Log( true, "[MYSQLX] Attempting to re-establish connection to MySQL server" );
		// Close the connection
		MYSQLX_Close();

		// Re-open the connection
		MYSQLX_Init();*/

	new players[32], num, i;
	get_players( players, num );

	for ( i = 0; i < num; i++ )
	{
		static s_Classname[ 8 ];
		pev ( i, pev_classname, s_Classname, charsmax ( s_Classname ) );

		server_print( "%d: %s", i, s_Classname );
	}
}

public test(id)
{
	new players[32], num, i, szName[32];
	get_players( players, num );

	for ( i = 0; i < num; i++ )
	{
		get_user_name( players[i], szName, 31 );

		WC3_Log( true, "**** %s ****", szName );

		SM_DebugPrint( players[i] );
		
		WC3_Log( true, " %s ", szName );
	}
}

public plugin_end()
{
	new szCurMap[32];
	get_mapname( szCurMap, 31 );
	WC3_Log( false, "** Map '%s' ended", szCurMap );

	if ( !WC3_Check() )
	{
		return;
	}

	if ( !get_pcvar_num( CVAR_wc3_save_xp ) )
	{
		return;
	}
	
	FWD_Destroy();
	DB_SaveAll( false );
	DB_Prune();
	DB_Close();


	return;
}

public plugin_precache()
{
	WC3_Precache();
}

public client_putinserver( id )
{
	if ( !WC3_Check() )
	{
		return;
	}

	// Check for steam ID pending
	static szPlayerID[32];
	get_user_authid( id, szPlayerID, 31 );
	
	// Then the player doesn't have a steam id, lets make them reconnect
	if ( equal(szPlayerID, "STEAM_ID_PENDING") )
	{
		client_cmd( id, "reconnect" );
	}

	// Get the user's ID!
	DB_FetchUniqueID( id );

	p_data_b[id][PB_ISCONNECTED] = true;
	
	if ( g_MOD == GAME_CSTRIKE || g_MOD == GAME_CZERO )
	{
		// Check user's cvar if the user isn't a bot and if we're not running a 64-bit server
		if ( !is_user_bot( id ) && !is_amd64_server() )
		{
			query_client_cvar( id, "cl_minmodels", "_CS_CheckMinModelsValue" );
		}
		
		if ( (pev(id, pev_flags) & FL_FAKECLIENT) && get_pcvar_num(CVAR_bot_quota) > 0 && !g_bCZBotRegisterHam )
		{
			// Delay for private data to initialize
			set_task( 0.1, "CZ_BotHookHam", id )
		}
	}

	// Start showing the user their money
	else if ( g_MOD == GAME_DOD )
	{
		p_data[id][P_MONEY] = get_pcvar_num( CVAR_wc3_dod_start_money );
		static parm[3];
		parm[0] = id;
		parm[1] = 0;
		_DOD_showMoney( parm );
	}

	return;
}

public client_connect( id )
{
	if ( !WC3_Check() )
	{
		return;
	}

	// Initialize this player
	WC3_PlayerInit( id );

	client_cmd( id, "hud_centerid 0" );


	p_data[id][P_RESPAWNBY]				= 0;
	p_data[id][P_SPECMODE]				= 0;

	p_data_b[id][PB_ISBURNING]			= false;
	p_data_b[id][PB_JUSTJOINED]			= true;
	p_data_b[id][PB_CAN_RENDER]			= true;
	p_data_b[id][PB_HAS_SPAWNED]		= false;
	p_data_b[id][PB_SKINSWITCHED]		= false;

	// User should have no items on connect...
	g_iShopMenuItems[id][0] = -1;
	g_iShopMenuItems[id][1] = -1;

	// Automatically set their XP if it's enabled
	if ( get_pcvar_num( CVAR_wc3_xp_auto_average ) && !get_pcvar_num( CVAR_wc3_save_xp ) )
	{
		new iTotalXP;
		new iNum, i;
		for( i = 1; i <= MAXPLAYERS; i++ )
		{
			if ( p_data[i][P_XP] > 0 )
			{
				iNum++;
				iTotalXP += p_data[i][P_XP];
			}
		}
		if ( iNum > 0 && iTotalXP > 0 )
		{
			p_data[id][P_XP] = iTotalXP/iNum;
		}
	}

	if ( g_MOD == GAME_CSTRIKE || g_MOD == GAME_CZERO )
	{
		p_data[id][P_HECOUNT]		= 0;
		p_data[id][P_FLASHCOUNT]	= 0;
	}
	else if ( g_MOD == GAME_DOD )
	{
		p_data[id][P_MONEY] = 0;
	}

	// Reset the "cheat" variables
	new j;
	for ( j = 0; j < MAX_RACES; j++ )
	{
		g_bGivenLevel10[id][j]	= false;
	}

	CS_GetIcon( id );
	
	return;
}

public client_disconnect( id )
{
	if ( !WC3_Check() )
	{
		return;
	}

	// Update the user's timestamps for each race if we're saving XP
	DB_UpdateTimestamp( id );

	// Remove the money task when a user disconnects
	if ( g_MOD == GAME_DOD )
	{
		task_exists( TASK_MONEYLOOP + id ) ? remove_task( TASK_MONEYLOOP + id ) : 0;
	}

	p_data[id][P_SPECMODE]			= 0;
	p_data_b[id][PB_ISBURNING]		= false;
	p_data_b[id][PB_DIEDLASTROUND]	= false;
	p_data_b[id][PB_JUSTJOINED]		= false;
	p_data_b[id][PB_ISCONNECTED]	= false;
	bIgnoreArmorSet[id]				= false;
	
	// Reset xp assist
	for ( new i = 0; i < MAXPLAYERS; i++ )
	{
		g_iDamageDealt[id][i] = 0;
	}

	// Save the user's XP if we have XP to save
	if ( get_pcvar_num( CVAR_wc3_save_xp ) && !is_user_bot(id) && p_data[id][P_RACE] && p_data[id][P_XP] )
	{
		DB_SaveXP( id, true );
	}

	if ( get_pcvar_num( CVAR_wc3_psychostats ) )
	{
		static szWeapon[64];

		static szTeam[16], szName[32], szAuthid[32];
		new iWeap, iUserid = get_user_userid( id );

		if ( is_user_connected(id) )
		{
			get_user_team( id, szTeam, 15 );
		}
		get_user_name( id, szName, 31 );
		get_user_authid( id, szAuthid, 31 );

		for ( iWeap = CSW_WAR3_MIN; iWeap <=CSW_WAR3_MAX; iWeap++ )
		{
			format( szWeapon, 63, "" );

			switch( iWeap )
			{
				case CSW_LIGHTNING:     LANG_GetSkillName( ULTIMATE_CHAINLIGHTNING	, LANG_SERVER,	szWeapon	, 63, 20 );
				case CSW_SUICIDE:		LANG_GetSkillName( ULTIMATE_SUICIDE			, LANG_SERVER,	szWeapon	, 63, 21 );
				case CSW_IMMOLATE:	    LANG_GetSkillName( ULTIMATE_IMMOLATE		, LANG_SERVER,	szWeapon	, 63, 22 );
				case CSW_LOCUSTS:		LANG_GetSkillName( ULTIMATE_LOCUSTSWARM		, LANG_SERVER,	szWeapon	, 63, 23 );
				case CSW_SERPENTWARD:   LANG_GetSkillName( SKILL_SERPENTWARD		, LANG_SERVER,	szWeapon	, 63, 24 );
				case CSW_SHADOW:		LANG_GetSkillName( SKILL_SHADOWSTRIKE		, LANG_SERVER,	szWeapon	, 63, 25 );
				case CSW_THORNS:		LANG_GetSkillName( SKILL_THORNS				, LANG_SERVER,	szWeapon	, 63, 26 );
				case CSW_CARAPACE:		LANG_GetSkillName( SKILL_SPIKEDCARAPACE		, LANG_SERVER,	szWeapon	, 63, 27 );
				case CSW_CARRION:		LANG_GetSkillName( SKILL_CARRIONBEETLES		, LANG_SERVER,	szWeapon	, 63, 28 );
				case CSW_ORB:			LANG_GetSkillName( PASS_ORB					, LANG_SERVER,	szWeapon	, 63, 29 );
				case CSW_CONCOCTION:	LANG_GetSkillName( PASS_UNSTABLECONCOCTION	, LANG_SERVER,	szWeapon	, 63, 30 );
			}
			
			replace( szWeapon, 63, " ", "_" );

			new WEAPON = iWeap - CSW_WAR3_MIN;
			
			if ( iStatsShots[id][WEAPON] || iStatsHits[id][WEAPON] || iStatsKills[id][WEAPON] ||  iStatsHS[id][WEAPON] || iStatsTKS[id][WEAPON] || iStatsDamage[id][WEAPON] || iStatsDeaths[id][WEAPON] || iStatsHead[id][WEAPON] || iStatsChest[id][WEAPON] || iStatsStomach[id][WEAPON] || iStatsLeftArm[id][WEAPON] || iStatsRightArm[id][WEAPON] || iStatsLeftLeg[id][WEAPON] || iStatsRightLeg[id][WEAPON] )
			{

				// Counter-Strike/Condition Zero log format is different than the DOD
				if ( g_MOD == GAME_CSTRIKE || g_MOD == GAME_CZERO )
				{
					log_message("^"%s<%d><%s><%s>^" triggered ^"weaponstats^" (weapon ^"%s^") (shots ^"%d^") (hits ^"%d^") (kills ^"%d^") (headshots ^"%d^") (tks ^"%d^") (damage ^"%d^") (deaths ^"%d^")", szName, iUserid, szAuthid, szTeam, szWeapon, iStatsShots[id][WEAPON], iStatsHits[id][WEAPON], iStatsKills[id][WEAPON], iStatsHS[id][WEAPON], iStatsTKS[id][WEAPON], iStatsDamage[id][WEAPON], iStatsDeaths[id][WEAPON] );
				}

				// Day of Defeat log format
				else if ( g_MOD == GAME_DOD )
				{
					log_message("^"%s<%d><%s><%s>^" triggered ^"weaponstats^" (weapon ^"%s^") (shots ^"%d^") (hits ^"%d^") (kills ^"%d^") (headshots ^"%d^") (tks ^"%d^") (damage ^"%d^") (deaths ^"%d^") (score ^"%d^")", szName, iUserid, szAuthid, szTeam, szWeapon, iStatsShots[id][WEAPON], iStatsHits[id][WEAPON], iStatsKills[id][WEAPON], iStatsHS[id][WEAPON], iStatsTKS[id][WEAPON], iStatsDamage[id][WEAPON], iStatsDeaths[id][WEAPON], 0 );
				}
				
				log_message("^"%s<%d><%s><%s>^" triggered ^"weaponstats2^" (weapon ^"%s^") (head ^"%d^") (chest ^"%d^") (stomach ^"%d^") (leftarm ^"%d^") (rightarm ^"%d^") (leftleg ^"%d^") (rightleg ^"%d^")", szName, iUserid, szAuthid, szTeam, szWeapon, iStatsHead[id][WEAPON], iStatsChest[id][WEAPON], iStatsStomach[id][WEAPON], iStatsLeftArm[id][WEAPON], iStatsRightArm[id][WEAPON], iStatsLeftLeg[id][WEAPON], iStatsRightLeg[id][WEAPON] );
			
				iStatsShots[id][WEAPON]		= 0;
				iStatsHits[id][WEAPON]		= 0;
				iStatsKills[id][WEAPON]		= 0;
				iStatsHS[id][WEAPON]		= 0;
				iStatsTKS[id][WEAPON]		= 0;
				iStatsDamage[id][WEAPON]	= 0;
				iStatsDeaths[id][WEAPON]	= 0;
				iStatsHead[id][WEAPON]		= 0;
				iStatsChest[id][WEAPON]		= 0;
				iStatsStomach[id][WEAPON]	= 0;
				iStatsLeftArm[id][WEAPON]	= 0;
				iStatsRightArm[id][WEAPON]	= 0;
				iStatsLeftLeg[id][WEAPON]	= 0;
				iStatsRightLeg[id][WEAPON]	= 0;
			}
		}
	}
}

public client_PreThink( id )
{
	if ( !WC3_Check() )
	{
		return;
	}

	if ( p_data_b[id][PB_ISCONNECTED] )
	{
		if ( is_user_alive( id ) )
		{
			
			// Counter-Strike or Condition Zero
			if ( g_MOD == GAME_CSTRIKE || g_MOD == GAME_CZERO )
			{

				// This is used so we can't hear the undead's footsteps at level 3
				if ( SM_GetSkillLevel( id, SKILL_UNHOLYAURA ) > 0 && !p_data_b[id][PB_STUNNED] && !p_data_b[id][PB_SLOWED] )
				{
					new Float:vel[3];
					entity_get_vector( id, EV_VEC_velocity, vel );

					// When this is true, the user is walking...  lets hope :P
					if ( vector_length( vel ) < 180.0 )
					{
						entity_set_int( id, EV_INT_flTimeStepSound, 999 );
					}

					// Otherwise if we just set it on the previous tick we need to set it back
					else if ( entity_get_int(id, EV_INT_flTimeStepSound) > 500 )
					{
						entity_set_int( id, EV_INT_flTimeStepSound, 200 );
					}
				}
			}

			// Day of Defeat
			else if ( g_MOD == GAME_DOD )
			{

				// Set the user's speed
				SHARED_SetSpeed( id );
				
				static iSkillLevel;
				iSkillLevel = SM_GetSkillLevel( id, SKILL_UNHOLYAURA );

				// Give the user more stamina
				if ( iSkillLevel > 0 )
				{
					if ( entity_get_float( id, EV_FL_fuser4 ) < p_unholy_dod[iSkillLevel-1] )
					{
						entity_set_float( id, EV_FL_fuser4, p_unholy_dod[iSkillLevel-1] );
					}

				}

				// Give the user more stamina
				if ( ITEM_Has( id, ITEM_BOOTS ) > ITEM_NONE && entity_get_float( id, EV_FL_fuser4 ) < DOD_BOOT_SPEED )
				{
					entity_set_float( id, EV_FL_fuser4, DOD_BOOT_SPEED );
				}
			}

			// Amulet of the Cat
			if ( ITEM_Has( id, ITEM_AMULET ) > ITEM_NONE )
			{
				entity_set_int( id, EV_INT_flTimeStepSound, 999 );
			}
		}
		
		// User is dead
		else
		{

			// Check to see if spectated player has changed
			new iTarget = entity_get_int( id, EV_INT_iuser2 );
			
			new Float:fTime = halflife_time();

			// Then we are looking at a new player or the last hud message has disappeared
			if ( g_iSpectatingID[id] != iTarget || g_fLastSpecDisplay[id] <= fTime )
			{

				// We have a valid target!!
				if ( SHARED_ValidPlayer( iTarget ) && iTarget != id )
				{
					WC3_ShowSpecInfo( id, iTarget );

					g_fLastSpecDisplay[id] = fTime + SPEC_HOLDTIME;
				}

				g_iSpectatingID[id] = iTarget;
			}
		}
	}

	return;
}

public plugin_natives()
{
	set_module_filter( "module_filter" );
	set_native_filter( "native_filter" );
	set_error_filter( "error_filter" );
}

public error_filter( error_code, bool:debugging, message[] ) 
{
	new szBuffer[256];
	dbg_fmt_error( szBuffer, 255 );

	log_amx( "[ERROR] '%s' '%d' '%d' '%s'", message, error_code, debugging, szBuffer );

	//L 12/27/2006 - 16:48:08: [war3ft.amxx] [ERROR] '[CSTRIKE] Invalid player 5' '10' '1' 'Run time error 10: native error (native "cs_set_user_money")'

	// We want to ignore invalid player messages that are generated by cstrike! - they're annoying + don't actually matter all that much...
	/*if ( error_code == AMX_ERR_NATIVE )
	{
		if ( containi( message, "" ) )
		{
		}
	}*/
}

public module_filter( const module[] )
{
	WC3_DetermineGame();

	// We don't need the cstrike module when we're DOD
	if ( g_MOD == GAME_DOD && equal( module, "cstrike" ) )
	{
		return PLUGIN_HANDLED;
	}

	// And we don't need any dod modules when we're in CS/CZ!
	else if ( ( g_MOD == GAME_CSTRIKE || g_MOD == GAME_CZERO ) && equal( module, "dodfun" ) )
	{
		return PLUGIN_HANDLED;
	}

	// We don't need to display a message, we'll display it later if we need to (when the DB is set up if XP Saving is on)
	else if ( equal( module, "dbi" ) || equal( module, "sqlx" ) )
	{
		return PLUGIN_HANDLED;
	}

	// Dammit plugin can't load now :/ - technically we should never get here unless the module doesn't exist in the modules folder
	else
	{
		WC3_Log( true, "Please enable the '%s' module in your modules.ini file", module );

		return PLUGIN_CONTINUE;
	}

	return PLUGIN_HANDLED;
}

public native_filter( const name[], index, trap )
{
	if ( !trap )
	{
		return PLUGIN_HANDLED;
	}

	return PLUGIN_CONTINUE;
}
