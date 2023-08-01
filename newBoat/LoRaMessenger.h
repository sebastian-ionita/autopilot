#include <SPI.h>
#include <LoRa.h>

struct LoraLatLong {
  double lat;
  double lng;
  int tankLeft;
  int tankRight;
  int index;
};

class LoRaMessenger
{
  public:
  void begin(void (*onReceive)(int));
  void send(String message);
  double parseDouble(String message, String startMarker);
  int parseInt(String message, String startMarker);
  int parseInt(String message, String startMarker, String endMarker);
  LoraLatLong parseLatLong(String message, String startMarker);
  
  const String endMarker = "-*";
  const String CALIBRATE_MESSAGE = "CALIBRATE*";
  const String CLEAR_WAYPOINTS_MESSAGE = "CLEARWP*";
  const String REQUEST_WAYPOINTS_MESSAGE = "*3*";
  const String ADD_WAYPOINT_MESSAGE = "WP:";  
  const String SET_CALIBRATION_MESSAGE = "SC:";
  const String SET_SPEED_MESSAGE = "SP:";  
  const String REQUEST_WAYPOINTS = "GETWP*";  
  const String RESET_MESSAGE = "RESET*";
  
};
