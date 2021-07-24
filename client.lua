-- Created by Dalrae

--[[CONFIG]]
local Config = {}
Config.Debug = false -- Adds debugging info such as: Highlighting entities and number of valid/invalid peds
Config.GivePistol = true -- Give a pistol to the ped after switching.
Config.EquipPistol = true -- Automatically equips the pistol for the above config value.

Config.RandomSwitchingExcludeAnimals = true -- Excludes animals from being switched to if the player is not aiming/looking at a ped.
Config.SpawnAsCurrentPed = true -- Spawns as the player's current ped. Disable to make them switch back to their original ped.
Config.UseBaseEvents = false -- Use the "baseevents" resource for detecting if a player died.

Config.UseLookDirection = true -- Use the camera direction if the player is not aiming with a gun.
Config.LookRayRadius = 1.0 -- The radius to use for the UseLookDirection config value.

Config.SwitchDelay = 500 -- Time (ms) to wait until switching peds again.
Config.CanAimAtVehicles = true -- If aiming at a vehicle, will switch to the driver of that vehicle. Can still aim at a vehicle and be detected as aiming at the driver though.
Config.ShowWarningWhenCooldown = true -- Show a message in chat when a player attempts to switch to a ped too fast.

Config.CanControlPlayers = true -- If attempting to switch peds to a player, it will control that player, probably confusing the shit out of them.
Config.CanRandomlySwitchToPlayers = false -- Pressing ctrl without looking or aiming at a player will let you randomly switch to them.
--[[END CONFIG]]



function setPedModel(modelHash) -- Sets the player's ped model with the original camera position.
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

local allWeapons = {
	--[-1569615261] = "Unarmed",
	[2460120199] = "Antique Cavalry Dagger",
	[2508868239] = "Baseball Bat",
	[4192643659] = "Bottle",
	[2227010557] = "Crowbar",
	[2725352035] = "Fist",
	[2343591895] = "Flashlight",
	[1141786504] = "Golf Club",
	[1317494643] = "Hammer",
	[4191993645] = "Hatchet",
	[3638508604] = "Knuckle",
	[2578778090] = "Knife",
	[3713923289] = "Machete",
	[3756226112] = "Switchblade",
	[1737195953] = "Nightstick",
	[419712736] = "Pipe Wrench",
	[3441901897] = "Battle Axe",
	[2484171525] = "Pool Cue",
	[940833800] = "Stone Hatchet",
	[453432689] = "Pistol",
	[3219281620] = "Pistol MK2",
	[1593441988] = "Combat Pistol",
	[584646201] = "AP Pistol",
	[911657153] = "Stun Gun",
	[2578377531] = "Pistol .50",
	[3218215474] = "SNS Pistol",
	[2285322324] = "SNS Pistol MK2",
	[3523564046] = "Heavy Pistol",
	[137902532] = "Vintage Pistol",
	[1198879012] = "Flare Gun",
	[3696079510] = "Marksman Pistol",
	[3249783761] = "Heavy Revolver",
	[3415619887] = "Heavy Revolver MK2",
	[2548703416] = "Double Action",
	[2939590305] = "Up-n-Atomizer",
	[324215364] = "Micro SMG",
	[736523883] = "SMG",
	[2024373456] = "SMG MK2",
	[4024951519] = "Assault SMG",
	[171789620] = "Combat PDW",
	[3675956304] = "Machine Pistol",
	[3173288789] = "Mini SMG",
	[1198256469] = "Unholy Hellbringer",
	[487013001] = "Pump Shotgun",
	[1432025498] = "Pump Shotgun MK2",
	[2017895192] = "Sawed-Off Shotgun",
	[3800352039] = "Assault Shotgun",
	[2640438543] = "Bullpup Shotgun",
	[2828843422] = "Musket",
	[984333226] = "Heavy Shotgun",
	[4019527611] = "Double Barrel Shotgun",
	[317205821] = "Sweeper Shotgun",
	[3220176749] = "Assault Rifle",
	[961495388] = "Assault Rifle MK2",
	[2210333304] = "Carbine Rifle",
	[4208062921] = "Carbine Rifle MK2",
	[2937143193] = "Advanced Rifle",
	[3231910285] = "Special Carbine",
	[2526821735] = "Special Carbine MK2",
	[2132975508] = "Bullpup Rifle",
	[2228681469] = "Bullpup Rifle MK2",
	[1649403952] = "Compact Rifle",
	[2634544996] = "MG",
	[2144741730] = "Combat MG",
	[3686625920] = "Combat MG MK2",
	[1627465347] = "Gusenberg Sweeper",
	[100416529] = "Sniper Rifle",
	[205991906] = "Heavy Sniper",
	[177293209] = "Heavy Sniper MK2",
	[3342088282] = "Marksman Rifle",
	[1785463520] = "Marksman Rifle MK2",
	[2982836145] = "RPG",
	[2726580491] = "Grenade Launcher",
	[1305664598] = "Smoke Grenade Launcher",
	[1119849093] = "Minigun",
	[2138347493] = "Firework Launcher",
	[1834241177] = "Railgun",
	[1672152130] = "Homing Launcher",
	[125959754] = "Compact Grenade Launcher",
	[3056410471] = "Ray Minigun",
	[2481070269] = "Grenade",
	[2694266206] = "BZ Gas",
	[4256991824] = "Smoke Grenade",
	[1233104067] = "Flare",
	[615608432] = "Molotov",
	[741814745] = "Sticky Bomb",
	[2874559379] = "Proximity Mine",
	[126349499] = "Snowball",
	[3125143736] = "Pipe Bomb",
	[600439132] = "Baseball",
	[883325847] = "Jerry Can",
	[101631238] = "Fire Extinguisher",
	[4222310262] = "Parachute"
}

