
// Everything that was included in the other files had to also be included here to work for some reason
#include <TinyGPS++.h>
#include <SoftwareSerial.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>
#include <avr/sleep.h>
#include <SPI.h>
#include <LoRa.h>
#include <IBusBM.h>
#include <avr/wdt.h>
#include <EEPROMex.h>

// *** Includes ***
#include "BoatController.h"
#include "Navigator.h"
#include "Path.h"
#include "Beeper.h"
#include "LoRaMessenger.h"
#include "Timer.h"

#define BEEPER_PIN 5
#define DEBUG // Enables serial output feedback for basic functions
//#define WAIT_FIX // Disable GPS fis for debugging

// *** Globals ***
Navigator nav;
BoatController controller;
Path path;
Beeper beeper;
LoRaMessenger loRaMessenger;

Timer timer;

double distance = 0;
int motorSpeed = 0;
int servoValue = 0;
double relativeBearing = 0;
double headingDegrees = 0;

void setup()
{  
  Serial.println("Setup started");
  wdt_enable(WDTO_8S);
   
  loRaMessenger.begin(onReceiveLora);  
  nav.begin();  
  beeper.begin(BEEPER_PIN);
  controller.beginServo(); 

  path.addWaypoint(44.40375040589921, 26.106770300233578);
  path.addWaypoint(44.404244863681654, 26.10776210470905);
  
  
  #ifdef DEBUG
    Serial.begin(9600);
  #endif

  #ifdef WAIT_FIX
    while(!nav.hasFix()) {
      wdt_reset();
      Serial.println("Waiting for fix...");
    }
  #endif
  Serial.println("Got a GPS fix");  
  
  beeper.beep3(); // A happy little 3 chirps to know we have fix  

  //every 1 second, send boat live data to received on the mobile
  timer.every(1000, sendBoatLiveData, (void*)4);
  

  Serial.println("Setup finished");  
  
}

void loop()
{
  Serial.println("Loop cycle");
  wdt_reset();
  timer.update();  
  // While we still have waypoints to reach
  while(path.hasWaypoints())
  {    
    
    wdt_reset();
    timer.update();

    // Lock in the current waypoint
    nav.setTarget(path.getLat(), path.getLon());

    // While we haven't reached waypoint
    distance = nav.getDistance();
    while(distance > WAYPOINT_PROXIMITY)
    {
      wdt_reset();
      timer.update();
      //Serial.print(nav.getRelativeBearing()); 
      // Get the relative bearing to adjust the motors accordingly
      relativeBearing = nav.getRelativeBearing(&headingDegrees); //heading degrees is passed as pointer reference to be able to set it from within the method
      motorSpeed = getSpeedFromDistance(distance);
      servoValue = controller.adjustHeading(relativeBearing, motorSpeed);      
      #ifdef DEBUG
        //Serial.print("Distance: "); 
        //Serial.println(nav.getDistance());
        //delay(500);
      #endif     
    }    
    
    // Waypoint reached
    loRaMessenger.send("INFO:Waypoint reached"); 
    #ifdef DEBUG
    Serial.println("\nWAYPOINT REACHED!!!");
    beeper.beep3();
    #endif
    path.nextWaypoint(); 
  }
  
  
  // All waypoints reached
  controller.stopEngines();
  
  // Shutdown
  cli(); // Disable interrupts
  sleep_enable();
  sleep_cpu();
  
}

int getSpeedFromDistance(double distance) {
  //distance in meters
  if(distance >= 25)
    return 80; //highest value
  if(distance >= 20)
    return 70;
  if(distance >= 15)
    return 50;
  if(distance >= 10)
    return 35;
  return 20;  
}

void sendBoatLiveData(void* context) {  
  String liveData = "LD:";
  liveData += distance;
  liveData += "|"; //value divider
  liveData += headingDegrees; //HARDCODED HEADING FOR NOW
  liveData += "|"; //value divider
  liveData += relativeBearing;
  liveData += "|"; //value divider
  liveData += servoValue;
  liveData += "|"; //value divider
  liveData += motorSpeed;
  liveData += "|"; //value location
  liveData += String(nav.getLat(), 8);
  liveData += ",";
  liveData += String(nav.getLng(), 8);
  liveData += "*"; //this char will say that the here the sent package ends, and the message can be processed
  //Serial.println(liveData);
  
  loRaMessenger.send(liveData); 
}


void onReceiveLora(int packetSize)
{
    // received a packet
  Serial.print("Received packet: ");
  String message = "";

  // read packet
  for (int i = 0; i < packetSize; i++) {
    message += (char)LoRa.read();
  }

  Serial.println(message);
  if(message == loRaMessenger.CALIBRATE_MESSAGE) {
    Serial.println("CALIBRATE_MESSAGE");
    beeper.beep(1000);
    nav.compass.calibrate();
    beeper.beep3();
  }
  
  if(message == loRaMessenger.CLEAR_WAYPOINTS_MESSAGE) {
    Serial.println("CLEAR_WAYPOINTS_MESSAGE");
    beeper.beep(500);
    path.clearWaypoints();
  }
  
  if(message.indexOf(loRaMessenger.SET_SPEED_MESSAGE) >= 0) {
    Serial.println("SET_SPEED_MESSAGE");
    int speed = loRaMessenger.parseInt(message, loRaMessenger.SET_SPEED_MESSAGE);
    if(speed != -1) {
      beeper.beep(500);
      controller.setSpeed(speed);
    }    
  }
  
  if(message.indexOf(loRaMessenger.ADD_WAYPOINT_MESSAGE) >= 0) {
    Serial.println("ADD_WAYPOINT_MESSAGE");
    LoraLatLong coordinates = loRaMessenger.parseLatLong(message, loRaMessenger.ADD_WAYPOINT_MESSAGE);
    if(coordinates.lat != 0.00 && coordinates.lng != 0.00) {
      beeper.beep(500);
      path.addWaypoint(coordinates.lat, coordinates.lng);
    }
  }
  
}
