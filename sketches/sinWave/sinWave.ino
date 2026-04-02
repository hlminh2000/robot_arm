
#include <Servo.h>

Servo servo1;
float x = 0;

void setup()
{
  Serial.begin(9600);
  delay(1000);
  Serial.println("Setup complete");
  servo1.attach(3);
}

void loop()
{

  float y = sin(x);
  int deg = map(y*100, -100, 100, 0, 180);
  servo1.write(deg);
  x += 0.1;

  Serial.print("x: ");
  Serial.print(x);
  Serial.print(" -> y: ");
  Serial.print(y);
  Serial.print(" -> deg: ");
  Serial.println(deg);

  // int pot2 = analogRead(4);
  // int val2 = map(pot2, 0, 1023, 0, 180);
  // servo2.write(val2);
}