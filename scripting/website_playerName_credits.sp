#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <store>

#pragma newdecls required

/* Globals var of the plugin */
Handle gTimer[MAXPLAYERS + 1];

/* Convars of the plugin */
ConVar cvWeb;
ConVar cvTimer;
ConVar cvAmount;

public Plugin myinfo = 
{
	name = "Website in player name for credits",
	author = "Luckiris",
	description = "Give credits to players if he have a part of his name matching the config",
	version = "1.0",
	url = "https://www.dream-commnunity.de"
};

public void OnPluginStart()
{
	cvWeb = CreateConVar("sm_pnc_website", "dream-community.de", "Website the player should have in his name in order to receive credits");
	cvTimer = CreateConVar("sm_pnc_timer", "60.0", "When the players should receive credits (every X seconds)");
	cvAmount = CreateConVar("sm_pnc_amount_credits", "1", "How much credits the player should get");
	
	AutoExecConfig(true, "website_playername_credits");
}

public void OnClientConnected(int client)
{
	/*	When the client connects, we create the timer set up in config 
	
	*/
	gTimer[client] = CreateTimer(cvTimer.FloatValue, TimerGiveCredits, GetClientUserId(client), TIMER_REPEAT);
}

public void OnClientDisconnect(int client)
{
	/*	When the client disconnects, we kill the timer
	
	*/
	KillTimer(gTimer[client]);
}

public Action TimerGiveCredits(Handle timer, any userid)
{
	/*	Timer to give credits to the client
	
		IF client is valid and has the website
		THEN credits are given to him
		ELSE nothing happen
	
	*/
	int client = GetClientOfUserId(userid);  // <- Get the client number in game
	char website[128];// <- Store the website name
	char name[128]; // <- Store the client name

	/*Check if client in game and has the website */
	if (IsValidClient(client))
	{
		/* Setting up vars */
		GetConVarString(cvWeb, website, sizeof(website));
		GetClientName(client, name, sizeof(name));
		
		if (StrContains(name, website, false) != -1)
		{
			Store_SetClientCredits(client, Store_GetClientCredits(client) + cvAmount.IntValue);
			PrintToChat(client, " \x01[\x04DREAM\x01] You received \x04%i\x01 credits for having our \x04community name\x01", cvAmount.IntValue);
		}
	}
	
	return Plugin_Handled;
}

/* Utils functions */
stock bool IsValidClient(int client)
{
	bool valid = false;
	if (client > 0 && client <= MAXPLAYERS && IsClientConnected(client) && !IsFakeClient(client) && IsClientInGame(client))
	{
		valid = true;
	}
	return valid;
}