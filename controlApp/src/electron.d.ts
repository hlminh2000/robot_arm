interface ElectronAPI {
    send(channel: string, data: string): void;
}

declare global {
    interface Window {
        electron: ElectronAPI;
    }
}

export {};
