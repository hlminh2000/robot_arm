#pragma once 
#include <Arduino.h>
#include <Servo.h>

float clamp (float value, float min, float max) {
  return max(min(value, max), min);
}

class ControlledComponent
{
public:
  String name;
  virtual ControlledComponent() {}
  virtual ~ControlledComponent() {}
  virtual void setup() {}
  virtual void sync(){}
};

class DigitalControlledServo : public ControlledComponent
{
  Servo servo;
  int controlPin;
  int servoPin;
  bool wasOn = false;
  static constexpr int openAngle = 90;
  static constexpr int closeAngle = 45;

public:
  String name;
  DigitalControlledServo(String _name, int _controlPin, int _servoPin)
  {
    name = _name;
    controlPin = _controlPin;
    servoPin = _servoPin;
    pinMode(controlPin, INPUT_PULLUP);
  }

  void setup()
  {
    servo.attach(servoPin);
    servo.write(openAngle);
  }

  void sync()
  {
    int controlSignal = digitalRead(controlPin);

    bool isOn = controlSignal == LOW;
    bool pressedStateChanged = isOn != wasOn;
    if (pressedStateChanged)
    {
      Serial.println(isOn);
      servo.write(isOn ? closeAngle : openAngle);
    }
    wasOn = isOn;
  }
};

class AnalogControlledServo : public ControlledComponent
{
  Servo servo;
  int controlPin;
  int servoPin;

  float velocity;
  float currentAngle = 90;
  float targetAngle = 90;
  static constexpr float maxSpeed = 2.0f;

  int flipAngle (int angle)
  {
    return 180 - angle;
  }

public:
  String name;
  AnalogControlledServo(String _name, int _controlPin, int _servoPin)
  {
    name = _name;
    controlPin = _controlPin;
    servoPin = _servoPin;
  }

  void setup()
  {
    servo.attach(servoPin);
    servo.write(currentAngle);
  }

  void sync(float angleFromSerialMessage)
  {
    if (angleFromSerialMessage != -9999) {
      targetAngle = angleFromSerialMessage;
      animateToTargetAngle(0);
    } else {
      int controlSignal = analogRead(controlPin);

      constexpr float midPoint = 1023 / 2;
      float normalized = (controlSignal - midPoint) / midPoint; // Range -1.0 to 1.0
      velocity = -normalized * maxSpeed;

      if (abs(velocity) < 0.15f)
      {
        velocity = 0.0f;
      }

      if (targetAngle < 0)
        targetAngle = 0;
      else if (targetAngle > 179)
        targetAngle = 179;
      else
        targetAngle += velocity;
      animateToTargetAngle(velocity);
    }
  }

  void animateToTargetAngle(float velocity){
    if (velocity) {
      servo.write(currentAngle + velocity);
      currentAngle += velocity;
      return;
    }
    const float targetSpeed = clamp(20, 0, abs(targetAngle - currentAngle));
    // const float targetSpeed = clamp(((targetAngle - currentAngle) / 50), 0.5f, maxSpeed);
    if (currentAngle < targetAngle)
    {
      currentAngle += targetSpeed;
    }
    else if (currentAngle > targetAngle)
    {
      currentAngle -= targetSpeed;
    }
    servo.write(currentAngle);
  }

  int getCurrentAngle()
  {
    return currentAngle;
  }
};
