#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_LSM303_U.h>
#include "SmartBoat_Compass.h"

#define MAGNETIC_DECLINATION 6.23f // Adjust for your area
#define CALIBRATION 30 // You might need to adjust this if your compass readouts are as poopy as mine.

// This is the distance from a waypoint before we consider it "reached"
// The value was derived from doing the cartesian distance between 2 lat/lon points
// This distance is approximately a radius of 6 meters.
#define WAYPOINT_PROXIMITY 5

class Navigator
{
  public:
  void begin();
  
  void useInterrupt(boolean v);
  double getDistance(void);
  void setTarget(double lat, double lon);
  double readCompass(void);
  float getLat();
  float getLng();
  double getRelativeBearing(double* headingValue);
  bool hasFix();
  SmartBoat_Compass compass;
  
  private:  
  boolean usingInterrupt = false;
  double targetLat, targetLon;
};
