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
#include "Timer.h"
#include "Sonar.h"

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
Sonar sonar;

Timer timer;

double distance = 0;
int motorSpeed = 0;
int servoValue = 0;
double relativeBearing = 0;
double headingDegrees = 0;
double proximityAlert = -1;
bool isStarted = false;

void setup()
{  
  
  Serial.begin(9600);
  Serial.println("Setup started");
  wdt_enable(WDTO_8S);
   
  loRaMessenger.begin(onReceiveLora);  
  nav.begin();  
  sonar.begin();
  beeper.begin(BEEPER_PIN);
  controller.beginServo(); 
  controller.startEngines();


  //path.addWaypoint(44.96401865891598, 24.89437097537398, 1, 1, 0); //test path1
  //path.addWaypoint(44.963730194840515, 24.893402308225465, 1, 1, 1); //test path1
  //path.addWaypoint(44.404753960198214, 26.10668608266575, 1, 0);//test path2
  //path.addWaypoint(44.95424987946493, 18.625603815865414, 0, 0, 1); // zabar 14 groapa 30 dreapta
  //path.addWaypoint(44.95425533815923, 18.625518966241945, 0, 1, 0); // zabar 14 groapa 30 stanga  
  //path.addWaypoint(44.95424078164077, 18.62524127655908, 0, 0, 1); // zabar 14 in stanga groapa 30 dreapta  
  //path.addWaypoint(44.954311744633145, 18.625225849356823, 0, 1, 0); // zabar 14 in stanga groapa 30 stanga  
  //path.addWaypoint(44.95398968111622, 18.625565247858102, 0, 0, 1); // zabar 14 prima groapa dreapta  
  //path.addWaypoint(44.953991500689185, 18.625498396638154, 0, 1, 0); // zabar 14 prima groapa stanga 

  //dreapta
  //path.addWaypoint(44.95424987946493, 18.625603815865414, 0, 1, 0); // zabar 14 prima groapa stanga   
  //path.addWaypoint(44.95425533815923, 18.625518966241945, 0, 1, 0); // zabar 14 groapa 30 dreapta

  //stanga
  //path.addWaypoint(44.95424078164077, 18.62524127655908, 1, 0, 1); // zabar 14 groapa 30   
  //path.addWaypoint(44.95425533815923, 18.625518966241945, 1, 0, 1);// zabar 14 in stanga groapa 30 
   
  //stanga 15
  //path.addWaypoint(44.95405578768267, 18.624409543385553, 1, 0, 0); // zabar 15
  //path.addWaypoint(44.95408025784635, 18.624725070616474, 0, 1, 1);// zabar 15
  
  //dreapta 15
  //path.addWaypoint(44.953863084779016, 18.62486770621402, 0, 1, 0); // zabar 15
  //path.addWaypoint(44.95428519505762, 18.62511839908242, 1, 0, 1);// zabar 15

  
  //path.addWaypoint(44.953396157710316, 18.625004910018188, 0, 0, 2); // zabar 14 home
  
  //path.addWaypoint(44.953583693964354, 18.624512963139995, 0, 0, 2); // zabar 15 home
  //isStarted = true;
  
  
  
  //path.addWaypoint(44.95361397919283, 18.624514667580385, 1, 0, 1); // Daimon stanga
  //path.addWaypoint(44.404611109453214, 26.108126680998154, 0, 0, 2); // Daimon home

  #ifdef WAIT_FIX
    while(!nav.hasFix()) {
      wdt_reset();      
      controller.update(); 
      //Serial.println("Waiting for fix...");
    }
  #endif
  Serial.println("Got a GPS fix");  
  
  beeper.beep3(); // A happy little 3 chirps to know we have fix  
  //nav.compass.calibrate();  
  //every 1 second, send boat live data to received on the mobile
  timer.every(2000, sendBoatLiveData, (void*)4);
  //timer.after(3000, sendBoatLiveData, (void*)0);
  //timer.after(3200, addWaypoint2, (void*)0);
  //timer.after(3000, nextWaypoint, (void*)0);
  //timer.after(6000, nextWaypoint, (void*)0);
  //timer.after(13000, nextWaypoint, (void*)0);
  
  //beeper.beep(1000);  
  //beeper.beep3();
  

  Serial.println("Setup finished");  
  
}

