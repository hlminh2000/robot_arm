const arduino = @import("lib/arduino.zig");
const DigitalControlledServo = @import("common/DigitalControlledServo.zig").DigitalControlledServo;
const Servo = @import("lib/servo.zig").Servo;
const Serial = arduino.Serial;

var gripper: ?DigitalControlledServo = null;

export fn setup() callconv(.c) void {
    Serial.begin(9600);
    Serial.println("boot: ATmega328P ready");

    gripper = DigitalControlledServo.init("gripper", 12, 6);
}

export fn loop() callconv(.c) void {
    const g = &(gripper orelse {
        Serial.print("No gripper");
        return;
    });

    g.sync();
    arduino.delay(15);
}