local weaponComponents = {
    ["MK2PistolRegularClip"] = 0x94F42D62,
    ["MK2PistolExtendedClip"] = 0x5ED6C128,
    ["MK2PistolFlashLight"] = 0x43FD595B,
    ["MK2PistolMountedScope"] = 0x8ED4BB70,
    ["MK2PistolCompensator"] = 0x21E34793,
    ["MK2SmgExtendedClip"] = 0xB9835B2E,
    ["MK2SmgSmallScope"] = 0x3DECC7DA,
    ["MK2SmgMediumScope"] = 0xE502AB6B,
    ["MK2SmgRegularBarrel"] = 0xD9103EE1,
    ["MK2SmgHeavyBarrel"] = 0xA564D78B,
    ["MK2SmgHoloSight"] = 0x9FDB5652,
    ["MK2AssaultRifleHoloSight"] = 0x420FD713,
    ["MK2AssaultRifleRegularClip"] = 0x8610343F,
    ["MK2AssaultRifleExtendedClip"] = 0xD12ACA6F,
    ["MK2AssaultRifleGrip"] = 0x9D65907A,
    ["MK2AssaultRifleSmallScope"] = 0x049B2945,
    ["MK2AssaultRifleMediumScope"] = 0xC66B6542,
    ["MK2AssaultRifleRegularBarrel"] = 0x43A49D26,
    ["MK2AssaultRifleHeavyBarrel"] = 0x5646C26A,
    ["MK2CarbineRifleRegularClip"] = 0x4C7A391E,
    ["MK2CarbineRifleExtendedClip"] = 0x5DD5DBD5,
    ["MK2CarbineRifleRegularBarrel"] = 0x833637FF,
    ["MK2CarbineRifleHeavyBarrel"] = 0x8B3C480B,
    ["MK2CombatMgRegularClip"] = 0x492B257C,
    ["MK2CombatMgExtendedClip"] = 0x17DF42E9,
    ["MK2CombatMgRegularBarrel"] = 0xC34EF234,
    ["MK2CombatMgHeavyBarrel"] = 0xB5E2575B,
    ["MK2SniperRegularClip"] = 0xFA1E1A28,
    ["MK2SniperExtendedClip"] = 0x2CD8FF9D,
    ["MK2SniperScopeLarge"] = 0x82C10383,
    ["MK2SniperScopeNightVision"] = 0xB68010B0,

    ["MK2SniperScopeThermal"] = 0x2E43DA41,
    ["MK2SniperSuppressor"] = 0xAC42DF71,
    ["MK2SniperRegularBarrel"] = 0x909630B7,
    ["MK2SniperHeavyBarrel"] = 0x108AB09E,
    ["MachinePistolRegularClip"] = 0x476E85FF,
    ["MachinePistolExtended"] = 0xB92C6979,
    ["CompactRifleRegularClip"] = 0x513F0A63,
    ["CompactRifleExtendedClip"] = 0x59FF9BF8,
    ["AdvancedSniperScope"] = 0xBC54DA77,
    ["AP_PistolExtendedClip"] = 0x249A17D5,
    ["HeavyPistolExtendedClip"] = 0x64F9C62B,
    ["S_N_S_PistolRegularClip"] = 0xF8802ED9,
    ["S_N_S_PistolExtendedClip"] = 0x7B0033B3,
    ["S_N_S_PistolEtchedWoodGrip"] = 0x8033ECAF,
    ["SpecialCarbineExtendedClip"] = 0x7C8BD10E,
    ["AssaultShotgunExtendedClip"] = 0x86BD7F72,
    ["AdvancedRifleExtendedClip"] = 0x8EC1C979,
    ["BullpupRifleExtendedClip"] = 0xB3688B0F,
    ["CombatM_G_ExtendedClip"] = 0xD6C59CD6,
    ["PistolExtendedClip"] = 0xED265A1C,
    ["CombatPistolExtendedClip"] = 0xD67B4F2D,
    ["point50PistolExtendedClip"] = 0xD9D3AC92,
    ["VintagePistolRegularClip"] = 0x45A3B6BB,
    ["VintagePistolExtendedClip"] = 0x33BA12E8,
    ["MicroS_M_G_ExtendedClip"] = 0x10E6BA2B,
    ["S_M_G_ExtendedClip"] = 0x350966FB,
    ["AssaultS_M_G_ExtendedClip"] = 0xBB46E417,
    ["CombatP_D_W_RegularClip"] = 0x4317F19E,
    ["CombatP_D_W_ExtendedClip"] = 0x334A5203,
    ["M_G_ExtendedClip"] = 0x82158B47,
    ["GusenbergRegularClip"] = 0x1CE5A6A5,
    ["GusenbergExtendedClip"] = 0xEAC8C270,
    ["AssaultRifleExtendedClip"] = 0xB1214F9B,
    ["CarbineRifleExtendedClip"] = 0x91109691,
    ["MarksmanRifleExtendedClip"] = 0xCCFD2AC5,
    ["HeavyShotgunRegularClip"] = 0x324F2D5F,
    ["HeavyShotgunExtendedClip"] = 0x971CF6FD,
    ["Pistol_Micro_S_M_G_Flashlight"] = 0x359B7AAE,
    ["RifleShotgunFlashlight"] = 0x7BC4CDDC,

    ["RifleShotgunGrip"] = 0xC164F53,
    ["BullpupRifleRegularClip"] = 0xC5A12F80,
    ["SpecialCarbineRegularClip"] = 0xC6C7E581,
    ["HeavyPistolRegularClip"] = 0xD4A969A,
    ["CombatM_G_RegularClip"] = 0xE1FFB34A,
    ["MicroS_M_G_RifleScope"] = 0x9D2FBF29,
    ["Carbine_Combat_M_G_Scope"] = 0xA0D89C42,
    ["P_D_W_Rifle_Grenade_Scope"] = 0xAA2C45B4,
    ["SniperScope"] = 0xD2443DDC,
    ["S_M_G_Scope"] = 0x3CC6BA57,
    ["M_G_Scope"] = 0x3C00AFED,
    ["PistolSupressor"] = 0x65EA7EBB,
    ["Rifle_ShotgunSuppressor"] = 0x837445AA,
    ["point50Pistol_MicroS_M_G_Assault_S_M_G_Rifle_Suppressor"] = 0xA73D4664,
    ["Combat_A_P_Heavy_VintagePistol_Suppressor"] = 0xC304849A,
    ["PumpShotgunSuppressor"] = 0xE608B35E,
    ["SMG_YusufAmirFinish"] = 0x27872C90,
    ["Pistol_YusufAmirFinish"] = 0xD7391086,
    ["AP_Pistol_GildedGunMetalFinish"] = 0x9B76C72C,
    ["MicroSMG_YusufAmirFinish"] = 0x487AAE09,
    ["SawnOffShotgun_GildedGunMetalFinish"] = 0x85A64DF9,
    ["AdvancedRifle_GildedGunMetalFinish"] = 0x377CD377,
    ["CarbineRifle_YusufAmirFinish"] = 0xD89B9658,
    ["AssaultRifle_YusufAmirFinish"] = 0x4EAD7533,
    ["SniperRifle_EtchedWoodGripFinish"] = 0x4032B5E7,
    ["point50Pistol_PlatinumPearlDeluxeFinish"] = 0x77B8AB2F,
    ["HeavyPistol_EtchedWoodGripFinish"] = 0x7A6A7B7B,
    ["MarksmanRifle_YusufAmirFinish"] = 0x161E9241,
    ["SniperRifleUnknown"] = 0x9BC64089,
    ["MiniSMGRegularClip"] = 0x84C8B2D3,
    ["MiniSMGExtendedClip"] = 0x937ED0B7,
    ["RevolverBoss"] = 0x16EE3040,
    ["RevolverGoon"] = 0x9493B80D,
    ["KnuckleDusterPlain"] = 0xF3462F33,
    ["KnuckleDusterPimp"] = 0xC613F685,
    ["KnuckleDusterBallas"] = 0xEED9FD63,
    ["KnuckleDusterDollar"] = 0x50910C31,
    ["KnuckleDusterDiamond"] = 0x9761D9DC,
    ["KnuckleDusterHate"] = 0x7DECFE30,
    ["KnuckleDusterLove"] = 0x3F4E8AA6,
    ["KnuckleDusterPlayer"] = 0x8B808BB,
    ["KnuckleDusterKing"] = 0xE28BABEF,
    ["KnuckleDusterVago"] = 0x7AF3F785,
    ["SwitchBladeBase"] = 0x9137A500,
    ["SwitchBladeMod1"] = 0x5B3E7DB6,
    ["SwitchBladeMod2"] = 0xE7939662
}

