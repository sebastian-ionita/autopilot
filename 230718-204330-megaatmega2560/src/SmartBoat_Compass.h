#include <Adafruit_Sensor.h>
#include <Adafruit_LSM303_U.h>
#include "Storage.h"

struct Vector
{
  float XAxis;
  float YAxis;
  float ZAxis;
};
struct VectorAccel
{
  float XAxis;
  float YAxis;
  float ZAxis;
};

class SmartBoat_Compass
{
public:
  bool begin(void);
  Vector read(void);  
  VectorAccel readAccel(void);  
  void calibrate(void);
  void initMinMax();
  void updateMinMax(sensors_event_t event);

  // Create an instance of the LSM303 sensor
  Adafruit_LSM303_Mag_Unified magnetometer = Adafruit_LSM303_Mag_Unified(12345);
  Adafruit_LSM303_Accel_Unified accel = Adafruit_LSM303_Accel_Unified(54321);


private:
  Vector v;
  VectorAccel vAccel;
  Storage storage;
  float minX, maxX;
  float minY, maxY;
  float minZ, maxZ;
};
