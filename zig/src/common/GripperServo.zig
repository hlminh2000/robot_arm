const Arduino = @import("../lib/arduino.zig");
const Serial = @import("../lib/arduino.zig").Serial;
const Servo = @import("../lib/servo.zig").Servo;
const ServoAllocationError = @import("../lib/servo.zig").ServoAllocationError;
const String = @import("types.zig").String;

const angleOpen: u8 = 90;
const angleClosed: u8 = 45;

pub const GripperServo = struct {
    _name: String,
    _servo: Servo,
    _controlPin: u8,
    _wasOn: bool,

    pub fn init(comptime name: String, controlPin: u8, servoPin: u4) ServoAllocationError!GripperServo {
        var servo = try Servo.acquire();
        servo.attach(servoPin);
        servo.write(angleOpen);
        Arduino.pinMode(controlPin, Arduino.PinMode.input_pullup);
        return .{
            ._name = name,
            ._controlPin = controlPin,
            ._servo = servo,
            ._wasOn = false,
        };
    }

    pub fn cleanup(self: *GripperServo) void {
        self._servo.release();
    }

    pub fn sync(self: *GripperServo) void {
        const controlSignal = Arduino.digitalRead(self._controlPin);
        const isOn = controlSignal == Arduino.DigitalValue.low;
        const pressStateChanged = isOn != self._wasOn;
        if (pressStateChanged) {
            self._servo.write(if (isOn) angleClosed else angleOpen);
        }
        self._wasOn = isOn;
    }
};
