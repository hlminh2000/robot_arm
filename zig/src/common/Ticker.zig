const Arduino = @import("../lib/arduino.zig");

pub const Ticker = struct {
    _lastRan: c_ulong = 0,
    _interval: u32 = 0,

    pub fn init(interVal: u32) Ticker {
        return .{
            ._lastRan = Arduino.millis(),
            ._interval = interVal,
        };
    }
    pub fn shouldRun(self: *Ticker) bool {
        const current = Arduino.millis();
        const delta = current - self._lastRan;

        if (delta < self._interval) return false;

        self._lastRan = current;
        return true;
    }
};
