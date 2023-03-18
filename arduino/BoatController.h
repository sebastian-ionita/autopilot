//#include <SoftwareServo.h>

// PWM motor speeds
#define FAST 255
#define SLOW 255

class BoatController
{
  public:
  BoatController(int servoPin);
  void adjustHeading(double relativeBearing, int speed);
  void stopEngines(void);
  void beginServo(void);
 //SoftwareServo servo;
  
  private:
  int leftEnginePin;
  int rightEnginePin;
  //SoftwareServo servo;
};
