#include "libraries/Timer-2.1/Timer.h"
#define MAX_WAYPOINTS 20

struct Waypoint
{
  double lat, lon;
  int tankLeft, tankRight;
};

class Path
{
  public:
  void addWaypoint(double lat, double lon, int tankLeft, int tankRight);
  double getLat(void);
  double getLon(void);
  int getSpeed(void);
  void nextWaypoint(
    void (*leftTankAction)(void), 
    void (*rightTankAction)(void), 
    void (*allTanksAction)(void), 
    void (*stopEnginesAction)(void), 
    void (*startEnginesAction)(void)
    );
  bool hasWaypoints(void);
  void clearWaypoints(void);
  
  private:
  int WAIT_AFTER_TANK_UNLOAD = 3000;
  Waypoint waypoints[MAX_WAYPOINTS];
  int store_index = 0; // Used while adding waypoints
  static int running_index; // Used while traversing waypoints
  
};
