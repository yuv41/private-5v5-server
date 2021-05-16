#define PLUGIN_VERSION "1.0"
public Plugin:myinfo =
{
    name = "SM Chat Tag Replacer",
    author = "",
    description = "",
    version = PLUGIN_VERSION,
    url = ""
};
public OnPluginStart()
{
    // Just for games with Protobuf
    if(GetUserMessageType() == UM_Protobuf)
    {
        HookUserMessage(GetUserMessageId("TextMsg"), TextMsg, true);
    }
}

public Action:TextMsg(UserMsg:msg_id, Handle:pb, players[], playersNum, bool:reliable, bool:init)
{
    if(!reliable || PbReadInt(pb, "msg_dst") != 3)
    {
        return Plugin_Continue;
    }

    new String:buffer[256];
    PbReadString(pb, "params", buffer, sizeof(buffer), 0);

    if(StrContains(buffer, "[SM] ") == 0)
    {
        new Handle:pack;
        CreateDataTimer(0.0, new_output, pack, TIMER_FLAG_NO_MAPCHANGE);
        WritePackCell(pack, playersNum);
        for(new i = 0; i < playersNum; i++)
        {
            WritePackCell(pack, players[i]);
        }
        WritePackCell(pack, strlen(buffer));
        WritePackString(pack, buffer);
        ResetPack(pack);

        return Plugin_Handled;
    }

    return Plugin_Continue;
}

public Action:new_output(Handle:timer, Handle:pack)
{
    new playersNum = ReadPackCell(pack);
    new players[playersNum];
    new player, players_count;

    for(new i = 0; i < playersNum; i++)
    {
        player = ReadPackCell(pack);

        if(IsClientInGame(player))
        {
            players[players_count++] = player;
        }
    }

    playersNum = players_count;

    if(playersNum < 1)
    {
        return;
    }

    new Handle:pb = StartMessage("TextMsg", players, playersNum, USERMSG_BLOCKHOOKS);
    PbSetInt(pb, "msg_dst", 3);

    new buffer_size = ReadPackCell(pack)+15;
    new String:buffer[buffer_size];
    ReadPackString(pack, buffer, buffer_size);
    //Chat SM Prefix Changer
    Format(buffer, buffer_size, " \x04[NewVision]\x01%s", buffer[4]); //purple [SM] prefix only

    PbAddString(pb, "params", buffer);
    PbAddString(pb, "params", NULL_STRING);
    PbAddString(pb, "params", NULL_STRING);
    PbAddString(pb, "params", NULL_STRING);
    PbAddString(pb, "params", NULL_STRING);
    EndMessage();

} 