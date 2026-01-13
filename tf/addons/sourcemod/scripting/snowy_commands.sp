
#include <sourcemod>
#include <tf2_stocks>
#include <sdktools>
#undef REQUIRE_PLUGIN
#include <adminmenu>

#include <snowy/main>
#include <snowy/commands>


TopMenu hTopMenu;
Menu g_MapList;

// ConVars
ConVar g_displayNoclipUsed = null;

//Other
StringMap g_ProtectedVars;

#include "snowy/infiniteammo.sp"


#include "snowy_cmds/tp_fp.sp" 			// Generic

// Admin
// #include "snowy_cmds/admin/.sp"   	// Admin
#include "snowy_cmds/admin/noclip.sp"   	// Admin
#include "snowy_cmds/admin/plugins.sp"    	// Admin
#include "snowy_cmds/admin/password.sp"   	// Admin
#include "snowy_cmds/admin/cvar.sp"   	// Admin
#include "snowy_cmds/admin/rcon.sp"   	// Admin
#include "snowy_cmds/admin/execcfg.sp"   	// Admin
#include "snowy_cmds/admin/who.sp"   	// Admin

public Plugin myinfo = 
{
	name = "Snowy's Plugin (CMDS)",
	author = "snow2code",
	description = "Nothin",
	version = "0.1.0",      // SOURCEMOD_VERSION
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("plugin.basecommands");
	// LoadTranslations("snowy.phrases");

	// Convars
	g_displayNoclipUsed = CreateConVar("sm_display_noclip_used", "1.0", "Toggle the '[Snowy] Admin toggled noclip on player' message", 0, true, 0.0, true, 1.0);
	
	// Events
	HookEvent("player_spawn", OnPlayerSpawn);
	HookEvent("player_class", OnPlayerSpawn);
	// HookEventEx("server_changelevel_failed", OnChangelevelFailed, EventHookMode_Pre);
	
	// Load
    InfiniteAmmo_Start();
	
    // Commands
	RegConsoleCmd("tp", Command_ThirdPerson);
	RegConsoleCmd("fp", Command_FirstPerson);

	RegAdminCmd("sm_noclip", Command_Noclip, ADMFLAG_CHEATS);
	RegAdminCmd("sm_rcon", Command_Rcon, ADMFLAG_RCON, "sm_rcon <args>");
	RegAdminCmd("sm_cvar", Command_Cvar, ADMFLAG_CONVARS, "sm_cvar <cvar> [value]");
	RegAdminCmd("sm_resetcvar", Command_ResetCvar, ADMFLAG_CONVARS, "sm_resetcvar <cvar>");
	RegAdminCmd("sm_execcfg", Command_ExecCfg, ADMFLAG_CONFIG, "sm_execcfg <filename>");

	/* Account for late loading */
	TopMenu topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != null))
	{
		OnAdminMenuReady(topmenu);
	}
	
	// g_MapList = new Menu(MenuHandler_ChangeMap, MenuAction_Display);
	// g_MapList.SetTitle("%T", "Please select a map", LANG_SERVER);
	// g_MapList.ExitBackButton = true;
	
	char mapListPath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, mapListPath, sizeof(mapListPath), "configs/adminmenu_maplist.ini");
	SetMapListCompatBind("sm_map menu", mapListPath);
	
	g_ProtectedVars = new StringMap();
	ProtectVar("rcon_password");
	ProtectVar("sm_show_activity");
	ProtectVar("sm_immunity_mode");
}

public void OnAdminMenuReady(Handle aTopMenu)
{
	TopMenu topmenu = TopMenu.FromHandle(aTopMenu);

	/* Block us from being called twice */
	if (topmenu == hTopMenu)
	{
		return;
	}
	
	/* Save the Handle */
	hTopMenu = topmenu;
	
	/* Build the "Player Commands" category */
	TopMenuObject player_commands = hTopMenu.FindCategory(ADMINMENU_PLAYERCOMMANDS);
	
	if (player_commands != INVALID_TOPMENUOBJECT)
	{
		// hTopMenu.AddItem("sm_kick", AdminMenu_Kick, player_commands, "sm_kick", ADMFLAG_KICK);
		hTopMenu.AddItem("sm_who", AdminMenu_Who, player_commands, "sm_who", ADMFLAG_GENERIC);
	}

	TopMenuObject server_commands = hTopMenu.FindCategory(ADMINMENU_SERVERCOMMANDS);

	// if (server_commands != INVALID_TOPMENUOBJECT)
	// {
	// 	hTopMenu.AddItem("sm_reloadadmins", AdminMenu_ReloadAdmins, server_commands, "sm_reloadadmins", ADMFLAG_BAN);
	// 	hTopMenu.AddItem("sm_map", AdminMenu_Map, server_commands, "sm_map", ADMFLAG_CHANGEMAP);
	// 	hTopMenu.AddItem("sm_execcfg", AdminMenu_ExecCFG, server_commands, "sm_execcfg", ADMFLAG_CONFIG);		
	// }

	TopMenuObject voting_commands = hTopMenu.FindCategory(ADMINMENU_VOTINGCOMMANDS);

	// if (voting_commands != INVALID_TOPMENUOBJECT)
	// {
	// 	hTopMenu.AddItem("sm_cancelvote", AdminMenu_CancelVote, voting_commands, "sm_cancelvote", ADMFLAG_VOTE);
	// }
}


public void OnLibraryRemoved(const char[] name)
{
	if (strcmp(name, "adminmenu") == 0)
	{
		hTopMenu = null;
	}
}

#define FLAG_STRINGS		14
char g_FlagNames[FLAG_STRINGS][20] =
{
	"res",
	"admin",
	"kick",
	"ban",
	"unban",
	"slay",
	"map",
	"cvars",
	"cfg",
	"chat",
	"vote",
	"pass",
	"rcon",
	"cheat"
};

int CustomFlagsToString(char[] buffer, int maxlength, int flags)
{
	char joins[6][6];
	int total;
	
	for (int i=view_as<int>(Admin_Custom1); i<=view_as<int>(Admin_Custom6); i++)
	{
		if (flags & (1<<i))
		{
			IntToString(i - view_as<int>(Admin_Custom1) + 1, joins[total++], 6);
		}
	}
	
	ImplodeStrings(joins, total, ",", buffer, maxlength);
	
	return total;
}

void FlagsToString(char[] buffer, int maxlength, int flags)
{
	char joins[FLAG_STRINGS+1][32];
	int total;

	for (int i=0; i<FLAG_STRINGS; i++)
	{
		if (flags & (1<<i))
		{
			strcopy(joins[total++], 32, g_FlagNames[i]);
		}
	}
	
	char custom_flags[32];
	if (CustomFlagsToString(custom_flags, sizeof(custom_flags), flags))
	{
		Format(joins[total++], 32, "custom(%s)", custom_flags);
	}

	ImplodeStrings(joins, total, ", ", buffer, maxlength);
}

public OnGameFrame()
{
    OGF_InfAmmo();
}

public void OnClientPutInServer(int client)
{
    OCPIS_InfAmmo(client); // infiniteammo.sp
}

public void OnClientDisconnect(int client)
{
	OCD_TPFP(client);
}

public void OnClientDisconnect_Post(int client)
{
    OCDP_InfAmmo(client);
}

public Action:OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
    OPS_TPFP(event, name);
}
