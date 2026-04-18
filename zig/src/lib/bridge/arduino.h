#include <Arduino.h>

extern "C"
{
  // Digital I/O
  void arduino_pinMode(uint8_t pin, uint8_t mode) { pinMode(pin, mode); }
  void arduino_digitalWrite(uint8_t pin, uint8_t val) { digitalWrite(pin, val); }
  int arduino_digitalRead(uint8_t pin) { return digitalRead(pin); }

  // Analog I/O
  int arduino_analogRead(uint8_t pin) { return analogRead(pin); }
  void arduino_analogReference(uint8_t mode) { analogReference(mode); }
  void arduino_analogWrite(uint8_t pin, int val) { analogWrite(pin, val); }

  // Timing
  void arduino_delay(unsigned long ms) { delay(ms); }
  void arduino_delayMicroseconds(unsigned int us) { delayMicroseconds(us); }
  unsigned long arduino_millis() { return millis(); }
  unsigned long arduino_micros() { return micros(); }

  // Pulse
  unsigned long arduino_pulseIn(uint8_t pin, uint8_t state, unsigned long timeout) { return pulseIn(pin, state, timeout); }
  unsigned long arduino_pulseInLong(uint8_t pin, uint8_t state, unsigned long timeout) { return pulseInLong(pin, state, timeout); }

  // Shift
  void arduino_shiftOut(uint8_t dataPin, uint8_t clockPin, uint8_t bitOrder, uint8_t val) { shiftOut(dataPin, clockPin, bitOrder, val); }
  uint8_t arduino_shiftIn(uint8_t dataPin, uint8_t clockPin, uint8_t bitOrder) { return shiftIn(dataPin, clockPin, bitOrder); }

  // Interrupts
  void arduino_interrupts() { sei(); }
  void arduino_noInterrupts() { cli(); }

  // Tone
  void arduino_tone(uint8_t pin, unsigned int freq, unsigned long duration) { tone(pin, freq, duration); }
  void arduino_noTone(uint8_t pin) { noTone(pin); }

  // Random
  long arduino_random(long max_val) { return random(max_val); }
  long arduino_random_range(long min_val, long max_val) { return random(min_val, max_val); }
  void arduino_randomSeed(unsigned long seed) { randomSeed(seed); }

  // Math
  long arduino_map(long val, long fromLow, long fromHigh, long toLow, long toHigh) { return map(val, fromLow, fromHigh, toLow, toHigh); }

  // Serial
  void serial_begin(unsigned long baud) { Serial.begin(baud); }
  void serial_print(const char *str) { Serial.print(str); }
  void serial_println(const char *str) { Serial.println(str); }
  void serial_print_int(int val) { Serial.print(val); }
  void serial_println_int(int val) { Serial.println(val); }
  void serial_write_byte(uint8_t b) { Serial.write(b); }
  int serial_available() { return Serial.available(); }
  int serial_read() { return Serial.read(); }

}
