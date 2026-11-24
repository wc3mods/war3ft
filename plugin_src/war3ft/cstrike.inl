/*
*	Counter-Strike and Condition Zero only functions
*/

public on_EndRound()
{

	if ( !WC3_Check() )
	{
		return;
	}

	g_EndRound = true;


	// Save XP at the end of the round?
	if ( get_pcvar_num( CVAR_wc3_save_end_round ) )
	{
		// Threaded saves on end round!
		DB_SaveAll( true );
	}
	
	return;
}

// Called when freezetime is over
public on_FreezeTimeComplete()
{

	if ( !WC3_Check() )
	{
		return;
	}

	g_freezeTime = false;
	
	new iPlayers[32], iNumPlayers, i;
	get_players( iPlayers, iNumPlayers, "a" );
	
	// Loop through all players
	for ( i = 0; i < iNumPlayers; i++ )
	{
		
		// Show them their race/xp/item bar
		WC3_ShowBar( iPlayers[i] );

		// Award speed bonuses (if any)
		set_task( 0.1, "SHARED_SetSpeed", TASK_UNHOLYSPEED + iPlayers[i] );
	}

	return;
}

public on_TerroristWin()
{

	if ( !WC3_Check() )
	{
		return;
	}

	XP_WinRound( TEAM_T );

	return;
}

public on_CTWin()
{
	if ( !WC3_Check() )
	{
		return;
	}

	XP_WinRound( TEAM_CT );

	return;
}


// Function called when a user's armor changes
public on_Battery( id )
{	
	if ( !WC3_Check() )
	{
		return;
	}
	
	if ( !bIgnoreArmorSet[id] )
	{
		// Store the previous value (we do this b/c the Battery event is triggered (and set to 0) before weapon reincarnation)
		p_data[id][P_LASTARMOR] = p_data[id][P_ARMORONDEATH];

		p_data[id][P_ARMORONDEATH] = read_data( 1 );
	}

	return;
}

public on_ArmorType(id)
{

	if ( !WC3_Check() )
	{
		return;
	}
	
	// Save user's armor
	p_data[id][P_ARMORONDEATH] = cs_get_user_armor( id, g_ArmorType[id] );

	return;
}

// Event triggered when you look at another player
public on_ShowStatus( id )
{

	if ( !WC3_Check() )
	{
		return;
	}

	// Lets not show any player info during freezetime! - don't want them to find moles (unless they have mole protectant) :P
	if ( g_freezeTime && ITEM_Has( id, ITEM_PROTECTANT ) == ITEM_NONE )
	{
		Create_StatusText( id, 0, "" );

		return;
	}

	new iTarget = read_data( 2 );
	
	new iTargetTeam = get_user_team( iTarget );
	new iViewerTeam = get_user_team( id );

	// Same team check
	if ( iViewerTeam == iTargetTeam )
	{

		// Check if your teammate looks like the enemy!
		if ( p_data_b[iTarget][PB_SKINSWITCHED] )
		{
		
			client_print( id, print_center, "%L", id, "HES_ON_YOUR_TEAM_DONT_SHOOT" );
			
			client_cmd( id, "speak %s", g_szSounds[SOUND_ANTEND] );
		}
	}

	// Show player icons if they are enabled
	if ( g_bExtraSpritesEnabled )
	{

		// Only show if player is on the same team
		if ( iViewerTeam == iTargetTeam )
		{

			// Race icons are enabled and the user has them turned on!
			if ( get_pcvar_num( CVAR_wc3_race_icon ) && p_data[id][P_SHOWICONS] )
			{
				Create_TE_PLAYERATTACHMENT( id, iTarget, 55, g_iRaceSprites[p_data[iTarget][P_RACE]], 15 );
			}

			// Level icons are enabled and the user has them turned on!
			if ( get_pcvar_num( CVAR_wc3_level_icon ) && p_data[id][P_SHOWICONS] )
			{
				Create_TE_PLAYERATTACHMENT( id, iTarget, 35, g_iLevelSprites[p_data[iTarget][P_LEVEL]], 16 );
			}
		}
	}

	// Show player information on screen?
	if ( !g_freezeTime && get_pcvar_num( CVAR_wc3_show_player ) )
	{

		new iRed = 0, iBlue = 0, bool:bShowAsTeammate = false;

		new szTargetName[32];
		get_user_name( iTarget, szTargetName, 31 );
		
		// The target looks like the enemy o.O
		if ( p_data_b[iTarget][PB_SKINSWITCHED] )
		{

			// Then the viewer should see the user's true color!
			if ( ITEM_Has( id, ITEM_PROTECTANT ) > ITEM_NONE )
			{
				( iTargetTeam == TEAM_T )	? ( iRed = 255 ) : 0;
				( iTargetTeam == TEAM_CT )	? ( iBlue = 255 ) : 0;
			}

			// Lets "camouflage" them
			else
			{
				( iTargetTeam == TEAM_T )	? ( iBlue = 255 ) : 0;
				( iTargetTeam == TEAM_CT )	? ( iRed = 255 ) : 0;

				bShowAsTeammate = true;
			}
		}
		
		// Lets just set the correct colors
		else
		{
			( iTargetTeam == TEAM_T )	? ( iRed = 255 ) : 0;
			( iTargetTeam == TEAM_CT )	? ( iBlue = 255 ) : 0;
		}
		
		// Set up the hud message
		set_hudmessage( iRed, 50, iBlue, -1.0, 0.60, 1, 0.01, 3.0, 0.01, 0.01, HUD_SHOWSTATUS );

		// Teammate or should look like teammate
		if ( iViewerTeam == iTargetTeam || bShowAsTeammate )
		{
			new iClip, iAmmo;
			new iWeaponID = get_user_weapon( iTarget, iClip, iAmmo );
			new szWeaponName[32];

			// Only get the weapon name if our weapon id is valid
			if ( iWeaponID > 0 )
			{
				get_weaponname( iWeaponID, szWeaponName, 31 );
			}
			
			show_hudmessage( id, "%s -- %d HP / %d AP%s%s", szTargetName, get_user_health( iTarget ), get_user_armor( iTarget ), ( ( iWeaponID > 0 ) ? " / " : "" ), szWeaponName );
		} 

		// Enemy
		else
		{
			show_hudmessage( id, szTargetName );
		}
	}

	return;
}

