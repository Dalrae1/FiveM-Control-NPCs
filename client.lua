-- Created by Dalrae

--[[CONFIG]]
local Config = {}
Config.RandomSwitchingExcludeAnimals = true -- Excludes animals from being switched to if the player is not aiming/looking at a ped.
Config.SpawnAsCurrentPed = true -- Spawns as the player's current ped. Disable to make them switch back to their original ped.
Config.UseBaseEvents = false -- Use the "baseevents" resource for detecting if a player died.

Config.UseLookDirection = true -- Use the camera direction if the player is not aiming with a gun.
Config.LookRayRadius = 1.0 -- The radius to use for the UseLookDirection config value.

Config.SwitchDelay = 500 -- Time (ms) to wait until switching peds again.
Config.CanAimAtVehicles = true -- If aiming at a vehicle, will switch to the driver of that vehicle. Can still aim at a vehicle and be detected as aiming at the driver though.
Config.ShowWarningWhenCooldown = true -- Show a message in chat when a player attempts to switch to a ped too fast.
--[[END CONFIG]]



function setPedModel(modelHash) -- Sets the player's ped model with the original camera position.
    --local modelHash = GetHashKey(model)
    RequestModel(modelHash)
    local timer = GetGameTimer()
    while not HasModelLoaded(modelHash) do
        if GetGameTimer()-timer > 100 then -- If it has taken this much time, something is wrong since none of these models are addons
            SetNotificationTextEntry("STRING")
            AddTextComponentString("Could not load ped in time, cancelling.")
            DrawNotification(0,1)
            return
        end
        Wait(1)
    end
    SetPlayerModel(PlayerId(), modelHash)
    SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)
    SetModelAsNoLongerNeeded(modelHash)
end

local animalPedModels =
{
    {"a_c_boar", "Boar"},
    {"a_c_cat_01", "Cat"},
    {"a_c_chickenhawk", "Chicken Hawk"},
    {"a_c_chimp", "Chimp"},
    {"a_c_chop", "Chop"},
    {"a_c_cormorant", "Cormorant"},
    {"a_c_cow", "Cow"},
    {"a_c_coyote", "Coyote"},
    {"a_c_crow", "Crow"},
    {"a_c_deer", "Deer"},
    {"a_c_hen", "Hen"},
    {"a_c_husky", "Husky"},
    {"a_c_mtlion", "Mountain Lion"},
    {"a_c_pig", "Pig"},
    {"a_c_pigeon", "Pigeon"},
    {"a_c_poodle", "Poodle"},
    {"a_c_pug", "Pug"},
    {"a_c_rabbit_01", "Rabbit"},
    {"a_c_rat", "Rat"},
    {"a_c_retriever", "Retriever"},
    {"a_c_rhesus", "Rhesus"},
    {"a_c_rottweiler", "Rottweiler"},
    {"a_c_seagull", "Seagull"},
    {"a_c_shepherd", "Shepherd"},
    {"a_c_westy", "Westy"}
}

local entityEnumerator = {
    __gc = function(enum)
      if enum.destructor and enum.handle then
        enum.destructor(enum.handle)
      end
      enum.destructor = nil
      enum.handle = nil
    end
  }
  
  local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
      local iter, id = initFunc()
      if not id or id == 0 then
        disposeFunc(iter)
        return
      end
      
      local enum = {handle = iter, destructor = disposeFunc}
      setmetatable(enum, entityEnumerator)
      
      local next = true
      repeat
        coroutine.yield(id)
        next, id = moveFunc(iter)
      until not next
      
      enum.destructor, enum.handle = nil, nil
      disposeFunc(iter)
    end)
  end
  
  function EnumerateObjects()
    return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
  end
  
  function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
  end
  
  function EnumerateVehicles()
    return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
  end
  
  function EnumeratePickups()
    return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
  end

function isAnimalPed(ped)
    for _,animalModel in pairs(animalPedModels) do
        if GetEntityModel(ped) == GetHashKey(animalModel[1]) then
            return true
        end
    end
    return false
end

