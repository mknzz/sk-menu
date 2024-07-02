-- Check if the user should be in the Fence menu for refreshing HAHA
local shouldBeInFenceMenu = false

-- Store the functions associated with each menu item
local savedFunctions = {}

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

-- Handle menu item events
RegisterNUICallback('event', function(data, cb)
    local eventName = data.eventName
    local eventParams = data.eventParams
    local eventType = data.eventType

    print(eventName)

    if eventParams then
        -- Check if it's a table of multiple parameters
        if type(eventParams) == 'table' then
            -- Unpack the table of parameters
            if eventType == 'server' then
                TriggerServerEvent(eventName, table.unpack(eventParams))
            else
                TriggerEvent(eventName, table.unpack(eventParams))
            end
        else
            if eventType == 'server' then
                TriggerServerEvent(eventName, eventParams)
            else
                TriggerEvent(eventName, eventParams)
            end
        end
    else
        if eventType == 'server' then
            TriggerServerEvent(eventName)
        else
            TriggerEvent(eventName)
        end
    end

    cb('ok')
end)

-- Handle menu item functions
RegisterNUICallback('clickedButton', function(data, cb)
    local savedFunc = savedFunctions[data.index]
    if savedFunc then savedFunc() end
    cb('ok')
end)

RegisterNUICallback('closeMenu', function(_, cb)
    SendNUIMessage({
        action = 'closeMenu'
    })
    SetNuiFocus(false, false)
    savedFunctions = nil
    shouldBeInFenceMenu = false
    cb('ok')
end)

----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

-- Open NUI menu
--- @param customMenuData table - The data for the custom menu.
--- @param position string - The position where the menu should be displayed. This should be a string such as 'top', 'bottom', 'left', 'right'.
function OpenCustomMenu(customMenuData, position)
    SendNUIMessage({
        action = 'openMenu',
        data = customMenuData,
        position = position
    })
    SetNuiFocus(true, true)

    SetFunctionData(customMenuData)

    if customMenuData.title and customMenuData.title == 'Fence' then
        shouldBeInFenceMenu = true
    end
end

exports('OpenCustomMenu', OpenCustomMenu)

function GetInMenu()
    return shouldBeInFenceMenu
end

exports('GetInMenu', GetInMenu)

function SetFunctionData(data)
    savedFunctions = {}
    for i, item in ipairs(data.items) do
        savedFunctions[i] = item.action
    end
end