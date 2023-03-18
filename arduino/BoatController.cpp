#include <Arduino.h>
#include "BoatController.h"
//#include <Servo.h>
//#include <SoftwareServo.h>

#define DEBUG // enable serial output for debugging





/**********************************************
 * BoatController() - Constructor
 * Creating a boatcontroller object requires 
 * passing the constructor a left engine pin 
 * and a right engine pin number.
 **********************************************/
BoatController::BoatController(int servoPin)
{
  //leftEnginePin = leftEngine;
  //rightEnginePin = rightEngine;
  
  //pinMode(leftEnginePin, OUTPUT);
  //pinMode(rightEnginePin, OUTPUT);
  pinMode(servoPin, OUTPUT); // Servo
  //servo.attach(6);


}

void BoatController::beginServo(void) {
  //servo.attach(30);
}

void servoPosition(int servopin, int degrees){
  
  // 600 = 0
  // 2380 = 180 
  // 9.88 per degree
  
  int pulseMicros = 0;
  if(degrees < 20) {
    pulseMicros = 800;
  } else if (degrees > 160) {
    pulseMicros = 2180;
  } else {
    pulseMicros = map(degrees, 0, 180, 600, 2380); // 600 = 0, 2380 = 180, 9.88 per degree;
  }  
  
  for(int i=0; i<24; i++) { //gets about 90 degrees movement, call twice or change i<16 to i<32 if 180 needed; set to 24 for 140;
    digitalWrite(servopin, HIGH);
    delayMicroseconds(pulseMicros);
    digitalWrite(servopin, LOW);
    delay(25);
  }
}


/**********************************************
 * adjustHeading()
 * This function takes a relative bearing, and 
 * running speed as an argument. Relative
 * bearing is the angle in degrees between
 * where the boat is heading versus where it's 
 * supposed to be heading. An angle to the left
 * is negative. The angle is measured from the 
 * target to the front of the boat.
 **********************************************/
void BoatController::adjustHeading(double relativeBearing, int speed)
{
  Serial.println("adjustHeading");
  double absRelativeBearing = abs(relativeBearing);
  int turnSpeed;
  
  int servoNum = (180 - map(relativeBearing, -90, 90, 0, 180));
  #ifdef DEBUG
    Serial.print("Servo: ");
    Serial.println(servoNum); 
  #endif 
  //analogWrite(11, servoNum);
  //delay(1000);
  int servoMilis = map(servoNum, 0, 180, 600, 2380); // 600 = 0; 2380 = 180, 9.88 per degree
  
    Serial.println(servoMilis);
  
  servoPosition(6, servoNum);
  //servo.write(90); 


  //servo.refresh();
  
  /* *** CALCULATE TURNSPEED ***
   * In this first section we calculate what the turn speed should be. The further off course, the more one of
   * the engines will be slowed to allow a smooth turn */
  
  //if (absRelativeBearing < 90)
   // turnSpeed = speed * (1 - absRelativeBearing / 90);
  //else
  //  turnSpeed = 0; // Really sharp turn
 
  #ifdef DEBUG
  Serial.print("\nRelBearing: ");
  Serial.print(relativeBearing);
  //Serial.print(" ");
  #endif 
   
  if ( relativeBearing > 0 ) // positive bearing, turn left
  {
    
    
    // Ensures motors won't run while in debug mode
    //#ifndef DEBUG
    //analogWrite(leftEnginePin, turnSpeed); // slow down
    //analogWrite(rightEnginePin, speed); // full speed
    //#endif 
    
    #ifdef DEBUG
    //Serial.print("Turning left: (");
    //Serial.print(turnSpeed);
    //Serial.print(") (");
    //Serial.print(speed);
    //Serial.println(")");
    #endif
  }
  else // negative bearing, turn right
  {
    
    // Ensures motors won't run while in debug mode
    //#ifndef DEBUG
    //analogWrite(leftEnginePin, speed); // full speed
    //analogWrite(rightEnginePin, turnSpeed); // slow down
    //#endif
    
    
    #ifdef DEBUG
    //Serial.println("Turning right");
    //Serial.print(speed);
    //Serial.print(") (");
    //Serial.print(turnSpeed);
    //Serial.println(")");
    #endif
  }
}


/**********************************************
 * stopEngines()
 * I feel like this one is pretty obvious.
 **********************************************/
 void BoatController::stopEngines(void)
 {
    analogWrite(leftEnginePin, 0);
    analogWrite(rightEnginePin, 0);
    
    #ifdef DEBUG
    Serial.println("Stopping");
    #endif
 }
