#include <ArduinoJson.h>
#include "ControlledComponent.h"

AnalogControlledServo joint1("Joint 1", 0, 3);
AnalogControlledServo joint2("Joint 2", 1, 5);
DigitalControlledServo gripper("Gripper", 12, 6);

void setup() {
  Serial.begin(9600);
  joint1.setup();
  joint2.setup();
  gripper.setup();
  Serial.println("Setup complete");
}

void loop() {
  JsonDocument message;
  if (Serial.available() > 0) {
    DeserializationError error = deserializeJson(message, Serial);
    if (error == DeserializationError::Ok) {
      const float angle = message["angle"].as<float>();
      const char* jointName = message["joint"].as<const char*>();
      if(strcmp(jointName, joint1.name.c_str()) == 0) {
        joint1.sync(angle);
      } else {
        joint1.sync(-9999);
      }
      if(strcmp(jointName, joint2.name.c_str()) == 0) {
        joint2.sync(angle);
      } else {
        joint2.sync(-9999);
      }
    } else {
      // If data was corrupted or partial, ignore it!
      // This prevents the "twitch"
      while(Serial.available() > 0) Serial.read(); 
    }
  } else {
    joint1.sync(-9999);
    joint2.sync(-9999);
  }


  message.clear();

  gripper.sync();
  delay(5); // Small delay for stability
}
