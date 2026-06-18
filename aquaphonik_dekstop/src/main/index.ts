/**
 * Aquaphonik Desktop — Main Process Entry
 * Electron main process that creates the window and registers all IPC handlers
 * for serial port communication and database operations.
 */

import { app, shell, BrowserWindow, ipcMain } from 'electron'
import { join } from 'path'
import { electronApp, optimizer, is } from '@electron-toolkit/utils'
import icon from '../../resources/icon.png?asset'

// Main process modules
import {
  listPorts,
  connectPort,
  disconnectPort,
  sendCommand,
  getStatus,
  onData as onSerialData,
  cleanup as serialCleanup
} from './serial'
import {
  initDatabase,
  insertSensorLog,
  getLatestLogs,
  getLogsByDateRange,
  getLogCount,
  deleteOldLogs,
  closeDatabase
} from './database'
// Server: Modul komunikasi REST API dan Socket.IO dengan Flutter Mobile
import { initServer, publishSensorData, closeServer } from './express-api'

// --- Data Logging Interval ---
// We receive data every ~2 seconds from the MCU, but we only save to DB
// at a configurable interval to prevent database bloat.
let logIntervalMinutes = 1 // Default: save every 1 minute
let lastLogTimestamp = 0

function createWindow(): void {
  const mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    minWidth: 800,
    minHeight: 500,
    show: false,
    autoHideMenuBar: true,
    title: 'AquaPhonik Desktop',
    // Untuk Linux (Raspberry Pi), jalankan dalam mode fullscreen secara default
    ...(process.platform === 'linux' ? { icon, fullscreen: true, kiosk: true } : {}),
    webPreferences: {
      preload: join(__dirname, '../preload/index.js'),
      sandbox: false
    }
  })

  mainWindow.on('ready-to-show', () => {
    if (process.platform === 'linux') {
      mainWindow.maximize()
    }
    mainWindow.show()
  })

  mainWindow.webContents.setWindowOpenHandler((details) => {
    shell.openExternal(details.url)
    return { action: 'deny' }
  })

  // HMR for renderer based on electron-vite cli.
  if (is.dev && process.env['ELECTRON_RENDERER_URL']) {
    mainWindow.loadURL(process.env['ELECTRON_RENDERER_URL'])
  } else {
    mainWindow.loadFile(join(__dirname, '../renderer/index.html'))
  }
}

// =====================================================
// Register IPC Handlers
// =====================================================
function registerIpcHandlers(): void {
  // --- Serial Port Handlers ---

  /**
   * Scan available COM/Serial ports
   */
  ipcMain.handle('serial:list-ports', async () => {
    return await listPorts()
  })

  /**
   * Connect to a serial port
   */
  ipcMain.handle('serial:connect', async (_event, portPath: string, baudRate?: number) => {
    return await connectPort(portPath, baudRate)
  })

  /**
   * Disconnect from the serial port
   */
  ipcMain.handle('serial:disconnect', async () => {
    return await disconnectPort()
  })

  /**
   * Send a command to the microcontroller
   */
  ipcMain.handle('serial:send-command', (_event, command: string) => {
    return sendCommand(command)
  })

  /**
   * Get current serial connection status
   */
  ipcMain.handle('serial:get-status', () => {
    return getStatus()
  })

  // --- Database Handlers ---

  /**
   * Get latest sensor logs
   */
  ipcMain.handle('db:get-latest-logs', (_event, limit?: number) => {
    return getLatestLogs(limit)
  })

  /**
   * Get logs by date range
   */
  ipcMain.handle('db:get-logs-by-date', (_event, startDate: string, endDate: string) => {
    return getLogsByDateRange(startDate, endDate)
  })

  /**
   * Get total log count
   */
  ipcMain.handle('db:get-log-count', () => {
    return getLogCount()
  })

  /**
   * Delete old logs
   */
  ipcMain.handle('db:delete-old-logs', (_event, daysToKeep?: number) => {
    return deleteOldLogs(daysToKeep)
  })

  // --- Settings Handlers ---

  /**
   * Set the log interval (in minutes)
   */
  ipcMain.handle('settings:set-log-interval', (_event, minutes: number) => {
    logIntervalMinutes = Math.max(1, minutes)
    return { success: true, interval: logIntervalMinutes }
  })

  /**
   * Get current log interval
   */
  ipcMain.handle('settings:get-log-interval', () => {
    return { interval: logIntervalMinutes }
  })

  // --- Register serial data callback for conditional DB logging + MQTT publish ---
  onSerialData((data) => {
    const now = Date.now()
    const intervalMs = logIntervalMinutes * 60 * 1000

    // Socket.IO: Publish data sensor realtime ke Flutter setiap kali data masuk
    publishSensorData(data)

    // Database: Simpan ke PostgreSQL hanya sesuai interval yang dikonfigurasi
    if (now - lastLogTimestamp >= intervalMs) {
      insertSensorLog({
        temp_water: data.temp_water ?? 0,
        ph: data.ph ?? 0,
        ph_volts: data.ph_volts ?? 0,
        tds: data.tds ?? 0,
        do_value: data.do ?? 0,
        turbidity: data.turbidity ?? 0,
        water_lvl: data.water_lvl ?? 0,
        co2: data.co2 ?? 0,
        eco2: data.eco2 ?? 0,
        tvoc: data.tvoc ?? 0,
        temp_air: data.temp_air ?? 0,
        humidity: data.humidity ?? 0,
        pump_status: data.pump_status ?? 0,
        oxy_status: data.oxy_status ?? 0
      })
      lastLogTimestamp = now
    }
  })
}

// =====================================================
// App Lifecycle
// =====================================================
app.whenReady().then(() => {
  electronApp.setAppUserModelId('com.aquaphonik.desktop')

  // DevTools shortcut
  app.on('browser-window-created', (_, window) => {
    optimizer.watchWindowShortcuts(window)
  })

  // Initialize database
  initDatabase()

  // Initialize Server (Express + Socket.IO) untuk komunikasi dengan Flutter
  initServer()

  // Register all IPC handlers
  registerIpcHandlers()

  // Create the main window
  createWindow()

  app.on('activate', function () {
    if (BrowserWindow.getAllWindows().length === 0) createWindow()
  })
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

// Cleanup on quit
app.on('before-quit', () => {
  serialCleanup()
  closeServer()
  closeDatabase()
})
