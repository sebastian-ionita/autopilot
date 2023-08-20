#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>
#include "Storage.h"

struct Vector
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
  void calibrate(void);

  Adafruit_BNO055 bno = Adafruit_BNO055(55, 0x29);


private:
  Vector v;
  Storage storage;
};
