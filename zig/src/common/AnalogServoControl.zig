const Ticker = @import("./Ticker.zig").Ticker;
const Arduino = @import("../lib/arduino.zig");
const Serial = @import("../lib/arduino.zig").Serial;
const Servo = @import("../lib/servo.zig").Servo;
const ServoAllocationError = @import("../lib/servo.zig").ServoAllocationError;
const String = @import("types.zig").String;

const maxSpeedPerSecond: f32 = 180.0;
const startingAngle = 90;

fn clamp(value: f32, min: f32, max: f32) f32 {
    return @max(@min(value, max), min);
}

pub const AnalogServoControl = struct {
    _name: String,
    _ticker: Ticker,
    _servo: *Servo,
    _controlPin: u8,

    pub fn init(options: struct {
        name: String,
        controlPin: u8,
        servo: *Servo,
    }) ServoAllocationError!AnalogServoControl {
        return .{
            ._name = options.name,
            ._controlPin = options.controlPin,
            ._servo = options.servo,
            ._ticker = Ticker.init(.{}),
        };
    }
    pub fn sync(self: *AnalogServoControl) void {
        const deltaTimeSeconds = self._ticker.tickSeconds() orelse return;

        const controlSignal: f32 = @floatFromInt(Arduino.analogRead(self._controlPin));
        const midPoint: f32 = comptime 1023.0 / 2.0;
        const normalized: f32 = (controlSignal - midPoint) / midPoint; // -1 to +1

        var velocity = -normalized * maxSpeedPerSecond;
        if (@abs(velocity) < 5) {
            velocity = 0.0;
        }

        const physicalServoAngle = @as(f32, @floatFromInt(self._servo.read()));
        const currentAngle: f32 = self._servo.currentAngleDegree orelse physicalServoAngle;

        const nextAngle = clamp(currentAngle + velocity * deltaTimeSeconds, 0, 180);
        self._servo.write(nextAngle);
    }
};
