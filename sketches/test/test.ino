
#include <Servo.h>

Servo servo1;
Servo servo2;

void setup()
{
  Serial.begin(9600);
  Serial.println("Setup complete");
  servo1.attach(3);
  servo2.attach(5);
}

void loop()
{
  int pot1 = analogRead(5);
  int val1 = map(pot1, 0, 1023, 0, 180);
  servo1.write(val1);

  int pot2 = analogRead(4);
  int val2 = map(pot2, 0, 1023, 0, 180);
  servo2.write(val2);
}