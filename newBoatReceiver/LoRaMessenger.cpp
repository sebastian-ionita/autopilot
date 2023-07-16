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

void LoRaMessenger::send(String message)
{
  LoRa.beginPacket();
  LoRa.print(message);
  LoRa.endPacket();
  LoRa.receive();    
}
