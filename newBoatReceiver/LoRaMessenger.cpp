#include <SPI.h>
#include <LoRa.h>
#include "LoRaMessenger.h"

/*******************************************************************************************/

void LoRaMessenger::begin(void (*onReceive)(int))
{
  if (!LoRa.begin(433E6)) {             // initialize ratio at 915 MHz
    Serial.println("LoRa init failed. Check your connections.");
    while (true);                       // if failed, do nothing
  }
  LoRa.setTxPower(20);
  LoRa.onReceive(onReceive);
  LoRa.receive();
  Serial.println("Lora initialized");
}

/*******************************************************************************************/

void LoRaMessenger::onReceive(int packetSize)
{
    // received a packet
  Serial.print("Received packet '");

  // read packet
  for (int i = 0; i < packetSize; i++) {
    Serial.print((char)LoRa.read());
  }

  // print RSSI of packet
  Serial.print("' with RSSI ");
  Serial.println(LoRa.packetRssi());
  
}

/*******************************************************************************************/


const char XON = 0x11; // ASCII code for XON (Resume transmission)
const char XOFF = 0x13; // ASCII code for XOFF (Pause transmission)

void askStopTransmission(){
  //send XOFF to stop boat transmission
  for(int i=0; i < 5; i++){
    LoRa.beginPacket();
    LoRa.print("XOFF*");
    LoRa.endPacket();
  }
  LoRa.receive();  
  Serial.println("Asked boat to STOP Lora trsnamission");
}

void askStartTransmission(){
  //send XON to start boat transmission
  for(int i=0; i < 5; i++){
    LoRa.beginPacket();
    LoRa.print("XON*");
    LoRa.endPacket();
  }
  LoRa.receive();  

  Serial.println("Asked boat to START Lora trsnamission");
}

void LoRaMessenger::send(String message)
{
  //askStopTransmission();

  LoRa.beginPacket();
  LoRa.print(message);
  LoRa.endPacket();

  Serial.print("Sent via lora: ");
  Serial.println(message);

  LoRa.receive();    

  //askStartTransmission();
}