function isPlayerPed(ped)
    for _,player in pairs(GetActivePlayers()) do
        if GetPlayerPed(player) == ped then
            return true
        end
    end
    return false
end

function getRandomPed()
    local numPeds = 0
    for ped in EnumeratePeds() do
        RequestCollisionAtCoord(GetEntityCoords(ped).xyz)
        if GetEntityCoords(ped).x ~= 0 and GetEntityCoords(ped).y ~= 0 and GetEntityCoords(ped).y ~= 0 and GetEntityCoords(ped).z ~= -100 and not isPlayerPed(ped) and (Config.RandomSwitchingExcludeAnimals and not isAnimalPed(ped)) and GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(ped)) < 200 then
            numPeds = numPeds+1
        end
    end
    if numPeds > 0 then
        local stopAt = math.random(1,numPeds)
        local curPed = 0
        chosenPed = nil
        for ped in EnumeratePeds() do
            if GetEntityCoords(ped).x ~= 0 and GetEntityCoords(ped).y ~= 0 and GetEntityCoords(ped).y ~= 0 and GetEntityCoords(ped).z ~= -100 and not isPlayerPed(ped) and (Config.RandomSwitchingExcludeAnimals and not isAnimalPed(ped)) and GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(ped)) < 200 then
                curPed = curPed+1
                if curPed == stopAt then
                    return ped
                end
            end
        end
    end
    return PlayerPedId()
end
function getPedVehicle(ped)
    if IsPedInAnyVehicle(ped) then
        local pedVehicle = GetVehiclePedIsIn(ped)
        local numSeats = GetVehicleModelNumberOfSeats(GetEntityModel(pedVehicle))
        for seatIndex=-1, numSeats-2 do
            if GetPedInVehicleSeat(pedVehicle, seatIndex) == ped then
                return pedVehicle, seatIndex
            end
        end
    end
    return false
end

function getPedVariations(ped)
    local pedVariations = {
        ["EyeColor"] = GetPedEyeColor(ped),
        ["HairColor"] = GetPedHairColor(ped),
        ["HairHighlightColor"] = GetPedHairHighlightColor(ped),
        ["HeadBlend"] = nil,
        ["HeadOverlays"] = {},
        ["FaceFeatures"] = {},
        ["Props"] = {},
        ["Components"] = {},
    }
    local successful, blendData = GetPedHeadBlendData(ped)
    if successful then
        pedVariations.HeadBlend = blendData
    end
    for overlayID = 0,12 do
        local successful, overlayValue, colorType, firstColor, secondColor, overlayOpacity = GetPedHeadOverlayData(ped, overlayID)
        if successful then
            pedVariations.HeadOverlays[overlayID] = {
                ["Value"] = overlayValue,
                ["ColorType"] = colorType,
                ["FirstColor"] = firstColor,
                ["SecondColor"] = secondColor,
                ["Opacity"] = overlayOpacity
            }
        end
    end
    
    for faceFeatureIndex = 0,19 do
        pedVariations.FaceFeatures[faceFeatureIndex] = GetPedFaceFeature(ped, faceFeatureIndex)
    end
    for propIndex = 0,7 do
        local prop = GetPedPropIndex(ped, propIndex)
        local propTexture = GetPedPropTextureIndex(ped, propIndex)
        pedVariations.Props[propIndex] = {
            ["Prop"] = prop,
            ["PropTexture"] = propTexture
        }
    end
    for componentID = 0,11 do
        local drawableVariation = GetPedDrawableVariation(ped, componentID)
        local textureVariation = GetPedTextureVariation(ped, componentID)
        local paletteVariation = GetPedPaletteVariation(ped, componentID)
        pedVariations.Components[componentID] = {
            ["DrawableVariation"] = drawableVariation,
            ["TextureVariation"] = textureVariation,
            ["PaletteVariation"] = paletteVariation
        }
    end
    return pedVariations
end

