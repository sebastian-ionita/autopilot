#include <EEPROMex.h>
#include <Arduino.h>
#include "Storage.h"

int getDoubleByteAddress(int address) {
  return address * 4;
}

void Storage::store(int address, double data) {
  int byteAddress = getDoubleByteAddress(address);
  double storedValue = EEPROM.readDouble(byteAddress);
  // Check if the new value is different from the stored value
  if (data != storedValue) {
    EEPROM.writeDouble(byteAddress, data);
  }
}

double Storage::read(int address) {  
  int byteAddress = getDoubleByteAddress(address);
  return EEPROM.readDouble(byteAddress);
}
