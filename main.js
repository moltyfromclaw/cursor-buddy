const { app, BrowserWindow, screen, ipcMain, desktopCapturer, globalShortcut } = require('electron');
const path = require('path');

let buddyWindow = null;
let isFollowing = true;
let offsetX = 30;
let offsetY = 30;

function createBuddyWindow() {
  buddyWindow = new BrowserWindow({
    width: 280,
    height: 120,
    frame: false,
    transparent: true,
    alwaysOnTop: true,
    skipTaskbar: true,
    resizable: false,
    hasShadow: false,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false
    }
  });

  buddyWindow.loadFile('buddy.html');
  buddyWindow.setVisibleOnAllWorkspaces(true, { visibleOnFullScreen: true });
  
  // Make window click-through except for interactive elements
  buddyWindow.setIgnoreMouseEvents(true, { forward: true });
  
  // Start cursor tracking
  trackCursor();
}

function trackCursor() {
  setInterval(() => {
    if (!isFollowing || !buddyWindow) return;
    
    const point = screen.getCursorScreenPoint();
    const display = screen.getDisplayNearestPoint(point);
    
    // Calculate position with offset, keeping in bounds
    let x = point.x + offsetX;
    let y = point.y + offsetY;
    
    // Keep window on screen
    const bounds = display.bounds;
    const winBounds = buddyWindow.getBounds();
    
    if (x + winBounds.width > bounds.x + bounds.width) {
      x = point.x - winBounds.width - 10;
    }
    if (y + winBounds.height > bounds.y + bounds.height) {
      y = point.y - winBounds.height - 10;
    }
    
    buddyWindow.setPosition(Math.round(x), Math.round(y), false);
  }, 50); // 20fps tracking
}

// IPC handlers
ipcMain.on('set-interactive', (event, interactive) => {
  if (buddyWindow) {
    buddyWindow.setIgnoreMouseEvents(!interactive, { forward: true });
  }
});

ipcMain.on('toggle-follow', () => {
  isFollowing = !isFollowing;
});

ipcMain.on('capture-screen', async (event) => {
  try {
    const sources = await desktopCapturer.getSources({ 
      types: ['screen'], 
      thumbnailSize: { width: 1920, height: 1080 }
    });
    if (sources.length > 0) {
      const screenshot = sources[0].thumbnail.toDataURL();
      event.reply('screen-captured', screenshot);
    }
  } catch (err) {
    console.error('Screen capture failed:', err);
  }
});

app.whenReady().then(() => {
  createBuddyWindow();
  
  // Global shortcut to toggle buddy visibility
  globalShortcut.register('CommandOrControl+Shift+B', () => {
    if (buddyWindow) {
      if (buddyWindow.isVisible()) {
        buddyWindow.hide();
      } else {
        buddyWindow.show();
      }
    }
  });
  
  // Toggle follow mode
  globalShortcut.register('CommandOrControl+Shift+F', () => {
    isFollowing = !isFollowing;
    if (buddyWindow) {
      buddyWindow.webContents.send('follow-toggled', isFollowing);
    }
  });
});

app.on('will-quit', () => {
  globalShortcut.unregisterAll();
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});
