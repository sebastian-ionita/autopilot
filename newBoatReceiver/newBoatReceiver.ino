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
  //message += "*";

  Serial.print("Message to send: ");
  Serial.println(message);

  bluetoothModule.send(message);
  Serial.println("Sent via bluetooth module");
}

void loop()
{
  wdt_reset();
  String received = bluetoothModule.read();
  if(received != ""){
    Serial.println("------");
    Serial.println(received);
    Serial.println("------");
    //String received2 = bluetoothModule.read();
    //Serial.print("Extra:");
    //Serial.println(received2);
    int prevIndex = 0;
    int currentIndex;
    while ((currentIndex = received.indexOf('*', prevIndex)) != -1) {  // Find the next *
      Serial.println(received.substring(prevIndex, currentIndex));  // Extract and print the substring
      loRaMessenger.send(received.substring(prevIndex, currentIndex) + "*");
      prevIndex = currentIndex + 1;  // Update the previous index to the current index
      delay(500);
    }
    
    loRaMessenger.send(received.substring(prevIndex) + "*");
    Serial.println("------");
    //Serial.println(received.substring(prevIndex));
    //loRaMessenger.send(p);
    //Serial.println("Finished reception on bluetooth");
  }
  
}
