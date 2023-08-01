
#include <Arduino.h>
#include <SoftwareSerial.h>

#include "Bluetooth.h"

#define SOP1 '['
#define EOP1 ']'

int bluetoothTx = 5;
int bluetoothRx = 6;
SoftwareSerial bluetooth(bluetoothTx, bluetoothRx); 

char inData[200];
byte index;
bool started = false;
bool ended = false;
bool canSend = true;

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

  bluetooth.write("AT+ADVI9");
  delay(200);

  bluetooth.write("AT+FIOW1");
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


String Bluetooth::read(){
  String message = "";
  while(bluetooth.available()){
    message += bluetooth.readString();
  }  
  return message;
}

const char XON = 0x11; // ASCII code for XON (Resume transmission)
const char XOFF = 0x13; // ASCII code for XOFF (Pause transmission)

String Bluetooth::readString() {
 
  while (bluetooth.available())
  {
    char inChar = bluetooth.read();
    if (inChar == XON) {
      canSend = true;
    } else if (inChar == XOFF) {
      canSend = false;
    }
    if(inChar == SOP1)
    {
       index = 0;
       inData[index] = '\0';
       started = true;
       ended = false;
    }
    else if(inChar == EOP1)
    {
       ended = true;
       break;
    }
    else
    {
      if(index < 199)
      {
        inData[index] = inChar;
        index++;
        inData[index] = '\0';
      }
    }
  }
 
 if(started && ended)
  { 
    started = false;
    ended = false;
    index = 0;
   
    return inData;
  }

  return "";
}


void Bluetooth::send(String toSend) {
  if(canSend){
    bluetooth.print(toSend); // send data over characteristic   
  }
}

