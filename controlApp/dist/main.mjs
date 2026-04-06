import path, { join } from "path";
import { app, BrowserWindow } from "electron";
import { ipcMain } from 'electron';
import { SerialPort } from 'serialport';
import { fileURLToPath } from 'node:url';
import _ from 'lodash';
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
// Force dedicated GPU on systems with dual graphics cards (typically laptops).
app.commandLine.appendSwitch("force_high_performance_gpu");
const isDev = process.env.DEV !== undefined;
const port = new SerialPort({
    path: '/dev/tty.usbmodem11301', // Change this to your Arduino's port
    baudRate: 9600,
    autoOpen: true
});
port.on('close', () => {
    console.log('⚠️ Port was closed.');
});
ipcMain.on('send-to-arduino', _.throttle((event, message) => {
    if (!port.isOpen) {
        console.error("❌ Cannot send! The Serial Port is NOT open.");
        return;
    }
    port.write(message, (err) => {
        if (err)
            return console.log('Error on write: ', err.message);
        console.log('Message sent:', message);
    });
}, 40));
app.on("ready", () => {
    const window = new BrowserWindow({
        show: true,
        frame: false,
        closable: true,
        minimizable: true,
        maximizable: true,
        transparent: false,
        titleBarStyle: "hidden",
        width: 1280,
        height: 800,
        webPreferences: {
            nodeIntegration: false,
            nodeIntegrationInWorker: false,
            javascript: true,
            contextIsolation: true,
            preload: path.join(__dirname, 'preload.js'),
            nodeIntegrationInSubFrames: true,
        },
    });
    if (isDev) {
        window.loadURL("http://localhost:5000");
        window.webContents.openDevTools();
    }
    else {
        window.loadURL(join("file://", app.getAppPath(), "dist/index.html"));
    }
});
app.on("window-all-closed", () => {
    app.quit();
});
