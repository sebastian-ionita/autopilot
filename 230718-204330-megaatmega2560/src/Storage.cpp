#include <EEPROMex.h>
#include <Arduino.h>
#include "Storage.h"

#define COMPASS_AX_ADDRESS 0
#define COMPASS_AY_ADDRESS 1
#define COMPASS_AZ_ADDRESS 2

#define COMPASS_MX_ADDRESS 3
#define COMPASS_MY_ADDRESS 4
#define COMPASS_MZ_ADDRESS 5

#define COMPASS_GX_ADDRESS 6
#define COMPASS_GY_ADDRESS 7
#define COMPASS_GZ_ADDRESS 8

#define COMPASS_AR_ADDRESS 9
#define COMPASS_MR_ADDRESS 10


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

void Storage::setCompassCalibration(adafruit_bno055_offsets_t &calibrationData) {
  store(COMPASS_AX_ADDRESS, calibrationData.accel_offset_x);
  store(COMPASS_AY_ADDRESS, calibrationData.accel_offset_y);
  store(COMPASS_AZ_ADDRESS, calibrationData.accel_offset_z);
  
  store(COMPASS_MX_ADDRESS, calibrationData.mag_offset_x);
  store(COMPASS_MY_ADDRESS, calibrationData.mag_offset_y);
  store(COMPASS_MZ_ADDRESS, calibrationData.mag_offset_z);
  
  store(COMPASS_GX_ADDRESS, calibrationData.gyro_offset_x);
  store(COMPASS_GY_ADDRESS, calibrationData.gyro_offset_y);
  store(COMPASS_GZ_ADDRESS, calibrationData.gyro_offset_z);

  store(COMPASS_AR_ADDRESS, calibrationData.accel_radius);
  store(COMPASS_MR_ADDRESS, calibrationData.mag_radius);
}


void Storage::getCompassCalibration(adafruit_bno055_offsets_t *calibrationData) {
  calibrationData->accel_offset_x = read(COMPASS_AX_ADDRESS);
  calibrationData->accel_offset_y = read(COMPASS_AY_ADDRESS);
  calibrationData->accel_offset_z = read(COMPASS_AZ_ADDRESS);
  
  calibrationData->mag_offset_x = read(COMPASS_MX_ADDRESS);
  calibrationData->mag_offset_y = read(COMPASS_MY_ADDRESS);
  calibrationData->mag_offset_z = read(COMPASS_MZ_ADDRESS);
  
  calibrationData->gyro_offset_x = read(COMPASS_GX_ADDRESS);
  calibrationData->gyro_offset_y = read(COMPASS_GY_ADDRESS);
  calibrationData->gyro_offset_z = read(COMPASS_GZ_ADDRESS);
  
  calibrationData->accel_radius = read(COMPASS_AR_ADDRESS);
  calibrationData->mag_radius = read(COMPASS_MR_ADDRESS);
}
