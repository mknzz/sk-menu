-- Variables
local shouldBeInFenceMenu = false
local savedFunctions = {}
local isMenuOpen = false

-- Functions
local function handleEvent(data, cb)
    if not isMenuOpen then
        cb('menu_closed')
    end

    local eventName = data.eventName
    local eventParams = data.eventParams
    local eventType = data.eventType

    if not eventName then return cb('invalid_event') end

    local trigger = eventType == 'server' and TriggerServerEvent or TriggerEvent

    local success, error = pcall(function()
        if eventParams then
            if type(eventParams) == 'table' then
                trigger(eventName, table.unpack(eventParams))
            else
                trigger(eventName, eventParams)
            end
        else
            trigger(eventName)
        end
    end)

    if not success then
        cb('error')
    else
        cb('ok')
    end
end

local function handleClick(data, cb)
    if not isMenuOpen then
        cb('menu_closed')
    end

    local savedFunc = savedFunctions[data.index]
    if savedFunc then
        local success, error = pcall(savedFunc)
        if not success then
            cb('error')
            return
        end
    else
        print('[sk-menu] No function found for index:', data.index)
    end
    cb('ok')
end

local function handleClose(_, cb)
    if not isMenuOpen then
        return cb('menu_closed')
    end

    SendNUIMessage({ action = 'closeMenu' })
    SetNuiFocus(false, false)
    savedFunctions = {}
    shouldBeInFenceMenu = false
    isMenuOpen = false
    cb('ok')
end

local function setFunctionData(data)
    if type(data.items) ~= 'table' then
        return
    end

    savedFunctions = {}
    local count = 0
    for i, item in ipairs(data.items) do
        if item.action then
            savedFunctions[i] = item.action
            count = count + 1
        end
    end
end

local function openCustomMenu(customMenuData, position)
    if isMenuOpen then
        --print('[sk-menu] Warning: Menu already open')
    end

    if type(customMenuData) ~= 'table' then
        --print('[sk-menu] Error: Invalid menu data')
        return
    end

    isMenuOpen = true

    SendNUIMessage({
        action = 'openMenu',
        data = customMenuData,
        position = position,
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