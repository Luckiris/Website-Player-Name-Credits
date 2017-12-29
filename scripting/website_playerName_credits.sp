#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <store>
#include <luckiris_include>

#pragma newdecls required

/* Convars of the plugin */
ConVar cvWeb;
ConVar cvTimer;
ConVar cvAmount;

public Plugin myinfo = 
{
	name = "Website in player name for credits",
	author = "Luckiris",
	description = "Give credits to players if he have a part of his name matching the config",
	version = "1.1",
	url = "https://www.dream-commnunity.de"
};

public void OnPluginStart()
{
	LoadTranslations("website_playerName_credits.phrases");
	
	cvWeb = CreateConVar("sm_pnc_website", "dream-community.de", "Website the player should have in his name in order to receive credits");
	cvTimer = CreateConVar("sm_pnc_timer", "60.0", "When the players should receive credits (every X seconds)");
	cvAmount = CreateConVar("sm_pnc_amount_credits", "1", "How much credits the player should get");
	
	AutoExecConfig(true, "website_playername_credits");
}

public void OnMapStart()
{
	CreateTimer(cvTimer.FloatValue, TimerGiveCredits, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action TimerGiveCredits(Handle timer, any userid)
{
	char website[128];// <- Store the website name
	char name[128]; // <- Store the client name
			
	/* Setting up vars */
	GetConVarString(cvWeb, website, sizeof(website));

	for (int i = 0; i < MAXPLAYERS; i++)
	{
		if (IsClientValid(i))
		{
			GetClientName(i, name, sizeof(name));
		
			if (StrContains(name, website, false) != -1)
			{
				Store_SetClientCredits(i, Store_GetClientCredits(i) + cvAmount.IntValue);
				WriteToChat(i, "%t", "Give", cvAmount.IntValue);	
			}
		}
	}
	return Plugin_Continue;
}