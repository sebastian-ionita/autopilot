
#include <Arduino.h>

class Bluetooth
{
  public:
  SoftwareSerial getInstance();
  void setup();
  String read(void);
  void send(String toSend);
  
};
