#include "ControlledServo.h"

ControlledServo servo1(0, 3);
ControlledServo servo2(1, 5);

void setup() {
  Serial.begin(9600);
  servo1.setup();
  servo2.setup();
  Serial.println("Setup complete");
}

void loop() {
  servo1.sync();
  servo2.sync();
}
