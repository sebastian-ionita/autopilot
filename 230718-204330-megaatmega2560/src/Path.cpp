#include <Arduino.h>
#include "Path.h"
#include "libraries/Timer-2.1/Timer.h"

/*******************************************************************************************/

int Path::running_index = 0;

void Path::addWaypoint(double lat, double lon, int tankLeft, int tankRight, int index)
{
  if(store_index >= MAX_WAYPOINTS) {
    return;
  }
  //Serial.println("added");
  waypoints[index].lat = lat;
  waypoints[index].lon = lon;
  waypoints[index].tankLeft = tankLeft;
  waypoints[index].tankRight = tankRight;

  if(store_index <= index) {
    store_index = index + 1;
  }
}

String Path::getWaypointsMessage() {
  // SW:<index>|<leftTank>|<rightTank>@<index>|<leftTank>|<rightTank>@*
  String message = "SW:";
  for (int i = 0; i < MAX_WAYPOINTS; i++) {
    if(waypoints[i].lat != 0.00 && waypoints[i].tankLeft != -1) {
      message += String(i) + "|" + String(waypoints[i].tankLeft) + "|" + String(waypoints[i].tankRight) + "@";
    }
  }
  return message += "*";
}

/*******************************************************************************************/

double Path::getLat()
{
  return waypoints[running_index].lat;  
}

/*******************************************************************************************/

double Path::getLon()
{
  return waypoints[running_index].lon;
}

/*******************************************************************************************/

void Path::nextWaypoint(
  void (*leftTankAction)(void), 
  void (*rightTankAction)(void),
  void (*unloadAllTanks)(void),
  void (*stopEnginesAction)(void), 
  void (*startEnginesAction)(void)
  ) {
  int currentRunningIndex = running_index;
  stopEnginesAction();

  if(waypoints[currentRunningIndex].tankLeft == 1 && waypoints[currentRunningIndex].tankRight == 0) {
    leftTankAction();
  }

  if(waypoints[currentRunningIndex].tankRight == 1 && waypoints[currentRunningIndex].tankLeft == 0) {
    rightTankAction();
  }

  if(waypoints[currentRunningIndex].tankLeft == 1 && waypoints[currentRunningIndex].tankRight == 1) {
    unloadAllTanks();
  }

  if(waypoints[currentRunningIndex].tankLeft == 1 || waypoints[currentRunningIndex].tankRight == 1) {
    delay(WAIT_AFTER_TANK_UNLOAD);
    running_index++;
    startEnginesAction();
    return;
  }
  running_index++;
  startEnginesAction();
}

bool Path::hasWaypoints()
{
  return running_index < store_index;
}

void Path::clearWaypoints()
{
  store_index = 0;
  running_index = 0;
  for (int i = 0; i < MAX_WAYPOINTS; i++) {
    waypoints[i] = {};
  }
}

int Path::getRunningIndex()
{
  return running_index;  
}
