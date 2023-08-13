#include "Arduino.h"
#include <Wire.h>
#include "SmartBoat_Compass.h"
#include <avr/wdt.h>

#define DEBUG // enable serial output for debugging

bool SmartBoat_Compass::begin()
{
  // Initialize the magnetometer
  if(!bno.begin())
  {
   Serial.println("Ooops, no BNO055 detected ... Check your wiring or I2C ADDR!");
    while (1);
  }

  delay(1000);
  bno.setExtCrystalUse(true);

  adafruit_bno055_offsets_t calibrationData;
  storage.getCompassCalibration(&calibrationData);
  bno.setSensorOffsets(calibrationData);
}

void SmartBoat_Compass::calibrate()
{
  #ifdef DEBUG
    Serial.println("Start Calibration");
  #endif
  
  uint8_t system, gyro, accel, mag;
  system = gyro = accel = mag = 0;
  bno.getCalibration(&system, &gyro, &accel, &mag);
  sensors_event_t event;
  while(!bno.isFullyCalibrated()) {
    bno.getCalibration(&system, &gyro, &accel, &mag);
    bno.getEvent(&event);
    wdt_reset();
    Serial.print("system:");
    Serial.print(system, DEC);
    Serial.print(" gyro:");
    Serial.print(gyro, DEC);
    Serial.print(" accel:");
    Serial.print(accel, DEC);
    Serial.print(" mag:");
    Serial.println(mag, DEC);
    delay(100);
  }

  // Calibration is complete
  adafruit_bno055_offsets_t calibrationData;
  bno.getSensorOffsets(calibrationData);
  storage.setCompassCalibration(calibrationData);
  bno.setSensorOffsets(calibrationData);


  #ifdef DEBUG
    Serial.println("Calibrated Successfully");
  #endif
}

Vector SmartBoat_Compass::read(void)
{
  sensors_event_t event; 
  bno.getEvent(&event);
  //updateMinMax(event);
  
  v.XAxis= event.orientation.x;
  v.YAxis= event.orientation.y;
  v.ZAxis= event.orientation.z;

  return v;
}
