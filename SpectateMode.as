/*
Copyright (c) 2016 Drake "MrOats" Denston

This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

/*
Current Status: Stable, but in development.
Documentation: https://github.com/MrOats/AngelScript_SC_Plugins/wiki/SpectateMode.as
Thank you to all those who have assisted me with this plugin!
*/
CScheduledFunction@ g_pKeepSpec=null;
CScheduledFunction@ g_pSetRespawn=null;
const int g_MAXPLAYERS=g_Engine.maxClients;
array<bool> pSpectatePlease(g_MAXPLAYERS,false);
const float MAX_FLOAT=3.402823466*pow(10,38);
CClientCommand spectate( "spectate", "Say \"spectate on\" to turn on and \"spectate off\" to turn off", @toggleSpectate );
//Config

bool adminOnly=false;

//End Config

void PluginInit(){
  g_Module.ScriptInfo.SetAuthor("MrOats");
  g_Module.ScriptInfo.SetContactInfo("http://forums.svencoop.com/showthread.php/44306-Plugin-SpectateMode");
  g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect,@RemoveSpecStatus);
  g_Hooks.RegisterHook(Hooks::Game::MapChange,@EndTimerFuncs);


  @g_pKeepSpec = g_Scheduler.SetInterval("CheckObserver",g_Engine.frametime,g_Scheduler.REPEAT_INFINITE_TIMES);
  @g_pSetRespawn = g_Scheduler.SetInterval("SetRespawnTime",g_Engine.frametime,g_Scheduler.REPEAT_INFINITE_TIMES);
  }

void toggleSpectate(const CCommand@ pArguments){
  CBasePlayer@ pPlayer=g_ConCommandSystem.GetCurrentPlayer();
  if (pSpectatePlease[pPlayer.entindex()]) {
    ExitSpectate(pPlayer);
  }
  else EnterSpectate(pPlayer);
  /*if(pArguments.ArgC()==2){
    if (pArguments[1]=="on") {
      EnterSpectate(pPlayer);
    }
    else if(pArguments[1]=="off"){
      ExitSpectate(pPlayer);
    }
  }*/
}

void EnterSpectate(CBasePlayer@ pPlayer)
{
  g_Game.AlertMessage(at_console, "Entering SpectateMode");
  pSpectatePlease[pPlayer.entindex()]=true;
  if(!pPlayer.GetObserver().IsObserver()){
    pPlayer.GetObserver().StartObserver( pPlayer.pev.origin, pPlayer.pev.angles, false );
  }
}
void CheckObserver(){
  for (int i = 1; i <= g_MAXPLAYERS; i++) {
    CBasePlayer@ pPlayer = g_PlayerFuncs.FindPlayerByIndex(i);
    if(pPlayer !is null){
      if (pSpectatePlease[pPlayer.entindex()]){
        if(!pPlayer.GetObserver().IsObserver()){
        pPlayer.GetObserver().StartObserver( pPlayer.pev.origin, pPlayer.pev.angles, false );
      }
      }
  }
}
}
void ExitSpectate(CBasePlayer@ pPlayer){
  g_Game.AlertMessage(at_console, "Exiting SpectateMode");
  pSpectatePlease[pPlayer.entindex()]=false;
  //Reset the player's respawn time by respawning and killing.
  g_PlayerFuncs.RespawnPlayer(pPlayer,true,true);
  g_AdminControl.KillPlayer(pPlayer,3);
}
HookReturnCode RemoveSpecStatus(CBasePlayer@ pPlayer){
  ExitSpectate(pPlayer);
  return HOOK_HANDLED;
}
HookReturnCode EndTimerFuncs(){
  g_Scheduler.ClearTimerList();
}
