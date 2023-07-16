#include "Path.h"

/*******************************************************************************************/

void Path::addWaypoint(double lat, double lon)
{
  if(store_index >= MAX_WAYPOINTS) {
    return;
  }
  waypoints[store_index].lat = lat;
  waypoints[store_index].lon = lon;
  store_index++;
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

void Path::nextWaypoint()
{
  running_index++;
}

/*******************************************************************************************/

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
