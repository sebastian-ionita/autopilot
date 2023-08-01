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
#include "BoatController.h"
#include "Navigator.h"
#include "Path.h"
#include "Beeper.h"
#include "LoRaMessenger.h"
#include "libraries/Timer-2.1/Timer.h"

#define BEEPER_PIN 5
//#define DEBUG // Enables serial output feedback for basic functions
#define WAIT_FIX // Disable GPS fix for debugging
//#define TEST_DATA;

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
  
  Serial.begin(9600);
  Serial.println("Setup started");
  wdt_enable(WDTO_8S);
   
  loRaMessenger.begin(onReceiveLora);  
  nav.begin();  
  beeper.begin(BEEPER_PIN);
  controller.beginServo(); 
  controller.startEngines();

  path.addWaypoint(44.40476466439481, 26.106513105501197, 1, 1, 0); //test path1
  //path.addWaypoint(44.404753960198214, 26.10668608266575, 1, 0);//test path2
  //path.addWaypoint(44.40507764703135, 26.10763937205082, 0, 1, 0); // Daimon dreapta
  //path.addWaypoint(44.404646468815955, 26.10735369565071, 1, 0, 1); // Daimon stanga
  //path.addWaypoint(44.404611109453214, 26.108126680998154, 0, 0, 2); // Daimon home

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
  //timer.after(3000, sendBoatLiveData, (void*)0);
  //timer.after(3200, addWaypoint2, (void*)0);
  //timer.after(3000, nextWaypoint, (void*)0);
  //timer.after(6000, nextWaypoint, (void*)0);
  //timer.after(13000, nextWaypoint, (void*)0);
  

  Serial.println("Setup finished");  
  
}

void loop()
{
  Serial.println("Loop cycle");
  wdt_reset();
  timer.update();
  controller.update();   
  
  while(path.hasWaypoints())
  {    
    controller.startEngines();
    wdt_reset();
    timer.update();
    controller.update();

    // Lock in the current waypoint
    nav.setTarget(path.getLat(), path.getLon());

    // While we haven't reached waypoint
    #ifndef TEST_DATA
        distance = nav.getDistance();
    #endif 
    #ifdef TEST_DATA
        distance = 100;
    #endif 
    
    while(distance > WAYPOINT_PROXIMITY)
    {
      distance = nav.getDistance();
      wdt_reset();
      timer.update();
      controller.update();

      relativeBearing = nav.getRelativeBearing(&headingDegrees); //heading degrees is passed as pointer reference to be able to set it from within the method
      motorSpeed = getSpeedFromDistance(distance);
      servoValue = controller.adjustHeading(relativeBearing, motorSpeed);      

      #ifdef DEBUG
      Serial.print("distance: ");
      Serial.println(distance);
      Serial.print("headingDegrees: ");
      Serial.println(headingDegrees);
      Serial.print("relativeBearing: ");
      Serial.println(relativeBearing);
      Serial.print("servoValue: ");
      Serial.println(servoValue);
      Serial.print("motorSpeed: ");
      Serial.println(motorSpeed);
      Serial.println("------------");
      delay(1000);
      #endif     
    }    
    
    // Waypoint reached
    loRaMessenger.send("N:Waypoint reached"); 
    nextWaypoint(0);
    #ifdef DEBUG
    Serial.println("\nWAYPOINT REACHED!!!");
    beeper.beep3();
    #endif
    //path.nextWaypoint(controller.unloadLeftTank, controller.unloadRightTank, controller.startEngines, controller.stopEngines); 
  }  
  
  // All waypoints reached
  controller.stopEngines();
  
  // Shutdown
  //cli(); // Disable interrupts
  //sleep_enable();
  //sleep_cpu();
  
}

int getSpeedFromDistance(double distance) {
  //distance in meters
  if(distance >= 10) {
    return 100; //highest value
  }
  return 50;  
}

void addWaypoint(void* context) {  
  Serial.println("Add waypoint");
  //path.addWaypoint(44.40533550476172, 26.107248736699017, 0, 1);
  //LoraLatLong coordinates = loRaMessenger.parseLatLong("WP:123.22@,33.44||1@,0-*", loRaMessenger.ADD_WAYPOINT_MESSAGE);
  //path.addWaypoint(coordinates.lat, coordinates.lng, coordinates.tankLeft, coordinates.tankRight);

}

void addWaypoint2(void* context) {  
  Serial.println("Add waypoint");
  
  //path.addWaypoint(44.404753960198214, 26.10668608266575, 1, 0);//test path
  //LoraLatLong coordinates = loRaMessenger.parseLatLong("WP:123.22@,33.44||0@,1-*", loRaMessenger.ADD_WAYPOINT_MESSAGE);
  //path.addWaypoint(coordinates.lat, coordinates.lng, coordinates.tankLeft, coordinates.tankRight);

}

void nextWaypoint(void* context) {  
  Serial.println("next waypoint");
  path.nextWaypoint(
    controller.unloadLeftTank, 
    controller.unloadRightTank, 
    controller.unloadAllTanks, 
    controller.stopEngines, 
    controller.startEngines); 

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
  liveData += "|"; //value divider
  liveData += String(path.getRunningIndex()); //value divider
  liveData += "*"; //this char will say that the here the sent package ends, and the message can be processed
  Serial.println(liveData);
  //nav.compass.calibrate();

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
  
  
  if(message == loRaMessenger.REQUEST_WAYPOINTS_MESSAGE) {
    Serial.println("REQUEST_WAYPOINTS_MESSAGE");
    loRaMessenger.send(path.getWaypointsMessage());
    beeper.beep(500);
    
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
      path.addWaypoint(coordinates.lat, coordinates.lng, coordinates.tankLeft, coordinates.tankRight, coordinates.index);
    }
  }
  
}
