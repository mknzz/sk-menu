# sk-menu

Just a simple NUI menu for FiveM. It’s designed for our existing resources and will also serve as a fundamental component in our next project.

WIP

Testing this with our robbery resource

![alt text](image-5.png)

![alt text](image-7.png)

![alt text](image-8.png)

![alt text](image-9.png)

![alt text](image-10.png)

![alt text](image-4.png)

## Usage
To open a menu, call the `OpenCustomMenu` export with the desired menu data and position.

```
local menuData = {
    title = 'Test title',
    titleIcon = 'fa-solid fa-tasks',
    generalDescription = 'Test desccc',
    items = {
        {
            header = 'item title',
            description = 'item desccc',
            disabled = false,
            icon = 'fa-solid fa-tasks',
            action = function()
            end,
            shouldClose = true,
            event = 'burglary:test:test',
            eventType = 'server',
            eventParams = { },
        },
    }
}
```

```
exports['sk-menu']:OpenCustomMenu(menuData, 'right')
```