function setPedVariations(ped, pedVariations)
    SetPedHeadBlendData(ped, pedVariations.HeadBlend)
    SetPedEyeColor(ped, pedVariations.EyeColor)
    SetPedHairColor(ped, pedVariations.HairColor, pedVariations.HairHighlightColor)
    for propIndex, propInfo in pairs(pedVariations.Props) do
        SetPedPropIndex(ped, propIndex, propInfo.Prop, propInfo.PropTexture, true)
    end
    for componentID, component in pairs(pedVariations.Components) do
        SetPedComponentVariation(ped, componentID, component.DrawableVariation, component.TextureVariation, component.PaletteVariation)
    end
    for overlayID, headOverlay in pairs(pedVariations.HeadOverlays) do
        SetPedHeadOverlay(ped, overlayID, headOverlay.Value, headOverlay.Opacity)
        SetPedHeadOverlayColor(ped, overlayID, headOverlay.ColorType, headOverlay.FirstColor, headOverlay.SecondColor)
    end
    for faceFeatureIndex, faceFeatureValue in pairs(pedVariations.FaceFeatures) do
        SetPedFaceFeature(ped, faceFeatureIndex, faceFeatureValue)
    end
end

function recreatePed(ped, newPed)
    local isReplacing = true
    if not newPed then
        isReplacing = false
        newPed = CreatePed(true, GetEntityModel(ped), GetEntityCoords(PlayerPedId()).xyz, GetEntityHeading(PlayerPedId()), true, true)
        SetEntityAsMissionEntity(newPed, true, true)
    end
    setPedVariations(newPed, getPedVariations(ped))
    
    SetEntityCoordsNoOffset(newPed, GetEntityCoords(PlayerPedId()).xyz)
    if not isReplacing then
        local pedVehicle, seatIndex = getPedVehicle(ped)
        if pedVehicle then
            SetEntityCoords(ped, GetEntityCoords(ped)+vector3(0,0,-50))
            SetPedIntoVehicle(newPed, pedVehicle, seatIndex)
            if IsPedInAnyPlane(newPed) then
                TaskVehicleDriveToCoordLongrange(newPed, pedVehicle, 1403.0020751953, 2995.9179, 40.5507, GetVehicleModelMaxSpeed(GetEntityModel(pedVehicle)), 16777216, 0.0)
            else
                TaskVehicleDriveWander(newPed, pedVehicle, 60.0, 786603)
            end
        else
            TaskWanderStandard(newPed, 10.0, 10)
        end
    end
    return newPed
end

function getDirectionVectorFromHeading(heading, pitch)
    heading = heading-270
    pitch = pitch
    return vector3(math.cos(math.rad(heading))*math.cos(math.rad(pitch)), math.sin(math.rad(heading))*math.cos(math.rad(pitch)), math.sin(math.rad(pitch)))
end
function createCamForPed(ped)
    RequestCollisionAtCoord(GetEntityCoords(ped).xyz)
    local pitch, heading, zoom = GetGameplayCamRelativePitch(), GetGameplayCamRot().z, -4.25
    local forwardVector, rightVector, upVector = GetEntityMatrix(ped)
    local camVector = getDirectionVectorFromHeading(heading, pitch)
    local headPos = GetEntityCoords(ped)+vector3(0,0,0.55)+(getDirectionVectorFromHeading(heading+90, 0)*-0.5)--GetPedBoneCoords(ped, 0x796E)
    --local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetGameplayCamCoord(), GetGameplayCamRelativePitch(), 0, GetGameplayCamRot().z, GetGameplayCamFov() * 1.0)
    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", headPos+(camVector*zoom), pitch, 0, heading, GetGameplayCamFov() * 1.0)
    return cam
end
function dot(coord1, coord2)
    return coord1.x*coord2.x+coord1.y*coord2.y
end
function cross(coord1, coord2)
    return coord1.x*coord2.y-coord1.y*coord2.x;
end
function getAngleBetweenCoords(coord1, coord2)
    return math.atan2(cross(coord1,coord2), dot(coord1,coord2))
end
function drawThing(coords)
    DrawBox(coords-0.5, coords+0.5, 255, 0, 0, 255)
end
local Keys = {}
function Keys.Register(Controls, ControlName, Description, Action)
    RegisterKeyMapping(string.format('keys-%s', ControlName), Description, "keyboard", Controls)
    RegisterCommand(string.format('keys-%s', ControlName), function()
        if (Action ~= nil) then
            Action();
        end
    end, false)
