#include <Arduino.h>
#include <SoftwareSerial.h>

#include "Bluetooth.h"

int bluetoothTx = 5;
int bluetoothRx = 6;
SoftwareSerial bluetooth(bluetoothTx, bluetoothRx); 

SoftwareSerial Bluetooth::getInstance() {
  return bluetooth;
}
 
void Bluetooth::setup()
{
  Serial.println("Bluetooth setup started");
  bluetooth.begin(9600);
  while(!Serial){}

  Serial.write("AT sent");


  bluetooth.write("AT+POWE3");
  delay(200);

  bluetooth.write("AT+RESET");
  delay(200);

  bluetooth.write("AT+MODE0");
  delay(200);

  bluetooth.write("AT+CHAR0xAAA1,NOTIFY,1"); //add charicteristic
  delay(200);

  bluetooth.write("AT+NAMEFishingBoat"); //set name
  delay(200);

  bluetooth.write("AT+RELI1"); 
  delay(200);

  bluetooth.write("AT+SHOW1");
  delay(200);

  while(bluetooth.available()){
    String configResponse = (String)bluetooth.readString();
    Serial.print("Configuration received: ");
    Serial.println(configResponse);
  }

  Serial.println("Bluetooth setup finished");
}


String Bluetooth::read()
{
  String message = "";
  while(bluetooth.available()){
    message += bluetooth.readString();
  }  
  return message;
}


void Bluetooth::send(String toSend)
{
  bluetooth.print(toSend); // send data over characteristic   
}
