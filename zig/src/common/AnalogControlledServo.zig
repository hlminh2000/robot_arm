const Ticker = @import("./Ticker.zig").Ticker;
const Arduino = @import("../lib/arduino.zig");
const Serial = @import("../lib/arduino.zig").Serial;
const Servo = @import("../lib/servo.zig").Servo;
const ServoAllocationError = @import("../lib/servo.zig").ServoAllocationError;
const String = @import("types.zig").String;

const maxSpeedPerSecond: f32 = 180.0;
const startingAngle = 90;

pub const AnalogControlledServo = struct {
    _name: String,
    _ticker: Ticker,
    _servo: Servo,
    _controlPin: u8,

    _velocity: f32 = 0,
    _currentAngle: f32 = startingAngle,
    _targetAngle: f32 = startingAngle,

    pub fn init(name: String, controlPin: u8, servoPin: u8) ServoAllocationError!AnalogControlledServo {
        var servo = try Servo.acquire();
        servo.attach(servoPin);
        servo.write(startingAngle);
        return .{
            ._name = name,
            ._controlPin = controlPin,
            ._servo = servo,
            ._ticker = Ticker.init(0),
        };
    }
    pub fn deinit(self: *AnalogControlledServo) void {
        self._servo.release();
    }
    pub fn sync(self: *AnalogControlledServo) void {
        const deltaTimeSeconds = self._ticker.tickSeconds() orelse return;

        const controlSignal: f32 = @floatFromInt(Arduino.analogRead(self._controlPin));
        const midPoint: f32 = comptime 1023 / 2;
        const normalized: f32 = (controlSignal - midPoint) / midPoint;

        self._velocity = -normalized * maxSpeedPerSecond;
        if (@abs(self._velocity) < 5) {
            self._velocity = 0.0;
        }

        const targetAngle = self._targetAngle;
        self._targetAngle = if (targetAngle < 0) 0 else if (targetAngle > 179) 179 else targetAngle + self._velocity;
        const nextAngle = self._currentAngle + self._velocity * deltaTimeSeconds;
        self._servo.write(@intFromFloat(nextAngle));
        self._currentAngle = nextAngle;
    }
};
