class BoatController
{
  public:
  BoatController();
  int adjustHeading(double relativeBearing, int speed);
  void stopEngines();
  void beginServo(void);
  void setSpeed(int sp);

  private:
  int speed = 80;
  void gas(void);
};