local animalPedModels = --[[ Doesn't include water animals since they're quite rare]]
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
            return player
        end
    end
    return false
end

function getRandomPed()
    local numPeds = 0
    for ped in EnumeratePeds() do
        RequestCollisionAtCoord(GetEntityCoords(ped).xyz)
        if GetEntityCoords(ped).x ~= 0 and GetEntityCoords(ped).y ~= 0 and GetEntityCoords(ped).y ~= 0 and GetEntityCoords(ped).z ~= -100 and (not isPlayerPed(ped) or Config.CanControlPlayers and Config.CanRandomlySwitchToPlayers) and ped ~= PlayerPedId() and (Config.RandomSwitchingExcludeAnimals and not isAnimalPed(ped)) and GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(ped)) < 200 then
            numPeds = numPeds+1
        end
    end
    if numPeds > 0 then
        local stopAt = math.random(1,numPeds)
        local curPed = 0
        chosenPed = nil
        for ped in EnumeratePeds() do
            if GetEntityCoords(ped).x ~= 0 and GetEntityCoords(ped).y ~= 0 and GetEntityCoords(ped).y ~= 0 and GetEntityCoords(ped).z ~= -100 and (not isPlayerPed(ped) or Config.CanControlPlayers and Config.CanRandomlySwitchToPlayers) and ped ~= PlayerPedId() and  (Config.RandomSwitchingExcludeAnimals and not isAnimalPed(ped)) and GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(ped)) < 200 then
                curPed = curPed+1
                if curPed == stopAt then
                    return ped
                end
            end
        end
    end
    return false
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

