local AttachedHeadbands = {}

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        DeleteAnimationHeadbandProps()
        ClearPedTasksImmediately(PlayerPedId())
    end
end)

AddEventHandler('playerDropped', function (reason)
    DeleteAnimationHeadbandProps()
end)

function MakeEntityFaceEntity(entity1, entity2)
    local p1 = GetEntityCoords(entity1)
    local p2 = GetEntityCoords(entity2)
    local dx = p2.x - p1.x
    local dy = p2.y - p1.y
    local heading = GetHeadingFromVector_2d(dx, dy)
    SetEntityHeading(entity1, heading)
end

DeleteAnimationHeadbandProps = function()
    for _, v in pairs (AttachedHeadbands) do
		for _, entity in pairs(v.entities) do
			local retval =	DoesEntityExist( entity )
			if retval or retval == 1 then
				DeleteObject(entity)
			end
		end
	end
end

DeleteAnimationHeadbandTypeProps = function(type)
    for k, v in pairs (AttachedHeadbands) do
		if v.type == type then
			for _, entity in pairs(v.entities) do
				Wait(100)
				local retval =	DoesEntityExist( entity )
				if retval or retval == 1 then
					DeleteObject(entity)
				end
			end
			Wait(1000)
			table.remove(AttachedHeadbands, k)
		end
	end
end

RegisterNetEvent('mm_native_headbands:AttachHeadbandTypeOnPlayerPed')
AddEventHandler('mm_native_headbands:AttachHeadbandTypeOnPlayerPed', function(type)
    local foundResult = false
    for _, v in pairs (AttachedHeadbands) do
        if v.type == type then
            foundResult = true
        end
    end
    RequestAnimDict(Config.MultiItemSetList[type].Animations.AnimDict)
    while not HasAnimDictLoaded(Config.MultiItemSetList[type].Animations.AnimDict) do
        Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), Config.MultiItemSetList[type].Animations.AnimDict, Config.MultiItemSetList[type].Animations.AnimLib, 2.0, 2.0, Config.MultiItemSetList[type].Animations.time, Config.MultiItemSetList[type].Animations.flag, 0, 0)
    if foundResult then
        exports.mega_progressbars:DisplayProgressBar(Config.MultiItemSetList[type].Animations.time, "Taking off accessory...")
    else
        exports.mega_progressbars:DisplayProgressBar(Config.MultiItemSetList[type].Animations.time, "Putting on accessory...")
    end
    AttachHeadbandTypeOnPlayerPed(type)
end)

AttachHeadbandTypeOnPlayerPed = function (type)
    local Ped = PlayerPedId()
    if Config.MultiItemSetList[type] then
        local foundResult = false
        for _, v in pairs (AttachedHeadbands) do
            if v.type == type then
                foundResult = true
            end
        end
        Wait(500)
        if not foundResult then
            local coords = GetEntityCoords(Ped)
            ClearPedTasksImmediately(Ped)
            ClearPedSecondaryTask(Ped)
            Citizen.InvokeNative(0xFCCC886EDE3C63EC, Ped, 2, 1) -- Removes Weapon from animation
            local entitiesList = {}
            for _, v in pairs(Config.MultiItemSetList[type]['Object']) do
                Citizen.Wait(200)
                local prop = CreateObject(v.ObjectCode, coords.x, coords.y, coords.z , 0.2, true, true, false, false, true)
                table.insert(entitiesList, prop)
                local boneIndex = GetEntityBoneIndexByName(Ped, v.Attachment)
                AttachEntityToEntity(prop, Ped, boneIndex,
                v.x, v.y, v.z, v.xRot, v.yRot, v.zRot,
                true, true, false, true, 1, true)
            end
            table.insert(AttachedHeadbands, {type = type, entities = entitiesList })
        else
            ClearPedTasksImmediately(Ped)
            ClearPedSecondaryTask(Ped)
            DeleteAnimationHeadbandTypeProps(type)
        end
    end
end

DHeadband = function ()
    local player = PlayerPedId()
    ClearPedTasksImmediately(player)
    ClearPedSecondaryTask(player)
    DeleteAnimationHeadbandProps()
end

RegisterCommand("wearables", function(source, args)
    if args ~= nil then
        DHeadband()
    end
end, false)