end
function getEntityAimingAt()
    local _, freeAimEntity = GetEntityPlayerIsFreeAimingAt(PlayerId()) 
    if IsEntityAPed(freeAimEntity) or IsEntityAVehicle(freeAimEntity) and not isPlayerPed(entity) then
        return freeAimEntity
    elseif Config.UseLookDirection then
        local camForwardVector = getDirectionVectorFromHeading(GetGameplayCamRot().z, GetGameplayCamRot().x)
        local pedOrVehicle = IsPedInAnyVehicle(PlayerPedId()) and GetVehiclePedIsIn(PlayerPedId()) or PlayerPedId()
        local i = StartShapeTestCapsule((GetGameplayCamCoord()+(camForwardVector*5)).xyz, (GetGameplayCamCoord()+(camForwardVector*1000.0)).xyz, Config.LookRayRadius, 10, pedOrVehicle, 7)
        local a, hit, endCoords,surface, material,entity = GetShapeTestResultIncludingMaterial(i)
        if hit and DoesEntityExist(entity) and not isPlayerPed(entity) then
            return entity
        end
    end
    return false
end
local vehiclesToExcludeFromDeletion = {}
local lastSwitch = GetGameTimer()
local cameraTweenTime = 0
local _, group1Hash = AddRelationshipGroup("group1")
local _, group2Hash = AddRelationshipGroup("group2")
SetRelationshipBetweenGroups(0, group1Hash, group2Hash)
local originalPedModel
TriggerServerEvent("DalraeTakeControl:SendPermissions")
RegisterNetEvent("DalraeTakeControl:RecievePermissions", function(canUse)
    if canUse then
        if not Config.SpawnAsCurrentPed then
            if Config.UseBaseEvents then
                RegisterNetEvent("baseevents:onPlayerDied", function()
                    if originalPedModel then
                        repeat Wait(0) until not IsEntityDead(PlayerPedId())
                        setPedModel(originalPedModel.ModelHash)
                        setPedVariations(originalPedModel.Variations)
                    end
                end)
                RegisterNetEvent("baseevents:onPlayerKilled", function()
                    if originalPedModel then
                        repeat Wait(0) until not IsEntityDead(PlayerPedId())
                        setPedModel(originalPedModel.ModelHash)
                        setPedVariations(originalPedModel.Variations)
                    end
                end)
            else
                local deathDeb = false
                CreateThread(function()
                    while true do
                        Wait(100)
                        if IsEntityDead(PlayerPedId()) then
                            if deathDeb then
                                deathDeb = false
                                if originalPedModel then
                                    repeat Wait(0) until not IsEntityDead(PlayerPedId())
                                    setPedModel(originalPedModel.ModelHash)
                                    setPedVariations(originalPedModel.Variations)
                                end
                            end
                        else
                            deathDeb = true
                        end
                    end
                end)
            end
        end
        local switchedPeds = false
        Keys.Register('LCONTROL', 'LCONTROL', 'Control A Ped', function()
            CreateThread(function()
                if not switchedPeds then
                    originalPedModel = {
                        ["ModelHash"] = GetEntityModel(PlayerPedId()), 
                        ["Variations"] = getPedVariations(PlayerPedId())
                    }
                    RequestModel(originalPedModel.ModelHash) -- To keep the ped in ram
                end
                switchedPeds = true
                local cooldown = (GetGameTimer()-lastSwitch) - (cameraTweenTime+Config.SwitchDelay)
                if cooldown >= 0 then
                    for veh in EnumerateVehicles() do
                        if not IsVehicleSeatFree(veh, -1) and not isPlayerPed(GetPedInVehicleSeat(veh, -1)) then
                            SetEntityAsMissionEntity(veh, true, true)
                        elseif IsVehicleSeatFree(veh, -1)  then
                            SetEntityAsNoLongerNeeded(veh)
                            if GetEntityPopulationType(veh) == 5 then
                                DeleteEntity(veh)
                            end
                        end
                    end
                    local entity = getEntityAimingAt()
                    --Is the entity a ped, or a vehicle with a driver, or is the player not free aiming
                    if (entity and DoesEntityExist(entity) and (IsEntityAPed(entity) or IsEntityAVehicle(entity) and not IsVehicleSeatFree(entity, -1)) or not IsPlayerFreeAiming(PlayerId())) then
                        local ped
                        if IsEntityAVehicle(entity) then
                            if not Config.CanAimAtVehicles then
                                return
                            end
                            if GetPedInVehicleSeat(entity, -1) then
                                ped = GetPedInVehicleSeat(entity, -1)
                            end
                        elseif IsEntityAPed(entity) then
                            ped = entity
                        end
                        if not DoesEntityExist(ped) then
                            ped = getRandomPed()
                        end
                        
                        if DoesEntityExist(ped) and not isPlayerPed(ped) then
                            lastSwitch = GetGameTimer()
                            local vector1 = GetGameplayCamCoord()
                            local vector2 = GetEntityCoords(PlayerPedId())
                            recreatePed(PlayerPedId())
                            RenderScriptCams(false, false, 0, true, false)
                            local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetGameplayCamCoord(), GetGameplayCamRelativePitch(), 0, GetGameplayCamRot().z, GetGameplayCamFov() * 1.0)
                            SetCamActive(cam, true)
                            RenderScriptCams(true, false, 4000, true, false)
                            CreateThread(function()
                                local startTimer = GetGameTimer()
                                while GetGameTimer()-startTimer < cameraTweenTime do
                                    Wait(0)
                                    DisableControlAction(0,1,true)
                                    DisableControlAction(0,2,true)
                                end
                            end)
                            
                            Wait(1)
                            cameraTweenTime = math.floor(GetDistanceBetweenCoords(vector2, GetEntityCoords(ped)))*20
                            if cameraTweenTime > 4000 then cameraTweenTime = 4000 end
                            if cameraTweenTime < 700 then cameraTweenTime = 700 end
                            setPedModel(GetEntityModel(ped))
                            recreatePed(ped, PlayerPedId())
                            local pedVehicle, seatIndex = getPedVehicle(ped)
                            if pedVehicle then
                                if seatIndex == 0 then
                                    SetPedRelationshipGroupHash(PlayerPedId(), group1Hash)
                                    SetPedRelationshipGroupHash(GetPedInVehicleSeat(pedVehicle, -1), group2Hash)
                                end
                                DeleteEntity(ped) --[[ To make it look good on invoking player ]]
                                TriggerServerEvent("DalraeTakeControl:DeleteEntity", NetworkGetNetworkIdFromEntity(ped))
                                SetPedIntoVehicle(PlayerPedId(), pedVehicle, seatIndex)
                            else
                                SetEntityCoordsNoOffset(PlayerPedId(), GetEntityCoords(ped).xyz)
                                SetEntityVelocity(PlayerPedId(), GetEntityVelocity(ped).xyz)
                                SetEntityHeading(PlayerPedId(), GetEntityHeading(ped))
                                DeleteEntity(ped) --[[ To make it look good on invoking player ]]
                                TriggerServerEvent("DalraeTakeControl:DeleteEntity", NetworkGetNetworkIdFromEntity(ped))
                            end
                            RenderScriptCams(false, true, cameraTweenTime, true, false)
                            SetCamActive(cam, false)
                            DestroyCam(cam)
                            GiveWeaponToPed(PlayerPedId(), GetHashKey("WEAPON_PISTOL"), 100, false, true)
                            FreezeEntityPosition(PlayerPedId(), false)
                        else
                            TriggerEvent("chatMessage", "^*^8No available peds are around you.")
                        end
                    end
                elseif Config.ShowWarningWhenCooldown then
                    TriggerEvent("chatMessage", "^*^8You need to wait "..math.abs(cooldown).." ms before switching peds again.")
                end
            end)
        end)
    end
end)

AddEventHandler("onResourceStop", function(name)
    if name == GetCurrentResourceName() then
        if originalPedModel then
            setPedModel(originalPedModel.ModelHash)
            setPedVariations(originalPedModel.Variations)
        end
    end
end)
