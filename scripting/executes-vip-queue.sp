#include <sourcemod>
#include <executes>

#pragma semicolon 1
#pragma newdecls required

#define MESSAGE_PREFIX "[\x04Executes\x01]"

public Plugin myinfo =
{
	name = "[Executes] VIP Queue",
	author = "B3none",
	description = "Allow VIP players to take priority in the queue.",
	version = "1.0.0",
	url = "https://github.com/b3none"
};

public void Executes_OnPreRoundEnqueue(ArrayList rankingQueue, ArrayList waitingQueue)
{
	int vip;
	
	vip = FindAdminInArray(waitingQueue);
	
	int count;
	while (vip != -1)
	{
		PQ_Enqueue(rankingQueue, vip, 0);
		Queue_Drop(waitingQueue, vip);
		count++;
		
		vip = FindAdminInArray(waitingQueue);
	}
	
	ArrayList array_players = new ArrayList();
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) > 1 && !CheckCommandAccess(i, "skip_queue", ADMFLAG_RESERVATION, false))
		{
			array_players.Push(i);
		}
	}
	
	int luck, player;
	while (count > 0 && array_players.Length > 0)
	{
		count--;
		
		luck = GetRandomInt(0, array_players.Length - 1);
		player = array_players.Get(luck);
		
		ChangeClientTeam(player, 1);
		
		PrintToChat(player, "%s You have been moved to spectator because a VIP has taken your spot.", MESSAGE_PREFIX);
		
		array_players.Erase(luck);
		
		Queue_Enqueue(waitingQueue, player);
	}
	
	delete array_players;
}

int FindAdminInArray(ArrayList waitingQueue)
{
	if (waitingQueue.Length != 0)
	{
		int client = 0;
		int index = 0;
		bool found = false;
		
		while (!found && index < waitingQueue.Length)
		{
			client = waitingQueue.Get(index);
			
			if (CheckCommandAccess(client, "skip_queue", ADMFLAG_RESERVATION, false))
			{
				found = true;
			}
			else
			{
				index++;
			}
		}
		
		return found ? client : -1;
	}
	
	return -1;
} 

void PQ_Enqueue(ArrayList queueHandle, int client, int value)
{
    int index = PQ_FindClient(queueHandle, client);

    if (index == -1) {
        index = queueHandle.Length;
        queueHandle.Push(client);
        queueHandle.Set(index, client, 0);
    }

    queueHandle.Set(index, value, 1);
}

int PQ_FindClient(ArrayList queueHandle, int client)
{
    for (int i = 0; i < queueHandle.Length; i++)
    {
        int c = queueHandle.Get(i, 0);
        
        if (client == c)
        {
            return i;
        }
    }
    return -1;
}

void Queue_Enqueue(ArrayList queueHandle, int client)
{
    if (Queue_Find(queueHandle, client) == -1)
    {
        queueHandle.Push(client);
    }
}

int Queue_Find(ArrayList queueHandle, int client)
{
    return queueHandle.FindValue(client);
}

void Queue_Drop(ArrayList queueHandle, int client)
{
    int index = Queue_Find(queueHandle, client);
    
    if (index != -1)
    {
        queueHandle.Erase(index);
    }
}
