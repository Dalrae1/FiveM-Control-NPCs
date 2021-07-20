local Config = {}
Config.UsePermissions = false -- Set to false to allow everyone to use the script

RegisterServerEvent("DalraeTakeControl:DeleteEntity", function(pedNetID)
    if IsPlayerAceAllowed(source, "ControlNPCs.Allow") or not Config.UsePermissions then
        local ped = NetworkGetEntityFromNetworkId(pedNetID)
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end)

RegisterServerEvent("DalraeTakeControl:SendPermissions", function()
    if Config.UsePermissions then
        TriggerClientEvent("DalraeTakeControl:RecievePermissions", source, IsPlayerAceAllowed(source, "ControlNPCs.Allow"))
    else
        TriggerClientEvent("DalraeTakeControl:RecievePermissions", source, true)
    end
end)

RegisterServerEvent("DalraeTakeControl:StopTakeControlPlayer", function()
    if IsPlayerAceAllowed(source, "ControlNPCs.Allow") or not Config.UsePermissions then
        Entity(GetPlayerPed(source)).state.Controlling = "None"
    end
end)

RegisterServerEvent("DalraeTakeControl:TakeControlPlayer", function(targetPlayer, pedVehicleNetId, seatIndex)
    if IsPlayerAceAllowed(source, "ControlNPCs.Allow") or not Config.UsePermissions then
        local myPed, targetPed = GetPlayerPed(source), GetPlayerPed(targetPlayer)
        if pedVehicleNetId and DoesEntityExist(NetworkGetEntityFromNetworkId(pedVehicleNetId)) then
            SetEntityCoords(targetPed, GetEntityCoords(targetPed)+vector3(0,0,-50))
            TriggerClientEvent("DalraeTakeControl:PutInVehicle", source, pedVehicleNetId, seatIndex)
        end
        
        Entity(GetPlayerPed(source)).state.Controlling = targetPlayer
        TriggerClientEvent("DalraeTakeControl:TakeControlPlayer", targetPlayer, source)
    end
end)
