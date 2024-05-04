RegisterNUICallback('closeMenu', function()
    SendNUIMessage({
        action = 'closeMenu'
    })
    SetNuiFocus(false, false)
end)

-- If the button has an event (either server or client), this function will trigger that event.
--- @param data table - The data associated with the NUI event. It should include the eventName, eventParams, and eventType ('server' or 'client').
--- @param cb function
RegisterNUICallback('event', function(data, cb)
    local eventName = data.eventName
    local eventParams = data.eventParams
    local eventType = data.eventType

    print(eventName, eventParams, eventType)

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

----------------------------------------------------------
-------------------------Testing--------------------------
----------------------------------------------------------

local menuData = {
    title = 'Burglary Man',
    titleIcon = 'fa-solid fa-circle-user',
    levelInfo = 10,
    generalDescription = 'Level up with each job, unlocking tougher challenges and better loot. Beware, getting caught has consequences.',
    exp = 111111,
    xpNeeded = 1000000,
    items = {
        {header = 'Menu Item 1', description = 'This is the first menu item.', icon = 'fas fa-home', event = 'serverEvent2'},
        {header = 'Menu Item 2', description = 'This is the second menu item.', icon = 'fas fa-user', event = 'clientEvent2'},
        {header = 'Menu Item 3', description = 'This is the third menu item.', icon = 'fas fa-user', event = 'clientEvent2', eventParams = {'test', 'test'}, eventType = "client" },
    }
}

RegisterCommand('openMenu', function()
    SendNUIMessage({
        action = 'openMenu',
        data = menuData,
        position = 'right'
    })
    SetNuiFocus(true, true)
end, false)

RegisterCommand('closeMenu', function()
    SendNUIMessage({
        action = 'closeMenu'
    })
    SetNuiFocus(false, false)
end, false)