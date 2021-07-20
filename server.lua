local Config = {}
Config.UsePermissions = false -- Set to false to allow everyone to use the script

RegisterServerEvent("DalraeTakeControl:DeleteEntity", function(pedNetID)
    local ped = NetworkGetEntityFromNetworkId(pedNetID)
    if DoesEntityExist(ped) then
        DeleteEntity(ped)
    end
end)

RegisterServerEvent("DalraeTakeControl:SendPermissions", function()
    if Config.UsePermissions then
        TriggerClientEvent("DalraeTakeControl:RecievePermissions", source, IsPlayerAceAllowed(source, "ControlNPCs.Allow"))
    else
        TriggerClientEvent("DalraeTakeControl:RecievePermissions", source, true)
    end
end)
