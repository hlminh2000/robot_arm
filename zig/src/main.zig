const arduino = @import("lib/arduino.zig");
const Servo = @import("lib/servo.zig").Servo;
const Serial = arduino.Serial;

var s0 = Servo.init(0);

var angle: c_int = 0;
var direction: c_int = 1;

export fn setup() callconv(.c) void {
    arduino.delay(1000);
    Serial.begin(9600);
    Serial.println("boot: ATmega328P ready");

    _ = s0.attach(3);
    Serial.print("servo 0 attached on pin ");
    Serial.println(s0.pin orelse 0);
}

export fn loop() callconv(.c) void {
    s0.write(angle);
    angle += direction;
    if (angle >= 180 or angle <= 0) direction = -direction;
    arduino.delay(15);
}
