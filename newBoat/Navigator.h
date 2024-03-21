#include <Wire.h>
#include <Adafruit_Sensor.h>
//#include <Adafruit_LSM303_U.h>
#include "SmartBoat_Compass.h"

//#define MAGNETIC_DECLINATION 6.27 // Bucuresti
#define MAGNETIC_DECLINATION 6.2 // Pitesti
//#define MAGNETIC_DECLINATION 5.19 // Zabar
//#define CALIBRATION 0 // You might need to adjust this if your compass readouts are as poopy as mine.


struct TestLatLong {
  float lat;
  float lng;
};

class Navigator
{
  public:
  void begin();
  
  void useInterrupt(boolean v);
  double getDistance(void);
  void setTarget(double lat, double lon);
  
  void setCompassCalibration(int t);
  double readCompass(void);
  float getLat();
  float getLng();
  double getRelativeBearing(double* headingValue);
  bool hasFix();
  int WAYPOINT_PROXIMITY = 1;
  SmartBoat_Compass compass;
  
  private:  
  boolean usingInterrupt = false;
  double targetLat, targetLon;
  int CALIBRATION = 12;
  TestLatLong testData[18];
  int runningTestIndex = 0;
};
