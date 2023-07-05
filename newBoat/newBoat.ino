
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
#include <IBusBM.h>

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
#define MOTOR_PIN 7

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
//#define DEBUG // Enables serial output feedback for basic functions

// *** Globals ***
Navigator nav;
BoatController controller(SERVO_PIN, MOTOR_PIN);
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
   
  loRaMessenger.begin();
  nav.begin();
  beeper.begin(BEEPER_PIN);

  //path.addWaypoint(44.40137415624203, 26.097540411523457, SLOW);//vdf mega image
  //path.addWaypoint(44.40247667463061, 26.093612582007538, SLOW);//solca bariera
  //path.addWaypoint(44.40271144491504, 26.094229880607987, SLOW); //solca casa drept terasa
  //path.addWaypoint(44.42718003495822, 26.092074449012067, SLOW); //constitutiei 1
  //path.addWaypoint(44.40502614603183, 26.102622364772053, SLOW); ///ac tineretului
  
  path.addWaypoint(44.96402978199103, 24.894378956501285, SLOW); // purcareni 7 salcie
  
  //path.addWaypoint(44.404811107531685, 26.103457001243456, SLOW);//tineretului ponton
  //path.addWaypoint(44.40499891489526, 26.103412999862424, SLOW);//tineretului ponton baza
  
  //pinMode(LEFT_ENGINE_PIN1, OUTPUT); //IN3
  //pinMode(RIGHT_ENGINE_PIN, OUTPUT); //IN4
  //digitalWrite(LEFT_ENGINE_PIN1, HIGH);
  //digitalWrite(RIGHT_ENGINE_PIN, HIGH);
  
  #ifdef DEBUG
  Serial.begin(9600);
  #endif
  //beeper.beep3();
  while(!nav.hasFix()) {
    Serial.println("Waiting for fix...");
    //beeper.beep(15);
    //delay(1000);
  }
  Serial.println("Got a GPS fix");
  beeper.beep3(); // A happy little 3 chirps to know we have fix
  //controller.beginServo(); 
  

  //every 1 second, send boat live data to received on the mobile
  timer.every(1000, sendBoatLiveData, (void*)2);

  Serial.println("Setup finished");
  
}


void loop()
{
  Serial.println("Loop cycle");
  timer.update();
  // While we still have waypoints to reach
  while(path.hasWaypoints())
  {

    timer.update();

    // Lock in the current waypoint
    nav.setTarget(path.getLat(), path.getLon());

    // While we haven't reached waypoint
    distance = nav.getDistance();
    while(distance > WAYPOINT_PROXIMITY)
    {
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
    #ifdef DEBUG
    Serial.println("\nWAYPOINT REACHED!!!");
    beeper.beep3();
    #endif
    path.nextWaypoint(); 
  }
  
  
  // All waypoints reached
  controller.stopEngines(SERVO_PIN);
  
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

void sendBoatLiveData() {
  String message = "LD:";
  message += distance;
  message += "|"; //value divider
  message += headingDegrees; //HARDCODED HEADING FOR NOW
  message += "|"; //value divider
  message += relativeBearing;
  message += "|"; //value divider
  message += servoValue;
  message += "|"; //value divider
  message += motorSpeed;
  message += "*"; //this char will say that the here the sent package ends, and the message can be processed
  
  Serial.println(message);
  loRaMessenger.send(message); 
}

void sendLoRaData(void* context) {
  //controller.setControlSource();
  //int pulseMicros = 1000;
  //int servopin = 7;
   //for(int i=0; i<2; i++) { //gets about 90 degrees movement, call twice or change i<16 to i<32 if 180 needed; set to 24 for 140;
    //digitalWrite(servopin, HIGH);
    //delayMicroseconds(pulseMicros);
    //digitalWrite(servopin, LOW);
    
    //delayMicroseconds(pulseMicros);
    //delay(25);
  //}
  //Serial.println(nav.getLat(), 8);
  //String message = "BL:";
  //message += String(nav.getLat(), 8);
  //message += ",";
  //message += String(nav.getLng(), 8) + "|";
  //message += "D:";
  //message += String(nav.getDistance());
  //Serial.println(message);
  //loRaMessenger.send(message);
}
