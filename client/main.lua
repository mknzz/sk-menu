-- Variables
local shouldBeInFenceMenu = false
local savedFunctions = {}

-- Functions
local function handleEvent(data, cb)
    local eventName = data.eventName
    local eventParams = data.eventParams
    local eventType = data.eventType

    local trigger = eventType == 'server' and TriggerServerEvent or TriggerEvent
    if eventParams then
        if type(eventParams) == 'table' then
            trigger(eventName, table.unpack(eventParams))
        else
            trigger(eventName, eventParams)
        end
    else
        trigger(eventName)
    end

    cb('ok')
end

local function handleClick(data, cb)
    local savedFunc = savedFunctions[data.index]
    if savedFunc then savedFunc() end
    cb('ok')
end

local function handleClose(_, cb)
    SendNUIMessage({ action = 'closeMenu' })
    SetNuiFocus(false, false)
    savedFunctions = nil
    shouldBeInFenceMenu = false
    cb('ok')
end

local function setFunctionData(data)
    savedFunctions = {}
    for i, item in ipairs(data.items) do
        savedFunctions[i] = item.action
    end
end

local function openCustomMenu(customMenuData, position)
    SendNUIMessage({
        action = 'openMenu',
        data = customMenuData,
        position = position
    })
    SetNuiFocus(true, true)

    setFunctionData(customMenuData)

    if customMenuData.title and customMenuData.title == 'Fence' then
        shouldBeInFenceMenu = true
    end
end

-- Exports
exports('OpenCustomMenu', openCustomMenu)
exports('GetInMenu', function()
    return shouldBeInFenceMenu
end)

-- Callbacks
RegisterNUICallback('event', handleEvent)
RegisterNUICallback('clickedButton', handleClick)
RegisterNUICallback('closeMenu', handleClose)