void loop()
{
  //Serial.println("Loop cycle");
  update();    
  
  while(path.hasWaypoints())
  {    
    update();    
    nav.setTarget(path.getLat(), path.getLon());
    
    // While we haven't reached waypoint
    #ifndef TEST_DATA
        distance = nav.getDistance();
    #endif 
    #ifdef TEST_DATA
        distance = 100;
    #endif    
    
    if(path.getLat() == 0.00) {
      return;
    }
       
    // Lock in the current waypoint

    
    
    while(distance > WAYPOINT_PROXIMITY)
    {
      update();
      nav.setTarget(path.getLat(), path.getLon());  
      distance = nav.getDistance(); 

      relativeBearing = nav.getRelativeBearing(&headingDegrees); //heading degrees is passed as pointer reference to be able to set it from within the method
      motorSpeed = getSpeedFromDistance(distance, relativeBearing);
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
    //delay(1000); 
    
    // Waypoint reached
    loRaMessenger.send("N:Waypoint reached"); 
    nextWaypoint(0);
    proximityAlert = -1;
    #ifdef DEBUG
    Serial.println("\nWAYPOINT REACHED!!!");
    beeper.beep3();
    #endif
  }  
  
  // All waypoints reached
  controller.stopEngines();
  
  // Shutdown
  //cli(); // Disable interrupts
  //sleep_enable();
  //sleep_cpu();
  
}

void updateStartStatus() {
  if(isStarted) {
    controller.startEngines(); 
  } else {
    controller.stopEngines();
  }
}

void update() {
  wdt_reset();
  timer.update();
  controller.update();  
  beeper.update(); 
  updateStartStatus();
  sonar.update();
}

bool reachedWaypoint(double distance) {
  if(distance > WAYPOINT_PROXIMITY) {
    return false;
  }
  if(proximityAlert == -1) {
    proximityAlert = distance;
  }
  if(proximityAlert > distance) {
    return true;
  }
  proximityAlert = distance;
  return false;
}

int getSpeedFromDistance(double distance, double bearing) {
  if(bearing < -20 || bearing > 20)  {
    return 30;
  }
  //distance in meters
  if(distance >= 12) {
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
  if(!loRaMessenger.canSendLiveData) {
    return;
  }
  String message = getBoatLiveData();
  loRaMessenger.send(message); 
}

String getBoatLiveData() {  
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
  //Serial.println(liveData);

  return liveData;

  //loRaMessenger.send(liveData); 
}
void(* reset) (void) = 0;

void onReceiveLora(int packetSize)
{
  //noInterrupts();
    // received a packet
  Serial.print("Received packet: ");
  String message = "";

  // read packet
  for (int i = 0; i < packetSize; i++) {
    message += (char)LoRa.read();
  }

  Serial.println(message);
  if(message == loRaMessenger.CALIBRATE_MESSAGE) {
    beeper.beep(1000);
    nav.compass.calibrate();
    beeper.beep3();
  }
  
  if(message == loRaMessenger.CLEAR_WAYPOINTS_MESSAGE) {
    beeper.beep(100);
    path.clearWaypoints();
  }
  
  if(message == loRaMessenger.REQUEST_WAYPOINTS) {
    beeper.beep(100);
    loRaMessenger.send(path.getWaypointsMessage()); 
    
  }  
  
  if(message == loRaMessenger.REQUEST_WAYPOINTS_MESSAGE) {
    String message = path.getWaypointsMessage();
    sendMessageDelayed(message);
    //loRaMessenger.send(path.getWaypointsMessage());
    beeper.beep(100);
    
  }

  if(message == loRaMessenger.XON) {
    loRaMessenger.canSendLiveData = true;
  }
  
  if(message == loRaMessenger.XOFF) {
    loRaMessenger.canSendLiveData = false;
  }

  if(message == loRaMessenger.RESET_MESSAGE) {
    reset();    
  }
  
  if(message == loRaMessenger.REQUEST_DATA) {
    String message = getBoatLiveData();
    sendMessageDelayed(message); 
  }
  
  if(message == loRaMessenger.START) {
    isStarted = true;
    Serial.println("start");
    controller.setCourseStabilisation(true);    
    loRaMessenger.canSendLiveData = true;
    timer.after(3000, stopCourseStabilisation, (void*)0);
    
  }
  
  if(message == loRaMessenger.STOP) {
    isStarted = false;     
    path.clearWaypoints();
  }
  
  if(message.indexOf(loRaMessenger.SET_SPEED_MESSAGE) >= 0) {
    int speed = loRaMessenger.parseInt(message, loRaMessenger.SET_SPEED_MESSAGE);
    if(speed != -1) {
      beeper.beep(100);
      controller.setSpeed(speed);
    }    
  }
  
  
  if(message.indexOf(loRaMessenger.SET_CALIBRATION_MESSAGE) >= 0) {
    int c = loRaMessenger.parseInt(message, loRaMessenger.SET_CALIBRATION_MESSAGE);
    if(c != -1) {
      beeper.beep(100);
      nav.setCompassCalibration(c);
    }    
  }
  
  if(message.indexOf(loRaMessenger.ADD_WAYPOINT_MESSAGE) >= 0) {
    LoraLatLong coordinates = loRaMessenger.parseLatLong(message, loRaMessenger.ADD_WAYPOINT_MESSAGE);
    if(coordinates.lat != 0.00 && coordinates.lng != 0.00) {
      Serial.println(coordinates.index);
      beeper.beep(100);
      path.addWaypoint(coordinates.lat, coordinates.lng, coordinates.tankLeft, coordinates.tankRight, coordinates.index);
    }
  }  
  //interrupts();
}
void sendMessageDelayed(String message) {
  timer.after(2000, sendLoraMessage, const_cast<char*>(message.c_str()));
}
void sendLoraMessage(void* message) {
  String m = reinterpret_cast<char*>(message);
  loRaMessenger.send(m);
}

void stopCourseStabilisation(void* context) {
  controller.setCourseStabilisation(false);
}
