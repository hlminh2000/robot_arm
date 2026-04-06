
#include <Servo.h>

Servo servo1;
const int servo1Pin = 3;

Servo servo2;
const int servo2Pin = 5;

const int controlButtonPin = 13;

float x = 0;
float y = 0;

bool isOn = false;
int lasButtonState;

void setup()
{
  Serial.begin(9600);
  servo1.attach(servo1Pin);
  servo2.attach(servo2Pin);

  pinMode(controlButtonPin, INPUT_PULLUP);
  lasButtonState = digitalRead(controlButtonPin);

  Serial.println("Setup complete");
  delay(1000);
}

void loop()
{
  if(isPaused()) return;

  float sinX = sin(x);
  int degX = map(sinX*100, -100, 100, 0, 180);
  x += 0.0005;
  
  float siny = cos(y);
  int degY = map(siny*100, -100, 100, 0, 180);
  y += 0.0005;


  servo1.write(degX);
  servo2.write(degY);
}

bool isPaused ()
{
  int controlButtonState = digitalRead(controlButtonPin);
  if(controlButtonState == LOW && lasButtonState != controlButtonState) {
    isOn = !isOn;
  }
  lasButtonState = controlButtonState;
  return !isOn;
}
