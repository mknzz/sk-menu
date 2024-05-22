RegisterNUICallback('closeMenu', function()
    SendNUIMessage({
        action = 'closeMenu'
    })
    SetNuiFocus(false, false)
end)

-- TODO: sketchy?
-- If the button has an event (either server or client), this function will trigger that event.
--- @param data table - The data associated with the NUI event. It should include the eventName, eventParams, and eventType ('server' or 'client').
--- @param cb function
RegisterNUICallback('event', function(data, cb)
    local eventName = data.eventName
    local eventParams = data.eventParams
    local eventType = data.eventType

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
end

exports('OpenCustomMenu', OpenCustomMenu)