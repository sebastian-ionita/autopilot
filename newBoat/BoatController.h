#include "Storage.h"

class BoatController
{
  public:
  BoatController();
  int adjustHeading(double relativeBearing, int speed);
  static void stopEngines(void);
  static void startEngines(void);
  void beginServo(void);
  void setCourseStabilisation(bool active);
  void setSpeed(int sp);
  void update(void);
  static void unloadLeftTank(void);
  static void unloadRightTank(void);
  static void unloadAllTanks(void);
  void setSteeringCalibration(int t);
  void setSteeringDelay(int t);
  int getSteeringCalibration(void);
  int getSteeringDelay(void);
  void calibrate(void);
  void startCalibration(void);


  private:
  int speed = 100;
  int signalSpeed = 100;
  void gas(void);
  static void openRightTank();
  static void closeRightTank();
  static void openLeftTank();
  static void closeLeftTank();  
  Storage storage;
};
