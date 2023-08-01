#include "Arduino.h"
#include <Wire.h>
#include "SmartBoat_Compass.h"
#include <avr/wdt.h>

#define DEBUG // enable serial output for debugging

bool SmartBoat_Compass::begin()
{
  // Initialize the magnetometer
  if (!magnetometer.begin() || !accel.begin())
  {
    Serial.println("Failed to initialize the LSM303 magnetometer!");
    while (1);
  }

  // Enable auto-ranging, defaults to +/- 1.3 gauss
  magnetometer.enableAutoRange(true);  
  initMinMax();
}

void SmartBoat_Compass::calibrate()
{
  float minLX, maxLX;
  float minLY, maxLY;
  float minLZ, maxLZ;

  sensors_event_t event;
  magnetometer.getEvent(&event);
  
  minLX = maxLX = event.magnetic.x;
  minLY = maxLY = event.magnetic.y;
  minLZ = maxLZ = event.magnetic.z;

  #ifdef DEBUG
    Serial.println("Start Calibration");
  #endif
  
  for (int i = 0; i < 3000; i++) { // rotate compas on all 3 axes for 30s
    wdt_reset();
    magnetometer.getEvent(&event);
    
    if (event.magnetic.x < minLX) minLX = event.magnetic.x;
    if (event.magnetic.x > maxLX) maxLX = event.magnetic.x;

    if (event.magnetic.y < minLY) minLY = event.magnetic.y;
    if (event.magnetic.y > maxLY) maxLY = event.magnetic.y;

    if (event.magnetic.z < minLZ) minLZ = event.magnetic.z;
    if (event.magnetic.z > maxLZ) maxLZ = event.magnetic.z;

    delay(10);
  }
  storage.setCompassMinXCalibration(minLX);
  storage.setCompassMaxXCalibration(maxLX);
  
  storage.setCompassMinYCalibration(minLY);
  storage.setCompassMaxYCalibration(maxLY);
  
  storage.setCompassMinZCalibration(minLZ);
  storage.setCompassMaxZCalibration(maxLZ);
  
  initMinMax();

  #ifdef DEBUG
    Serial.println("Calibrated Successfully");

    Serial.print("MinX: ");
    Serial.println(minLX);
    Serial.print("MaxX: ");
    Serial.println(maxLX);
    
    Serial.print("MinY: ");
    Serial.println(minLY);
    Serial.print("MaxY: ");
    Serial.println(maxLY);
    
    Serial.print("MinZ: ");
    Serial.println(minLZ);
    Serial.print("MaxZ: ");
    Serial.println(maxLZ);
  #endif
}

void SmartBoat_Compass::initMinMax()
{
  minX = storage.getCompassMinXCalibration();
  maxX = storage.getCompassMaxXCalibration();

  minY = storage.getCompassMinYCalibration();
  maxY = storage.getCompassMaxYCalibration();

  minZ = storage.getCompassMinZCalibration();
  maxZ = storage.getCompassMaxZCalibration();
}

void SmartBoat_Compass::updateMinMax(sensors_event_t event) {
  if (event.magnetic.x < minX) minX = event.magnetic.x;
  if (event.magnetic.x > maxX) maxX = event.magnetic.x;

  if (event.magnetic.y < minY) minY = event.magnetic.y;
  if (event.magnetic.y > maxY) maxY = event.magnetic.y;

  if (event.magnetic.z < minZ) minZ = event.magnetic.z;
  if (event.magnetic.z > maxZ) maxZ = event.magnetic.z;
}

Vector SmartBoat_Compass::read(void)
{
  sensors_event_t event;
  magnetometer.getEvent(&event);
  updateMinMax(event);
  
  v.XAxis= map(event.magnetic.x, minX, maxX, -360,360);
  v.YAxis= map(event.magnetic.y, minY, maxY, -360,360);
  v.ZAxis= map(event.magnetic.z, minZ, maxZ, -360,360);

  return v;
}

VectorAccel SmartBoat_Compass::readAccel(void)
{
  sensors_event_t event;
  accel.getEvent(&event);
  
  vAccel.XAxis = event.acceleration.x;
  vAccel.YAxis = event.acceleration.y;
  vAccel.ZAxis = event.acceleration.z;

  return vAccel;
}
