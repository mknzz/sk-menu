// Helper Functions
const sendEvent = (eventType, eventName, eventParams) => {
  fetch(`https://${GetParentResourceName()}/event`, {
    method: "POST",
    headers: { "Content-Type": "application/json; charset=UTF-8" },
    body: JSON.stringify({ eventType, eventName, eventParams }),
  });
};

const createElement = (type, className, text) => {
  const element = document.createElement(type);
  element.className = className;
  if (text) element.textContent = text;
  return element;
};

const createMenuItem = (item) => {
  const menuItem = createElement("div", "menu-item");
  let icon = item.icon.startsWith('images/') ? createElement("img") : createElement("i", item.icon);
  if (item.icon.startsWith('images/')) icon.src = `./${item.icon}`;
  
  const content = createElement("div", "menu-item-content");
  const header = createElement("div", "menu-item-header", item.header);
  if (item.color) header.innerHTML = `<span style="color: ${item.color};">${item.header}</span>`;
  
  content.appendChild(header);
  if (item.description) content.appendChild(createElement("div", "menu-item-description", item.description));
  
  menuItem.appendChild(icon);
  menuItem.appendChild(content);
  menuItem.addEventListener("click", () => {
    if (item.event && !item.disabled) sendEvent(item.eventType, item.event, item.eventParams);
    if (item.action) {
      fetch(`https://${GetParentResourceName()}/clickedButton`, {
        method: "POST",
        headers: { "Content-Type": "application/json; charset=UTF-8" },
        body: JSON.stringify({ index: item.index }),
      });
    }
    if (item.shouldClose && !item.disabled) fetch(`https://${GetParentResourceName()}/closeMenu`, { method: "POST" });
  });

  if (item.disabled) {
    menuItem.style.backgroundColor = "dimgrey";
    menuItem.style.cursor = "none";
    //icon.className = "fa-solid fa-ban";
  }

  return menuItem;
};

// Event Listeners
window.addEventListener("message", (event) => {
  const menu = document.getElementById("menu");

  if (event.data.action === "openMenu") {
    const { data: menuData, position } = event.data;
    menu.innerHTML = ""; // Clear the existing menu content
    menu.style.position = "fixed";
    menu.style[position] = "15%";
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
    }, 500);
  }
});

window.addEventListener("keydown", async (event) => {
  if (event.key === "Escape") {
    try {
      await fetch(`https://${GetParentResourceName()}/closeMenu`, { method: "POST" });
    } catch (error) {
      console.log(error)
    }
  }
});
