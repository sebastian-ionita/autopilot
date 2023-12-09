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
  bool canSendLiveData = false;
  
  const String endMarker = "-*";
  const String CALIBRATE_MESSAGE = "CALIBRATE*";
  const String CLEAR_WAYPOINTS_MESSAGE = "CLEARWP*";
  const String ADD_WAYPOINT_MESSAGE = "WP:";  
  const String SET_CALIBRATION_MESSAGE = "SC:";
  const String SET_PROXIMITY_MESSAGE = "SP:";    
  const String SET_STEERING_DELAY_MESSAGE = "SD:";  
  const String REQUEST_WAYPOINTS = "GETWP*";  
  const String RESET_MESSAGE = "RESET*";  
  const String XON = "XON*";   
  const String XOFF = "XOFF*";  
  const String REQUEST_DATA = "GETD*";  
  const String REQUEST_CONFIG = "GETC*";
  const String START = "START:";
  const String STOP = "STOP*";
  const String STOP_AND_RETURN = "STOP:";
  const String GET_LOCATION = "GETL*";
  
};
