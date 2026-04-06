// src/preload.ts
const { contextBridge, ipcRenderer } = require('electron');
console.log('yooo!!!');
contextBridge.exposeInMainWorld('electron', {
    send: (channel, data) => {
        const validChannels = ['send-to-arduino'];
        if (validChannels.includes(channel)) {
            ipcRenderer.send(channel, data);
        }
    }
});