// This is called when the user is no longer viewing the player
public on_HideStatus( id )
{
	if ( !WC3_Check() )
	{
		return;
	}

	if ( get_pcvar_num( CVAR_wc3_show_player ) && !g_freezeTime )
	{
		UTIL_ClearHudChannel( id, HUD_SHOWSTATUS );
	}
}

public _CS_MinModelsLoop()
{
	if ( !WC3_Check() )
	{
		return;
	}

	if ( get_pcvar_num( CVAR_wc3_query_client ) )
	{
		new iPlayers[32], iNumPlayers, i;
		get_players( iPlayers, iNumPlayers, "c" );
		
		for ( i = 0; i < iNumPlayers; i++ )
		{
			query_client_cvar( iPlayers[i], "cl_minmodels", "_CS_CheckMinModelsValue" );
		}
	}
}

public _CS_CheckMinModelsValue( id, const cvar[], const value[] )
{
	if ( equali( cvar,"cl_minmodels" ) && strcmp( value, "0" ) )
	{
		client_cmd( id, "echo ^"======== Warcraft 3 Frozen Throne ========^"" );
		client_cmd( id, "echo ^"You were kicked because cl_minmodels is set to 1 on your client, please change this to 0.^"" );
		client_cmd( id, "echo ^"Type ^"cl_minmodels 0^" in your console and press enter to do this.^"" );
		client_cmd( id, "echo ^"=========================================^"" );
		server_cmd( "kick #%d ^"cl_minmodels 1 is not allowed on this server^"", get_user_userid( id ) );
	} 
}

// Function is called when buytime is over
public _CS_BuyTimeOver()
{
	g_buyTime = false;
}

CS_GetIcon( id )
{
	new szInfo[32];
	get_user_info( id, "_wc3", szInfo, 31 );

	if ( strlen( szInfo ) > 0 && str_to_num( szInfo ) > 0 )
	{
		p_data[id][P_SHOWICONS] = true;
	}
	else
	{
		p_data[id][P_SHOWICONS] = false;
	}
}

CS_SetIcon( id )
{
	client_cmd( id, "setinfo _wc3 ^"%d^"", p_data[id][P_SHOWICONS] )
}

public on_WeapPickup( id )
{ 

	if ( !WC3_Check() )
	{
		return;
	}

	SHARED_SaveWeapons( id );

	return;
}

public on_GameRestart()
{

	if ( !WC3_Check() )
	{
		return;
	}
	
	// Save all XP on game restart - do not do this threaded or it might take 300 years
	DB_SaveAll( false );

	g_GameRestarting = true;

	return;
}

// From war3x
public on_Zoom( id )
{

	if ( !WC3_Check() )
	{
		return;
	}

	if ( read_data( 1 ) < 90 )
	{
		g_bPlayerZoomed[id] = true;
	}

	else
	{
		g_bPlayerZoomed[id] = false;
	}

	// We will need to change the user's speed on zooming
	SHARED_SetSpeed( id );

	return;
}

public on_BombPlanting( id )
{
	p_data_b[id][PB_ISPLANTING] = true;
}

public on_BombStopPlanting( id )
{
	p_data_b[id][PB_ISPLANTING] = false;
}

public CZ_BotHookHam( id )
{
    // Thx to Avalanche and GunGame of which this method is based off of
    if ( g_bCZBotRegisterHam || !is_user_connected(id) || (g_MOD != GAME_CZERO && g_MOD != GAME_CSTRIKE))
		return;


    // Recheck for safety.
    if ( (pev(id, pev_flags) & FL_FAKECLIENT) && get_pcvar_num(CVAR_bot_quota) > 0 )
	{
        // Post spawn fix for cz bots, since RegisterHam does not work for them
        RegisterHamFromEntity( Ham_TakeDamage, id, "EVENT_TakeDamage", 1 );
		RegisterHamFromEntity( Ham_Spawn, id, "EVENT_Spawn", 1);

        // Only needs to run once after ham is registed ignore.
        g_bCZBotRegisterHam = true;
    }
}