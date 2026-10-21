#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <dhooks>

// int CCSPlayer::OnDamagedByExplosion(CTakeDamageInfo const&)
DynamicHook g_hDamagedByExplosion;

public Plugin myinfo =
{
	name			= "NoGrenadeRinging",
	author			= "BotoX",
	description		= "Block the annoying ringing noise when a grenade explodes next to you",
	version			= "1.2.2",
	url				= ""
};

public void OnPluginStart()
{
	GameData hTemp = new GameData("NoGrenadeRinging.games");
	if(hTemp == null)
		SetFailState("Why you no has gamedata?");

	int Offset = hTemp.GetOffset("OnDamagedByExplosion");
	g_hDamagedByExplosion = new DynamicHook(Offset, HookType_Entity, ReturnType_Int, ThisPointer_CBaseEntity);
	g_hDamagedByExplosion.AddParam(HookParamType_ObjectPtr);
	delete hTemp;

	/* Late load */
	for(int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
			OnClientPutInServer(client);
	}
}

public void OnClientPutInServer(int client)
{
	// Don't add removal callback for this one
	g_hDamagedByExplosion.HookEntity(Hook_Pre, client, OnDamagedByExplosion);
}

// int CCSPlayer::OnDamagedByExplosion(CTakeDamageInfo const&)
public MRESReturn OnDamagedByExplosion(int pThis, DHookReturn hReturn, DHookParam hParams)
{
	// Block call
	hReturn.Value = 0;
	return MRES_Supercede;
}
