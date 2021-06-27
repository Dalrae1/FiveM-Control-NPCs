RegisterServerEvent("DalraeTakeControl:DeleteEntity", function(pedNetID)
    local ped = NetworkGetEntityFromNetworkId(pedNetID)
    if DoesEntityExist(ped) then
        DeleteEntity(ped)
    end
end)
