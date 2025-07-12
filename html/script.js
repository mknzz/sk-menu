// Helper Functions
const sendEvent = async (eventType, eventName, eventParams) => {
  try {
    const response = await fetch(`https://${GetParentResourceName()}/event`, {
      method: "POST",
      headers: { "Content-Type": "application/json; charset=UTF-8" },
      body: JSON.stringify({ 
        eventType, 
        eventName, 
        eventParams,
      }),
    });
    const result = await response.json();
    if (result === 'menu_closed') {
      return false;
    }
    return true;
  } catch (error) {
    return false;
  }
};

const createElement = (type, className, text) => {
  const element = document.createElement(type);
  element.className = className;
  if (text) element.textContent = text;
  return element;
};

const createMenuItem = (item) => {
  const menuItem = createElement("div", "menu-item" + (item.textbox ? " has-textbox" : ""));
  let icon = item.icon.startsWith('images/') ? createElement("img") : createElement("i", item.icon);
  if (item.icon.startsWith('images/')) icon.src = `./${item.icon}`;
  
  const content = createElement("div", "menu-item-content");
  const header = createElement("div", "menu-item-header", item.header);
  if (item.color) header.innerHTML = `<span style="color: ${item.color};">${item.header}</span>`;
  
  content.appendChild(header);
  if (item.description) content.appendChild(createElement("div", "menu-item-description", item.description));
  
  // Add textbox if specified
  if (item.textbox) {
    const textbox = createElement("input", "menu-item-textbox");
    textbox.type = "text";
    textbox.placeholder = item.textbox.placeholder || "Enter text...";
    textbox.maxLength = item.textbox.maxLength || 50;
    content.appendChild(textbox);
    textbox.addEventListener("click", (e) => e.stopPropagation());
  }
  
  menuItem.appendChild(icon);
  menuItem.appendChild(content);
  menuItem.addEventListener("click", () => {
    if (item.disabled) return;
    // Get textbox value if exists
    const textboxValue = menuItem.querySelector('.menu-item-textbox')?.value;
    
    if (item.event) {
      if (item.textbox) {
        // If there's a textbox, handle the value differently based on whether an event for the textbox exists
        if (item.textbox.event) {
          // Send original event and separate textbox event
          sendEvent(item.eventType, item.event, item.eventParams);
          sendEvent(item.textbox.eventType || 'client', item.textbox.event, textboxValue);
        } else {
          // No textbox event, send textbox value as additional param to original event
          const params = item.eventParams ? 
            Array.isArray(item.eventParams) ? 
              [...item.eventParams, textboxValue] : 
              [item.eventParams, textboxValue] :
            textboxValue;
          sendEvent(item.eventType, item.event, params);
        }
      } else {
        // No textbox, send original
        sendEvent(item.eventType, item.event, item.eventParams);
      }
    }

    if (item.action) {
      fetch(`https://${GetParentResourceName()}/clickedButton`, {
        method: "POST",
        headers: { "Content-Type": "application/json; charset=UTF-8" },
        body: JSON.stringify({ 
          index: item.index,
          value: textboxValue 
        }),
      });
    }
    
    if (item.shouldClose) fetch(`https://${GetParentResourceName()}/closeMenu`, { method: "POST" });
  });

  if (item.disabled) {
    menuItem.style.backgroundColor = "#353636";
    menuItem.style.cursor = "not-allowed";
  }

  return menuItem;
};

// Event Listeners
window.addEventListener("message", (event) => {
  const menu = document.getElementById("menu");
  if (!menu) return;

  if (event.data.action === "openMenu") {
    const { data: menuData, position } = event.data;
    menu.innerHTML = ""; // Clear the existing menu content
    menu.style.position = "fixed";
    menu.style[position] = "20%";
    menu.style[position === "left" || position === "right" ? "top" : "left"] = "50%";
    menu.style.transform = `translate${position === "left" || position === "right" ? "Y" : "X"}(-50%)`;

    // Set the menu title and icon
    const menuTitle = createElement("div", "menu-title");
    const menuIcon = createElement("i", menuData.titleIcon);
    const menuTitleText = createElement("span", "", menuData.title);
    menuTitleText.id = "menu-title-text";
    menuTitle.append(menuIcon, menuTitleText);
    menu.appendChild(menuTitle);

    // Add the level box if levelInfo is not null or undefined
    if (menuData.levelInfo) {
      const levelBox = createElement("div", "level-box", menuData.levelInfo);
      menuTitle.appendChild(levelBox); // Append it to the menu title
    }

    // Set the general description
    const menuInfo = createElement("div", "menu-info", menuData.generalDescription);
    menuInfo.id = "menu-info";
    menu.appendChild(menuInfo);

    // Create a progress bar for level experience
    if (menuData.exp || (menuData.exp == 0 && menuData.xpNeeded)) {
      const progressBar = createElement("div", "progress-bar");
      const progressBarFill = createElement("div", "progress-bar-fill");
      progressBarFill.style.width = `${(menuData.exp / menuData.expNext) * 100}%`;
      progressBar.appendChild(progressBarFill);
      menu.appendChild(progressBar);
      // Display the XP needed
      const xpInfo = createElement("div", "xp-info", menuData.xpNeeded);
      menu.appendChild(xpInfo);
    }

    // Create a menu item for each item in the menuData.items array
    menuData.items.forEach((item, index) => {
      item.index = index + 1;
      menu.appendChild(createMenuItem(item));
    });

    // Smooth fade in
    requestAnimationFrame(() => {
      menu.style.opacity = "0";
      requestAnimationFrame(() => {
        menu.style.display = "block";
        requestAnimationFrame(() => {
          menu.style.opacity = "1";
        });
      });
    });
  } else if (event.data.action === "closeMenu") {
    menu.style.opacity = "0";
    setTimeout(() => {
      menu.style.display = "none";
      menu.innerHTML = "";
      if (typeof event.data._cb === "function") {
        event.data._cb('ok');
      }
    }, 500);
  }
});

window.addEventListener("keydown", async (event) => {
  if (event.key === "Escape") {
    try {
      await fetch(`https://${GetParentResourceName()}/closeMenu`, { method: "POST", body: JSON.stringify({}) });
    } catch (error) {
      console.log(error)
    }
  }
});