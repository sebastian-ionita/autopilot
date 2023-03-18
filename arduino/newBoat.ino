
/* Dear hackers, makers, and engineers, 
*
*  Welcome!
*
*  This is a complete rewrite of the original code that drove my autopilot RC boat. When I wrote the first
*  version, I never expected people would attempt to use it or understand it for use in their personal
*  projects, so the code was very difficult and sloppy, and for that, I apologize. I hope you will find
*  this version helpful and much easier to read. If you have any questions, feel free to shoot me an email
*  at joefortune11@gmail.com. Best of luck to you in your projects!
*
*  -Joseph Fortune 
*/

// Everything that was included in the other files had to also be included here to work for some reason
//#include <Adafruit_GPS.h>
#include <TinyGPS++.h>
#include <SoftwareSerial.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_HMC5883_U.h>
#include <Wire.h>
//#include <Adafruit_LSM303.h>
#include <avr/sleep.h>
//#include <SoftwareServo.h>
//#include <Servo.h>
#include <SPI.h>
#include <LoRa.h>

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
#define SERVO_PIN 6

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
BoatController controller(SERVO_PIN);
Path path;
Beeper beeper;
LoRaMessenger loRaMessenger;

Timer timer;


void setup()
{
  
  
  nav.begin();
   
  beeper.begin(BEEPER_PIN);
  loRaMessenger.begin();
  //path.addWaypoint(44.40137415624203, 26.097540411523457, SLOW);//vdf mega image
  //path.addWaypoint(44.40247667463061, 26.093612582007538, SLOW);//solca bariera

  //path.addWaypoint(30.114868, -81.746674, FAST);

  
    path.addWaypoint(44.404811107531685, 26.103457001243456, SLOW);//tineretului ponton
    //path.addWaypoint(44.40499891489526, 26.103412999862424, SLOW);//tineretului ponton baza
    

  
  //pinMode(LEFT_ENGINE_PIN1, OUTPUT); //IN3
  //pinMode(RIGHT_ENGINE_PIN, OUTPUT); //IN4
  //digitalWrite(LEFT_ENGINE_PIN1, HIGH);
  //digitalWrite(RIGHT_ENGINE_PIN, HIGH);
  
  
  #ifdef DEBUG
  Serial.begin(9600);
  #endif
  while(!nav.hasFix()) {
    Serial.println("Waiting for fix...");
  }
  Serial.println("Got a GPS fix");
  beeper.beep3(); // A happy little 3 chirps to know we have fix
  controller.beginServo(); 
  
  timer.every(2000, sendLoRaData, (void*)2);
  
}

void loop()
{
  Serial.println("loop");
  timer.update();
  // While we still have waypoints to reach
  while(path.hasWaypoints())
  {
    timer.update();
    Serial.print("1"); 
    // Lock in the current waypoint
    nav.setTarget(path.getLat(), path.getLon());

    // While we haven't reached waypoint
    while(nav.getDistance() > WAYPOINT_PROXIMITY)
    {
      timer.update();
      //Serial.print(nav.getRelativeBearing()); 
      // Get the relative bearing to adjust the motors accordingly
      controller.adjustHeading(nav.getRelativeBearing(), path.getSpeed());
      
      #ifdef DEBUG
        Serial.print("Distance: "); 
        Serial.println(nav.getDistance());
      delay(500);
      #endif     
    }    
    
    // Waypoint reached
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

void sendLoRaData(void* context) {
  Serial.println("sending");
  loRaMessenger.send(String(nav.getDistance()));
}
