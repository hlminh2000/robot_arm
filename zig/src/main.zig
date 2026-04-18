const arduino = @import("lib/arduino.zig");
const GripperServo = @import("common/GripperServo.zig").GripperServo;
const AnalogControlledServo = @import("common/AnalogControlledServo.zig").AnalogControlledServo;
const Servo = @import("lib/servo.zig").Servo;
const Serial = arduino.Serial;

export fn setup() callconv(.c) void {
    Serial.begin(9600);
    var gripper = GripperServo.init("gripper", 12, 6) catch return;
    defer gripper.deinit();

    var joint1 = AnalogControlledServo.init("Joint 1", 0, 3) catch return;
    defer joint1.deinit();

    var joint2 = AnalogControlledServo.init("Joint 2", 1, 5) catch return;
    defer joint2.deinit();

    Serial.println("boot: ATmega328P ready");

    while (true) {
        gripper.sync();
        joint1.sync();
        joint2.sync();
        arduino.delay(5);
    }
}

export fn loop() callconv(.c) void {}
