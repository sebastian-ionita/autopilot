#include <SPI.h>
#include <LoRa.h>

class LoRaMessenger
{
  public:
  void begin(void);
  static void onReceive(int packetSize);
  void send(String message);
  
};
