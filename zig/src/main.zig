const arduino = @import("lib/arduino.zig");
const GripperServo = @import("common/GripperServo.zig").GripperServo;
const AnalogServoControl = @import("common/AnalogServoControl.zig").AnalogServoControl;
const Servo = @import("lib/servo.zig").Servo;
const Serial = arduino.Serial;

export fn setup() callconv(.c) void {
    Serial.begin(9600);
    var gripper = GripperServo.init(.{ .name = "gripper", .controlPin = 12, .servoPin = 6 }) catch return;
    defer gripper.deinit();

    var joint1Servo = Servo.acquire() catch return;
    defer joint1Servo.release();
    joint1Servo.attach(3);
    var joint1AnalogControl = AnalogServoControl.init(.{ .name = "Joint 1", .controlPin = 0, .servo = &joint1Servo }) catch return;

    var joint2Servo = Servo.acquire() catch return;
    defer joint2Servo.release();
    joint2Servo.attach(5);
    var joint2AnalogControl = AnalogServoControl.init(.{ .name = "Joint 2", .controlPin = 1, .servo = &joint2Servo }) catch return;

    Serial.print(gripper._name);

    Serial.println("boot: ATmega328P ready");

    while (true) {
        gripper.sync();
        joint1AnalogControl.sync();
        joint2AnalogControl.sync();
    }
}

export fn loop() callconv(.c) void {}
