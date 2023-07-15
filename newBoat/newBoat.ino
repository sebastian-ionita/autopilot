
// Everything that was included in the other files had to also be included here to work for some reason
//#include <Adafruit_GPS.h>
#include <TinyGPS++.h>
#include <SoftwareSerial.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>
//#include <Adafruit_LSM303.h>
#include <avr/sleep.h>
//#include <SoftwareServo.h>
//#include <Servo.h>
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

// *** Macros ***
//#define LEFT_ENGINE_PIN1 8
//#define LEFT_ENGINE_PIN 9
//#define RIGHT_ENGINE_PIN1 6
//#define RIGHT_ENGINE_PIN 7

#define BEEPER_PIN 5

/****************************** DEBUG MODE ***********************************
* It is EXTREMELY helpful to have serial feedback on what the boat is doing.
* For example you might want to set up some test waypoints in your yard, and
* walk around, checking that the boat is turning the correct way and that
* the waypoints are registering at a reasonable distance. This is what debug
* mode does when the macro is enabled. All the #ifdefs made the code look
* blotchy, but its well worth it when something isn't working right. Note that
* some of the other classes may have their own debug mode as well. 
******************************************************************************/
#define DEBUG // Enables serial output feedback for basic functions

// *** Globals ***
Navigator nav;
BoatController controller;
Path path;
Beeper beeper;
LoRaMessenger loRaMessenger;
//Storage storage;

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
  Serial.println("Setup started");
   
  loRaMessenger.begin();
  
  nav.begin();
  
  beeper.begin(BEEPER_PIN);
  controller.beginServo(); 

  path.addWaypoint(44.40375040589921, 26.106770300233578, SLOW);
  path.addWaypoint(44.404244863681654, 26.10776210470905, SLOW);
  //path.addWaypoint(44.40247667463061, 26.093612582007538, SLOW);//solca bariera
  //path.addWaypoint(44.40271144491504, 26.094229880607987, SLOW); //solca casa drept terasa
  //path.addWaypoint(44.42718003495822, 26.092074449012067, SLOW); //constitutiei 1
  //path.addWaypoint(44.40502614603183, 26.102622364772053, SLOW); ///ac tineretului
  
  //path.addWaypoint(44.96402978199103, 24.894378956501285, SLOW); // purcareni 7 salcie
  
  //path.addWaypoint(44.404811107531685, 26.103457001243456, SLOW);//tineretului ponton
  //path.addWaypoint(44.40499891489526, 26.103412999862424, SLOW);//tineretului ponton baza
  
  
  #ifdef DEBUG
    Serial.begin(9600);
  #endif
  
  while(!nav.hasFix()) {
    wdt_reset();
    Serial.println("Waiting for fix...");
  }
  Serial.println("Got a GPS fix");  
  
  beeper.beep3(); // A happy little 3 chirps to know we have fix  

  //calibrateCompass();
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
  Serial.println(liveData);
  
  loRaMessenger.send(liveData); 
}


void calibrateCompass() {
  beeper.beep(1000);
  nav.compass.calibrate();
  beeper.beep3();
}
