#if ARDUINO >= 100
#include "Arduino.h"
#else
#include "WProgram.h"
#endif

#include <Wire.h>
#include "SmartBoat_Compass.h"

bool SmartBoat_Compass::begin()
{
  // Initialize the magnetometer
  if (!magnetometer.begin())
  {
    Serial.println("Failed to initialize the LSM303 magnetometer!");
    while (1);
  }

  // Enable auto-ranging, defaults to +/- 1.3 gauss
  magnetometer.enableAutoRange(true);
}

void SmartBoat_Compass::calibrate()
{
  if(v.XAxis < minX ) minX = v.XAxis;
  if(v.XAxis > maxX ) maxX = v.XAxis;

  if(v.YAxis < minY ) minY = v.YAxis;
  if(v.YAxis > maxY ) maxY = v.YAxis;

  if(v.ZAxis < minZ ) minZ = v.ZAxis;
  if(v.ZAxis > maxZ ) maxZ = v.ZAxis;
}

void SmartBoat_Compass::initMinMax()
{
  minX = v.XAxis;
  maxX = v.XAxis;

  minY = v.YAxis;
  maxY = v.YAxis;

  minZ = v.ZAxis;
  maxZ = v.ZAxis;
}

Vector SmartBoat_Compass::readAutoCalibrated(void)
{

  sensors_event_t event;
  magnetometer.getEvent(&event);

  av.XAxis = event.magnetic.x - autocalibrationOffsets.XAxis;
  av.YAxis = event.magnetic.y - autocalibrationOffsets.YAxis;
  av.ZAxis = event.magnetic.z - autocalibrationOffsets.ZAxis;

  return av;
}

Vector SmartBoat_Compass::readAndCalibrate(void)
{
  sensors_event_t event;
  magnetometer.getEvent(&event);

  int range = 10;
  float Xsum = 0.0;
  float Ysum = 0.0;
  float Zsum = 0.0;
  while (range--){
    v.XAxis = event.magnetic.x;
    v.YAxis = event.magnetic.y;
    v.ZAxis = event.magnetic.z;
    Xsum += v.XAxis;
    Ysum += v.YAxis;
    Zsum += v.ZAxis;
  }
  v.XAxis = Xsum/range;
  v.YAxis = Ysum/range;
  v.ZAxis = Zsum/range;
  if(firstRun){
    initMinMax();
    firstRun = false;
  }

  calibrate();

  v.XAxis= map(v.XAxis, minX, maxX, -360,360);
  v.YAxis= map(v.YAxis, minY, maxY, -360,360);
  v.ZAxis= map(v.ZAxis, minZ, maxZ, -360,360);

  return v;
}

// Constants for auto-calibration
const int CALIBRATION_SAMPLES = 250;
const int CALIBRATION_DELAY_MS = 100;

void SmartBoat_Compass::setOffsets(float offsetX, float offsetY, float offsetZ) {
    autocalibrationOffsets.XAxis = offsetX;
    autocalibrationOffsets.YAxis = offsetY;
    autocalibrationOffsets.ZAxis = offsetZ;

    Serial.println("Calibration offsets.");
    Serial.print("X: ");
    Serial.print(offsetX);
    Serial.print(" Y: ");
    Serial.print(offsetY);
    Serial.print(" Z: ");
    Serial.println(offsetZ);
}

void SmartBoat_Compass::calibrateMagnetometer(float *offsetX, float *offsetY, float *offsetZ)
{
  Serial.println("Auto - Calibrating magnetometer...");
  
  // Variables for summing calibration samples
  float sumX = 0.0;
  float sumY = 0.0;
  float sumZ = 0.0;
  
  // Collect calibration samples
  for (int i = 0; i < CALIBRATION_SAMPLES; i++)
  {
    sensors_event_t event;
    magnetometer.getEvent(&event);
    
    sumX += event.magnetic.x;
    sumY += event.magnetic.y;
    sumZ += event.magnetic.z;
    
    delay(CALIBRATION_DELAY_MS);
  }
  
  // Calculate calibration offsets
  *offsetX = sumX / CALIBRATION_SAMPLES;
  *offsetY = sumY / CALIBRATION_SAMPLES;
  *offsetZ = sumZ / CALIBRATION_SAMPLES;
  
  Serial.println("Calibration complete.");
}


