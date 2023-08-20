#include <LoRa.h>
#include <SoftwareSerial.h>
#include <string.h>
#include "Bluetooth.h"
#include "LoRaMessenger.h"
#include <avr/wdt.h>

Bluetooth bluetoothModule;
LoRaMessenger loRaMessenger;

void setup() {
  Serial.begin(9600);
  bluetoothModule.setup();
  loRaMessenger.begin(onReceive);
  Serial.println("Setup completed");
  wdt_enable(WDTO_8S);
}

void onReceive(int packetSize) {
  // received a packet
  Serial.print("Received packet '");
  String message = "";

  // read packet
  for (int i = 0; i < packetSize; i++) {
    message += (char)LoRa.read();
  }

  Serial.print("Message to send: ");
  Serial.println(message);

  bluetoothModule.send(message);
  Serial.println("Sent via bluetooth module");
}

void loop()
{
  wdt_reset();
  String received = bluetoothModule.readString();
  if(received != ""){
    Serial.print(received);
    Serial.print(" ------> ");

    loRaMessenger.send(received);
  }
}

