//#include <SoftwareServo.h>

// PWM motor speeds
#define FAST 100
#define SLOW 100

class BoatController
{
  public:
  BoatController(int servoPin, int motorPin);
  int adjustHeading(double relativeBearing, int speed);
  void stopEngines(int servoPin);
  void beginServo(void);
 //SoftwareServo servo;
  
  private:
  int leftEnginePin;
  int rightEnginePin;
  int motorPin;
  //SoftwareServo servo;
};
