#include <EEPROMex.h>
#include <Arduino.h>
#include "Storage.h"

#define COMPASS_MINX_ADDRESS 0
#define COMPASS_MAXX_ADDRESS 1

#define COMPASS_MINY_ADDRESS 2
#define COMPASS_MAXY_ADDRESS 3

#define COMPASS_MINZ_ADDRESS 4
#define COMPASS_MAXZ_ADDRESS 5


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


double Storage::getCompassMinXCalibration() {
  return read(COMPASS_MINX_ADDRESS);
}
double Storage::getCompassMaxXCalibration() {
  return read(COMPASS_MAXX_ADDRESS);
}
double Storage::getCompassMinYCalibration() {
  return read(COMPASS_MINY_ADDRESS);
} 
double Storage::getCompassMaxYCalibration() {
  return read(COMPASS_MAXY_ADDRESS);
}
double Storage::getCompassMinZCalibration() {
  return read(COMPASS_MINZ_ADDRESS);
} 
double Storage::getCompassMaxZCalibration() {
  return read(COMPASS_MAXZ_ADDRESS);
}

void Storage::setCompassMinXCalibration(double value) {
  store(COMPASS_MINX_ADDRESS, value);
}
void Storage::setCompassMaxXCalibration(double value) {  
  store(COMPASS_MAXX_ADDRESS, value);
}
void Storage::setCompassMinYCalibration(double value) {
  store(COMPASS_MINY_ADDRESS, value);
}
void Storage::setCompassMaxYCalibration(double value) {
  store(COMPASS_MAXY_ADDRESS, value);
}
void Storage::setCompassMinZCalibration(double value) {
  store(COMPASS_MINZ_ADDRESS, value);
}
void Storage::setCompassMaxZCalibration(double value) {
  store(COMPASS_MAXZ_ADDRESS, value);
}
