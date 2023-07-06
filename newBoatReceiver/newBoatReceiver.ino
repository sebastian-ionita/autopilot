#include <LoRa.h>
#include <SoftwareSerial.h>
#include <string.h>
#include "Bluetooth.h"
#include "LoRaMessenger.h"


Bluetooth bluetoothModule;
LoRaMessenger loRaMessenger;

void setup() {
  Serial.begin(9600);
  bluetoothModule.setup();
  loRaMessenger.begin();
  LoRa.onReceive(onReceive);
  Serial.println("Setup completed");
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
    // register the receive callback
  /*bool sendBack = false;
  String received = bluetoothModule.read();
  if(received != ""){
    if(received.startsWith("SB:")){
      sendBack = true;
    }
    Serial.println("Finished reception on bluetooth");
  }
  if(sendBack){
       Serial.println("Sending data back");
       bluetoothModule.send("Send back");
       sendBack = false;
  }*/
  
  /*bluetoothModule.send("BL:44.953738, 18.624445*"); //1
  delay(200);
  bluetoothModule.send("LD:102|NE|67|90|100*"); //1
  delay(200);

  bluetoothModule.send("BL:44.953952, 18.624230*"); //2
  delay(200);
  bluetoothModule.send("LD:85|NE|55|85|100*"); //1
  delay(200);

  bluetoothModule.send("BL:44.954193, 18.624285*"); //3
  delay(200);
  bluetoothModule.send("LD:70|NE|45|70|100*"); //1
  delay(200);

  bluetoothModule.send("BL:44.954224, 18.624820*"); //4
  delay(200);
  bluetoothModule.send("LD:40|N|30|90|100*"); //1
  delay(200);

  bluetoothModule.send("BL:44.953936, 18.625225*"); //5
  delay(200);
  bluetoothModule.send("LD:27|N|15|90|60*"); //1
  delay(200);

  bluetoothModule.send("BL:44.953770, 18.624766*"); //6
  delay(200);
  bluetoothModule.send("LD:5|N|5|90|20*"); //1
  delay(200);*/

  //bluetoothModule.send("Finished sending all the locations baby but this is a very long message to see what bluetooth can do here*"); //6
  
}