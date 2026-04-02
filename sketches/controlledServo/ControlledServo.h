#pragma once 
#include <Arduino.h>
#include <Servo.h>

class ControlledServo
{
  Servo servo;
  int controlPin;
  int servoPin;

public:
  ControlledServo(int _controlPin, int _servoPin)
  {
    this->controlPin = _controlPin;
    this->servoPin = _servoPin;
  }

  void setup()
  {
    this->servo.attach(this->servoPin);
  }

  void sync()
  {
    int controlSignal = analogRead(this->controlPin);
    int degree = map(controlSignal, 0, 1023, 0, 180);
    this->servo.write(degree);
  }
};