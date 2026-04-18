const Arduino = @import("../lib/arduino.zig");

pub const Ticker = struct {
    _lastTick: c_ulong = 0,
    _interval: u32 = 0,

    pub fn init(interVal: u32) Ticker {
        return .{
            ._lastTick = Arduino.millis(),
            ._interval = interVal,
        };
    }

    pub fn tickSeconds(self: *Ticker) ?f32 {
        const current = Arduino.millis();
        const delta = current - self._lastTick;

        if (delta < self._interval) return null;

        self._lastTick = current;

        const deltaAsFloat = @as(f32, @floatFromInt(delta));
        return deltaAsFloat / 1000.0;
    }
};
