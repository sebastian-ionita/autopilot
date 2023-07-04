//#include <Adafruit_GPS.h>
#include <Wire.h>
//#include <Adafruit_LSM303.h>


//#include <Adafruit_Sensor.h>
//#include <Adafruit_HMC5883_U.h>
#include <DFRobot_QMC5883.h>
//DFRobot_QMC5883 compass;

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
  double getRelativeBearing(void);
  bool hasFix();
  
  private:
  //Adafruit_LSM303 lsm;
  DFRobot_QMC5883 compass;
  //Adafruit_HMC5883_Unified mag = Adafruit_HMC5883_Unified(12345);
  boolean usingInterrupt = false;
  double targetLat, targetLon;
};
