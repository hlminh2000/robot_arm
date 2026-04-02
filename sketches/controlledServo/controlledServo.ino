#include "ControlledServo.h"

ControlledServo servo(5, 3);

void setup() {
  servo.setup();
}

void loop() {
  servo.sync();
}
