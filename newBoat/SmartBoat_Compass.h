#include <Adafruit_Sensor.h>
#include <Adafruit_LSM303_U.h>

struct Vector
{
  float XAxis;
  float YAxis;
  float ZAxis;
};

class SmartBoat_Compass
{
public:
  SmartBoat_Compass(): minX(0), maxX(0), minY(0), maxY(0), minZ(0), maxZ(0), firstRun(true)
    {}

  bool begin(void);

  Vector readAutoCalibrated(void);
  Vector readAndCalibrate(void);
  
  void initMinMax();
  void calibrate(void);
  void calibrateMagnetometer(float *offsetX, float *offsetY, float *offsetZ);
  void setOffsets(float x, float y, float z);

  // Create an instance of the LSM303 sensor
  Adafruit_LSM303_Mag_Unified magnetometer = Adafruit_LSM303_Mag_Unified(12345);

private:
  Vector v, av;
  Vector autocalibrationOffsets;
  float minX, maxX;
  float minY, maxY;
  float minZ, maxZ;
  bool firstRun;
};