function getPedWeapons(ped, excludePistol)
    local pedWeapons = {}
    for weaponHash, weaponName in pairs(allWeapons) do
        if HasPedGotWeapon(ped, weaponHash) then
            if not (excludePistol and weaponHash == GetHashKey("WEAPON_PISTOL")) then
                table.insert(pedWeapons, {
                    ["Hash"] = weaponHash,
                    ["Name"] = weaponName,
                    ["Ammo"] = GetAmmoInPedWeapon(ped, weaponHash),
                    ["ClipAmmo"] = GetAmmoInClip(ped, weaponHash),
                    ["TintIndex"] = GetPedWeaponTintIndex(ped, weaponHash),
                    ["Components"] = {}
                })
            end
        end
    end
    for i,weapon in pairs(pedWeapons) do
        for _,componentHash in pairs(weaponComponents) do
            if DoesWeaponTakeWeaponComponent(weapon.Hash, componentHash) and IsPedWeaponComponentActive(ped, weapon.Hash, componentHash) then
                table.insert(pedWeapons[i].Components, {
                    ["Hash"] = componentHash
                })
            end
        end
    end
    return pedWeapons
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

function giveWeaponsToPed(ped, weapons)
    for _,weapon in pairs(weapons) do
        GiveWeaponToPed(ped, weapon.Hash)
        SetPedAmmo(ped, weapon.Hash, weapon.Ammo)
        SetAmmoInClip(ped, weapon.Hash, weapon.ClipAmmo)
        for _,component in pairs(weapon.Components) do
            GiveWeaponComponentToPed(ped, weapon.Hash, component.Hash)
        end
    end
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
        newPed = CreatePed(true, GetEntityModel(ped), GetEntityCoords(ped).xyz, GetEntityHeading(ped), true, true)
        SetEntityAsMissionEntity(newPed, true, true)
    end
    SetEntityHealth(newPed, GetEntityHealth(ped))
    giveWeaponsToPed(newPed, getPedWeapons(ped, didntHavePistol))
    setPedVariations(newPed, getPedVariations(ped))
    
    SetEntityCoordsNoOffset(newPed, GetEntityCoords(ped).xyz)
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
    if IsEntityAPed(freeAimEntity) or IsEntityAVehicle(freeAimEntity) and (not isPlayerPed(entity) or Config.CanControlPlayers) then
        return freeAimEntity
    elseif Config.UseLookDirection then
        local camForwardVector = getDirectionVectorFromHeading(GetGameplayCamRot().z, GetGameplayCamRot().x)
        local pedOrVehicle = IsPedInAnyVehicle(PlayerPedId()) and GetVehiclePedIsIn(PlayerPedId()) or PlayerPedId()
        local i = StartShapeTestCapsule((GetGameplayCamCoord()+(camForwardVector*5)).xyz, (GetGameplayCamCoord()+(camForwardVector*1000.0)).xyz, Config.LookRayRadius, 10, pedOrVehicle, 7)
        local a, hit, endCoords,surface, material,entity = GetShapeTestResultIncludingMaterial(i)
        if hit and DoesEntityExist(entity) and (not isPlayerPed(entity) or Config.CanControlPlayers) then
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
                        setPedVariations(PlayerPedId(), originalPedModel.Variations)
                    end
                end)
                RegisterNetEvent("baseevents:onPlayerKilled", function()
                    if originalPedModel then
                        repeat Wait(0) until not IsEntityDead(PlayerPedId())
                        setPedModel(originalPedModel.ModelHash)
                        setPedVariations(PlayerPedId(), originalPedModel.Variations)
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
                                    setPedVariations(PlayerPedId(), originalPedModel.Variations)
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
        local isControllingPlayer = false
        Keys.Register('LCONTROL', 'LCONTROL', 'Control A Ped', function()
            CreateThread(function()
                if not switchedPeds then
                    originalPedModel = {
                        ["ModelHash"] = GetEntityModel(PlayerPedId()), 
                        ["Variations"] = getPedVariations(PlayerPedId()),
                        ["Weapons"] = getPedWeapons(PlayerPedId())
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
                        
                        if DoesEntityExist(ped) and (not isPlayerPed(ped) or Config.CanControlPlayers) then
                            
                            lastSwitch = GetGameTimer()
                            local vector1 = GetGameplayCamCoord()
                            local vector2 = GetEntityCoords(PlayerPedId())
                            if not isControllingPlayer then
                                recreatePed(PlayerPedId())
                            else
                                TriggerServerEvent("DalraeTakeControl:StopTakeControlPlayer")
                            end

                            if isPlayerPed(ped) then
                                isControllingPlayer = true
                            else
                                isControllingPlayer = false
                            end
                            
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
                            setPedVariations(PlayerPedId(), getPedVariations(ped))
                            SetEntityHealth(PlayerPedId(), GetEntityHealth(ped))
                            giveWeaponsToPed(PlayerPedId(), getPedWeapons(ped))
                            if isControllingPlayer then
                                local pedVehicle, seatIndex = getPedVehicle(ped)
                                TriggerServerEvent("DalraeTakeControl:TakeControlPlayer", GetPlayerServerId(isPlayerPed(ped)), NetworkGetNetworkIdFromEntity(pedVehicle), seatIndex)
                            else
                                recreatePed(ped, PlayerPedId())
                            end
                            local pedVehicle, seatIndex = getPedVehicle(ped)
                            if pedVehicle then
                                if seatIndex == 0 then
                                    SetPedRelationshipGroupHash(PlayerPedId(), group1Hash)
                                    SetPedRelationshipGroupHash(GetPedInVehicleSeat(pedVehicle, -1), group2Hash)
                                end
                                if not isControllingPlayer then
                                    DeleteEntity(ped) --[[ To make it look good on invoking player ]]
                                    TriggerServerEvent("DalraeTakeControl:DeleteEntity", NetworkGetNetworkIdFromEntity(ped))
                                    SetPedIntoVehicle(PlayerPedId(), pedVehicle, seatIndex)
                                end
                            else
                                SetEntityCoordsNoOffset(PlayerPedId(), GetEntityCoords(ped).xyz)
                                SetEntityVelocity(PlayerPedId(), GetEntityVelocity(ped).xyz)
                                SetEntityHeading(PlayerPedId(), GetEntityHeading(ped))
                                if not isControllingPlayer then
                                    DeleteEntity(ped) --[[ To make it look good on invoking player ]]
                                    TriggerServerEvent("DalraeTakeControl:DeleteEntity", NetworkGetNetworkIdFromEntity(ped))
                                end
                            end
                            RenderScriptCams(false, true, cameraTweenTime, true, false)
                            SetCamActive(cam, false)
                            DestroyCam(cam)
                            if Config.GivePistol and not isAnimalPed(PlayerPedId()) then
                                didntHavePistol = not HasPedGotWeapon(PlayerPedId(), GetHashKey("WEAPON_PISTOL"))
                                GiveWeaponToPed(PlayerPedId(), GetHashKey("WEAPON_PISTOL"), 100, false, Config.EquipPistol)
                            end
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

RegisterNetEvent("DalraeTakeControl:PutInVehicle", function(vehicleNet, seatIndex)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNet)
    repeat Wait(0) until not DoesEntityExist(GetPedInVehicleSeat(vehicle, seatIndex))
    SetPedIntoVehicle(PlayerPedId(), vehicle, seatIndex)
end)

RegisterNetEvent("DalraeTakeControl:TakeControlPlayer", function(player)
    for _,playerC in pairs(GetActivePlayers()) do
        if tonumber(GetPlayerServerId(playerC)) == tonumber(player) then
            player = playerC
            break
        end
    end
    if player and DoesEntityExist(GetPlayerPed(player)) then
        local playerPed = GetPlayerPed(player)
        local oldPlayerModel = GetEntityModel(playerPed)
        local oldCamRot = GetGameplayCamRot()
        local vehicle, seat = getPedVehicle(playerPed)
        NetworkSetInSpectatorMode(true, playerPed)
        SetGameplayCamRawPitch(oldCamRot.x)
        SetGameplayCamRawYaw(oldCamRot.z)
        SetEntityCoordsNoOffset(PlayerPedId(), vector3(0,0,1000))
        CreateThread(function()
            Wait(1000)
            FreezeEntityPosition(PlayerPedId(), true)
        end)
        CreateThread(function()
            local newCoords = GetEntityCoords(GetPlayerPed(player))
            local newCamRot = GetGameplayCamRot()
            repeat Wait(0) until DoesEntityExist(GetPlayerPed(player))
            while DoesEntityExist(GetPlayerPed(player)) and Entity(GetPlayerPed(player)).state.Controlling == GetPlayerServerId(PlayerId()) do
                newCoords = GetEntityCoords(GetPlayerPed(player))
                newCamRot = GetGameplayCamRot()
                vehicle, seat = getPedVehicle(GetPlayerPed(player))
                RequestCollisionAtCoord(GetEntityCoords(GetPlayerPed(player)))
                Wait(20)
            end
            NetworkSetInSpectatorMode(false)
            FreezeEntityPosition(PlayerPedId(), false)
            if DoesEntityExist(vehicle) then
                repeat Wait(0) until not DoesEntityExist(GetPedInVehicleSeat(vehicle, seat))
                SetPedIntoVehicle(PlayerPedId(), vehicle, seat)
            else
                SetEntityCoordsNoOffset(PlayerPedId(), newCoords)
            end
            SetGameplayCamRawPitch(newCamRot.x)
            SetGameplayCamRawYaw(newCamRot.z)
        end)
    end
end)



if Config.Debug then
    local function DrawBoundingBox(box, r, g, b, a)
        local function GetBoundingBoxPolyMatrix(box)
            return {
                { box[3], box[2], box[1] },
                { box[4], box[3], box[1] },

                { box[5], box[6], box[7] },
                { box[5], box[7], box[8] },

                { box[3], box[4], box[7] },
                { box[8], box[7], box[4] },

                { box[1], box[2], box[5] },
                { box[6], box[5], box[2] },

                { box[2], box[3], box[6] },
                { box[3], box[7], box[6] },

                { box[5], box[8], box[4] },
                { box[5], box[4], box[1] }
            }
        end
        local function GetBoundingBoxEdgeMatrix(box)
            return {
                { box[1], box[2] },
                { box[2], box[3] },
                { box[3], box[4] },
                { box[4], box[1] },

                { box[5], box[6] },
                { box[6], box[7] },
                { box[7], box[8] },
                { box[8], box[5] },

                { box[1], box[5] },
                { box[2], box[6] },
                { box[3], box[7] },
                { box[4], box[8] }
            }
        end
        local function DrawPolyMatrix(polyCollection, r, g, b, a)
            for _,poly in pairs(polyCollection) do
                local x1 = poly[1].x
                local y1 = poly[1].y
                local z1 = poly[1].z

                local x2 = poly[2].x
                local y2 = poly[2].y
                local z2 = poly[2].z

                local x3 = poly[3].x
                local y3 = poly[3].y
                local z3 = poly[3].z
                DrawPoly(x1, y1, z1, x2, y2, z2, x3, y3, z3, r, g, b, a)
            end
        end
        local function DrawEdgeMatrix(linesCollection, r, g, b, a)
                for _,line in pairs(linesCollection) do
                    local x1 = line[1].x
                    local y1 = line[1].y
                    local z1 = line[1].z
    
                    local x2 = line[2].x
                    local y2 = line[2].y
                    local z2 = line[2].z
    
                    DrawLine(x1, y1, z1, x2, y2, z2, r, g, b, a)
                end
            end
        local polyMatrix = GetBoundingBoxPolyMatrix(box)
        local edgeMatrix = GetBoundingBoxEdgeMatrix(box)
        DrawPolyMatrix(polyMatrix, r, g, b, a)
        DrawEdgeMatrix(edgeMatrix, 255, 255, 255, 255)
    end
    function GetEntityBoundingBox(entity)
        local min, max = GetModelDimensions(GetEntityModel(entity))
        local pad = 0.001
        local retval = {
            -- Bottom
            vector3(GetOffsetFromEntityInWorldCoords(entity, min.x - pad, min.y - pad, min.z - pad)),
            vector3(GetOffsetFromEntityInWorldCoords(entity, max.x + pad, min.y - pad, min.z - pad)),
            vector3(GetOffsetFromEntityInWorldCoords(entity, max.x + pad, max.y + pad, min.z - pad)),
            vector3(GetOffsetFromEntityInWorldCoords(entity, min.x - pad, max.y + pad, min.z - pad)),
            -- Top
            vector3(GetOffsetFromEntityInWorldCoords(entity, min.x - pad, min.y - pad, max.z + pad)),
            vector3(GetOffsetFromEntityInWorldCoords(entity, max.x + pad, min.y - pad, max.z + pad)),
            vector3(GetOffsetFromEntityInWorldCoords(entity, max.x + pad, max.y + pad, max.z + pad)),
            vector3(GetOffsetFromEntityInWorldCoords(entity, min.x - pad, max.y + pad, max.z + pad))
        }
        return retval
    end

    local function drawDebugText(y, text)
        local width, height, x = 1.0, 1.0, 1.0
        SetTextFont(0)
        SetTextProportional(0)
        SetTextScale(0.5, 0.5)
        SetTextColour(255, 0, 0, 255)
        SetTextDropShadow(0, 0, 0, 0,255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(x - width/2, y - height/2 + 0.005)
    end
    local function drawEntityBox(entity, r,g,b,a)
        local max, min = GetModelDimensions(GetEntityModel(entity))
        local dim = max-min
        local entityPosition = GetEntityCoords(entity)
        local boundingBox = GetEntityBoundingBox(entity)
        DrawBoundingBox(boundingBox, r,g,b,a)
    end
    CreateThread(function()
        while true do
            Wait(0)
            local numPedsCan,numPedsCannot, numAnimals = 0,0,0
            local lookingOrAimingAtEntity = getEntityAimingAt()
            for ped in EnumeratePeds() do
                RequestCollisionAtCoord(GetEntityCoords(ped).xyz)
                if GetEntityCoords(ped).x ~= 0 and GetEntityCoords(ped).y ~= 0 and GetEntityCoords(ped).y ~= 0 and GetEntityCoords(ped).z ~= -100 and (not isPlayerPed(ped) or Config.CanControlPlayers and Config.CanRandomlySwitchToPlayers) and ped ~= PlayerPedId() and (Config.RandomSwitchingExcludeAnimals and not isAnimalPed(ped)) and GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(ped)) < 200 then
                    if lookingOrAimingAtEntity == ped then
                        drawEntityBox(ped, 255,255,0,75)
                    else
                        drawEntityBox(ped, 0,255,0,75)
                    end
                    numPedsCan = numPedsCan+1
                else
                    if lookingOrAimingAtEntity == ped then
                        drawEntityBox(ped, 255,100,0,75)
                    else
                        drawEntityBox(ped, 255,0,0,75)
                    end
                    numPedsCannot = numPedsCannot+1
                end
                if isAnimalPed(ped) then
                    numAnimals = numAnimals+1
                end
            end
            if IsEntityAVehicle(lookingOrAimingAtEntity) then
                if Config.CanAimAtVehicles then
                    if DoesEntityExist(GetPedInVehicleSeat(lookingOrAimingAtEntity, -1)) then
                        drawEntityBox(lookingOrAimingAtEntity, 255,255,0,75)
                    else
                        drawEntityBox(lookingOrAimingAtEntity, 200,100,0,75)
                    end
                end
            end
            drawDebugText(0.5, ("#Peds which can be switched to: %s"):format(numPedsCan))
            drawDebugText(0.53, ("#Peds which cannot be switched to: %s"):format(numPedsCannot))
            drawDebugText(0.56, ("# Animal peds: %s"):format(numAnimals))
            
            if lookingOrAimingAtEntity then
                if IsPlayerFreeAiming() then

                end
            end
        end
    end)
end

AddEventHandler("onResourceStop", function(name)
    if name == GetCurrentResourceName() then
        if originalPedModel then
            setPedModel(PlayerPedId(), originalPedModel.ModelHash)
            setPedVariations(PlayerPedId(), originalPedModel.Variations)
            giveWeaponsToPed(PlayerPedId(), originalPedModel.Weapons)
        end
    end
end)
