local securedEntities = {} 

local function GetClosestCarrierVehicle(entity, radius)
    local coords = GetEntityCoords(entity)
    local vehicles = GetGamePool('CVehicle')
    local closestDistance = radius
    local closestVehicle = 0

    for _, vehicle in ipairs(vehicles) do
        if vehicle ~= entity then
            local vehCoords = GetEntityCoords(vehicle)
            local distance = #(coords - vehCoords)
            if distance < closestDistance then
                closestDistance = distance
                closestVehicle = vehicle
            end
        end
    end
    return closestVehicle
end

-- Command: /freezee
RegisterCommand("freezee", function()
    local playerPed = PlayerPedId()
    local targetEntity = IsPedInAnyVehicle(playerPed, false) and GetVehiclePedIsIn(playerPed, false) or playerPed
    
    if securedEntities[targetEntity] then
        TriggerEvent("chat:addMessage", { args = { "^1ERROR", "This object is already secured!" } })
        return
    end
    
    local carrierVehicle = GetClosestCarrierVehicle(targetEntity, 15.0)
    if carrierVehicle == 0 then
        TriggerEvent("chat:addMessage", { args = { "^1ERROR", "No carrier vehicle nearby (15m radius)!" } })
        return
    end
    
    local targetCoords = GetEntityCoords(targetEntity)
    local targetRot = GetEntityRotation(targetEntity, 2)
    local carrierRot = GetEntityRotation(carrierVehicle, 2)
    
    local offset = GetOffsetFromEntityGivenWorldCoords(carrierVehicle, targetCoords.x, targetCoords.y, targetCoords.z)
    local rotOffset = vector3(0.0, 0.0, targetRot.z - carrierRot.z)
    
    AttachEntityToEntity(targetEntity, carrierVehicle, 0, offset.x, offset.y, offset.z, rotOffset.x, rotOffset.y, rotOffset.z, false, false, true, false, 2, true)
    
    securedEntities[targetEntity] = carrierVehicle
    TriggerEvent("chat:addMessage", { args = { "^2SUCCESS", "Object successfully secured!" } })
end, false)

-- Command: /unfreezee
RegisterCommand("unfreezee", function()
    local playerPed = PlayerPedId()
    local targetEntity = IsPedInAnyVehicle(playerPed, false) and GetVehiclePedIsIn(playerPed, false) or playerPed
    
    if securedEntities[targetEntity] then
        DetachEntity(targetEntity, true, false)
        FreezeEntityPosition(targetEntity, false)
        securedEntities[targetEntity] = nil
        TriggerEvent("chat:addMessage", { args = { "^2SUCCESS", "Object released!" } })
    else
        TriggerEvent("chat:addMessage", { args = { "^1ERROR", "No secured object found for this entity!" } })
    end
end, false)