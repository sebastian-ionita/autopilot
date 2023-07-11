#include <EEPROMex.h>
#include <Arduino.h>
#include "Storage.h"

void Storage::store(int address, double data) {
  double storedValue = EEPROM.readDouble(address);
  Serial.println("bla");
  Serial.println(storedValue);
  // Check if the new value is different from the stored value
  if (data != storedValue) {
    EEPROM.writeDouble(address, data);
  }
}

double Storage::read(int address) {
  return EEPROM.readDouble(address);
}
