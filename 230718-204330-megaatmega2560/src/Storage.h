#include <EEPROMex.h>

class Storage
{
  public:
  double read(int address);
  
  double getCompassMinXCalibration(); 
  double getCompassMaxXCalibration();
  double getCompassMinYCalibration(); 
  double getCompassMaxYCalibration();
  double getCompassMinZCalibration(); 
  double getCompassMaxZCalibration();

  void setCompassMinXCalibration(double value); 
  void setCompassMaxXCalibration(double value);
  void setCompassMinYCalibration(double value); 
  void setCompassMaxYCalibration(double value);
  void setCompassMinZCalibration(double value); 
  void setCompassMaxZCalibration(double value);

  private:
  void store(int address, double data);  
};
