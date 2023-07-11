// PWM motor speeds
#define FAST 100
#define SLOW 100

class BoatController
{
  public:
  BoatController();
  int adjustHeading(double relativeBearing, int speed);
  void stopEngines();
  void beginServo(void);
};
