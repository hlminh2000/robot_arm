#include <Arduino.h>
#include <Servo.h>

static Servo servos[12];

extern "C"
{
  void arduino_pinMode(uint8_t pin, uint8_t mode) { pinMode(pin, mode); }
  void arduino_digitalWrite(uint8_t pin, uint8_t val) { digitalWrite(pin, val); }
  void arduino_delay(unsigned long ms) { delay(ms); }

  void serial_begin(unsigned long baud) { Serial.begin(baud); }
  void serial_print(const char *str) { Serial.print(str); }
  void serial_println(const char *str) { Serial.println(str); }
  void serial_print_int(int val) { Serial.print(val); }
  void serial_println_int(int val) { Serial.println(val); }
  void serial_write_byte(uint8_t b) { Serial.write(b); }
  int serial_available() { return Serial.available(); }
  int serial_read() { return Serial.read(); }

  uint8_t servo_attach(uint8_t id, int pin) { return servos[id].attach(pin); }
  uint8_t servo_attach_minmax(uint8_t id, int pin, int min_us, int max_us) { return servos[id].attach(pin, min_us, max_us); }
  void servo_write(uint8_t id, int angle) { servos[id].write(angle); }
  void servo_write_microseconds(uint8_t id, int us) { servos[id].writeMicroseconds(us); }
  int servo_read(uint8_t id) { return servos[id].read(); }
  int servo_read_microseconds(uint8_t id) { return servos[id].readMicroseconds(); }
  bool servo_attached(uint8_t id) { return servos[id].attached(); }
  void servo_detach(uint8_t id) { servos[id].detach(); }
}
