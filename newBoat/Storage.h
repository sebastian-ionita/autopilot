#include <EEPROMex.h>
#include <Adafruit_BNO055.h>

class Storage
{
  public:
  double read(int address);  
  void setCompassCalibration(adafruit_bno055_offsets_t &calibrationData);
  void getCompassCalibration(adafruit_bno055_offsets_t *calibrationData);

  private:
  void store(int address, double data);  
};
