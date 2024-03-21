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
//#include "Sonar.h"

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
//Sonar sonar;

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
  //sonar.begin();
  beeper.begin(BEEPER_PIN);
  controller.beginServo(); 
  controller.startEngines();

  #ifdef WAIT_FIX
    while(!nav.hasFix()) {
      wdt_reset();      
      controller.update(); 
      //Serial.println("Waiting for fix...");
    }
  #endif
  Serial.println("Got a GPS fix");  
  
  beeper.beep3(); // A happy little 3 chirps to know we have fix  
  timer.every(1000, sendBoatLiveData, (void*)4);  

  Serial.println("Setup finished");  
  
}

void loop()
{
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
    while(distance > nav.WAYPOINT_PROXIMITY)
    {
      update();
      nav.setTarget(path.getLat(), path.getLon());  
      distance = nav.getDistance(); 

      
      relativeBearing = nav.getRelativeBearing(&headingDegrees); //heading degrees is passed as pointer reference to be able to set it from within the method
      motorSpeed = getSpeedFromDistance(distance, relativeBearing);
      servoValue = controller.adjustHeading(relativeBearing, motorSpeed);   
      //controller.calibrate();   

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
    loRaMessenger.send("REACHED:"+path.getRunningRoutineId()+"|"+path.getRunningIndex()+"*"); 
    nextWaypoint(0);
    proximityAlert = -1;
    
    #ifdef DEBUG
    Serial.println("\nWAYPOINT REACHED!!!");
    beeper.beep3();
    #endif
  }  
  
  // All waypoints reached
  controller.stopEngines();
  
  //send finished message to receiver
  if(path.getRunningRoutineId() != ""){
    loRaMessenger.send("FINISHED:"+path.getRunningRoutineId()+"*"); 
    //set running routine to empty
    path.setRunningRoutineId("");    
    path.clearWaypoints();
  }
  
  
  
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
  //sonar.update();
}

bool reachedWaypoint(double distance) {
  if(distance > nav.WAYPOINT_PROXIMITY) {
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
  liveData += String(path.getRunningIndex()); //running index
  liveData += "|"; //value divider
  liveData += String(path.getRunningRoutineId()); //running routine id
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
    //sendMessageDelayed(message);    
  }

  
  
  if(message == loRaMessenger.REQUEST_CONFIG) {
    beeper.beep(100);
    String message = "BC:";
    message += String(nav.WAYPOINT_PROXIMITY);
    message += "|";
    message += String(controller.getSteeringCalibration());
    message += "|";
    message += String(controller.getSteeringDelay());    
    message += "*";    
    //delay(100);
    loRaMessenger.send(message); 
    //sendMessageDelayed(message);    
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
  
  if(message == loRaMessenger.GET_LOCATION) {
    String message = "BL:";    
    message += String(nav.getLat(), 8);
    message += ",";
    message += String(nav.getLng(), 8);
    message += "*";
    loRaMessenger.send(message); 
  }
  
  if(message.indexOf(loRaMessenger.START) >= 0) {
    isStarted = true;
    Serial.println("Start running");
    controller.setCourseStabilisation(true);    
    loRaMessenger.canSendLiveData = true;

    //set running routine id
    int startIndex = message.indexOf(loRaMessenger.START);
    if(startIndex != -1){
      int endIndex = message.indexOf("*");
      if(endIndex != -1){
        String routine_id = message.substring(startIndex + loRaMessenger.START.length(), endIndex);
        Serial.print("Routine id: ");
        Serial.println(routine_id);
        path.setRunningRoutineId(routine_id); 
      }
    }
    timer.after(3000, stopCourseStabilisation, (void*)0);
    
  }
  
  if(message == loRaMessenger.STOP) {
    isStarted = false;     
    Serial.println("Stop running");
    path.setRunningRoutineId("");
    path.clearWaypoints();
  }
  
  if(message.indexOf(loRaMessenger.SET_PROXIMITY_MESSAGE) >= 0) {
    int speed = loRaMessenger.parseInt(message, loRaMessenger.SET_PROXIMITY_MESSAGE);
    if(speed != -1) {
      beeper.beep(100);
      nav.WAYPOINT_PROXIMITY = speed;
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
  
  
  if(message.indexOf(loRaMessenger.SET_CALIBRATION_MESSAGE) >= 0) {
    Serial.println(message);
    int c = loRaMessenger.parseInt(message, loRaMessenger.SET_CALIBRATION_MESSAGE);
    Serial.println(c);
    if(c != -1) {
      beeper.beep(100);
      controller.setSteeringCalibration(c);
    }    
  }
  if(message.indexOf(loRaMessenger.SET_STEERING_DELAY_MESSAGE) >= 0) {
    int c = loRaMessenger.parseInt(message, loRaMessenger.SET_STEERING_DELAY_MESSAGE);
    if(c != -1) {
      beeper.beep(100);
      controller.setSteeringDelay(c);
    }    
  }
  
  
  if(message.indexOf(loRaMessenger.STOP_AND_RETURN) >= 0) {
    LoraLatLong coordinates = loRaMessenger.parseLatLong(message, loRaMessenger.STOP_AND_RETURN);
    if(coordinates.lat != 0.00 && coordinates.lng != 0.00) {
      path.clearWaypoints();
      path.addWaypoint(coordinates.lat, coordinates.lng, 0, 0, 0);
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
