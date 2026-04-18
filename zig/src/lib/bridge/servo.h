#include <Servo.h>

static Servo servos[12];

extern "C"
{

  uint8_t servo_attach(uint8_t id, int pin) { return servos[id].attach(pin); }
  uint8_t servo_attach_minmax(uint8_t id, int pin, int min_us, int max_us) { return servos[id].attach(pin, min_us, max_us); }
  void servo_write(uint8_t id, int angle) { servos[id].write(angle); }
  void servo_write_microseconds(uint8_t id, int us) { servos[id].writeMicroseconds(us); }
  int servo_read(uint8_t id) { return servos[id].read(); }
  int servo_read_microseconds(uint8_t id) { return servos[id].readMicroseconds(); }
  bool servo_attached(uint8_t id) { return servos[id].attached(); }
  void servo_detach(uint8_t id) { servos[id].detach(); }
}
