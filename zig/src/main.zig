const arduino = @import("lib/arduino.zig");
const GripperServo = @import("common/GripperServo.zig").GripperServo;
const AnalogControlledServo = @import("common/AnalogControlledServo.zig").AnalogControlledServo;
const Servo = @import("lib/servo.zig").Servo;
const Serial = arduino.Serial;

export fn setup() callconv(.c) void {
    Serial.begin(9600);
    var gripper = GripperServo.init(.{ .name = "gripper", .controlPin = 12, .servoPin = 6 }) catch return;
    defer gripper.deinit();

    var joint1 = AnalogControlledServo.init(.{ .name = "Joint 1", .controlPin = 0, .servoPin = 3 }) catch return;
    defer joint1.deinit();

    var joint2 = AnalogControlledServo.init(.{ .name = "Joint 2", .controlPin = 1, .servoPin = 5 }) catch return;
    defer joint2.deinit();

    Serial.println("boot: ATmega328P ready");

    while (true) {
        gripper.sync();
        joint1.sync();
        joint2.sync();
    }
}

export fn loop() callconv(.c) void {}
