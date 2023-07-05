#include <Arduino.h>
#include "BoatController.h"
//#include <Servo.h>
//#include <SoftwareServo.h>
#include <IBusBM.h>

HardwareSerial& ibusRcSerial = Serial1;
IBusBM ibusRc;

boolean externalControl = true;

//#define DEBUG // enable serial output for debugging





/**********************************************
 * BoatController() - Constructor
 * Creating a boatcontroller object requires 
 * passing the constructor a left engine pin 
 * and a right engine pin number.
 **********************************************/
BoatController::BoatController(int servoPin, int motorPin)
{
  //leftEnginePin = leftEngine;
  //rightEnginePin = rightEngine;
  
  //pinMode(leftEnginePin, OUTPUT);
  //pinMode(motorPin, OUTPUT);
   // Servo    
   //pinMode(servoPin, OUTPUT);
   
   pinMode(motorPin, OUTPUT);
   
  //digitalWrite(servoPin, HIGH);
  //digitalWrite(servoPin, HIGH);
  
  ibusRc.begin(ibusRcSerial);
  //servo.attach(6);


}

int readChannel(byte channelInput, int minLimit, int maxLimit, int defaultValue){
  uint16_t ch = ibusRc.readChannel(channelInput);
  if (ch < 100) return defaultValue;
  return map(ch, 1000, 2000, minLimit, maxLimit);
}


void BoatController::beginServo(void) {
  //servo.attach(30);
}
void moveServo(int degrees, int servopin) {
    int pulseMicros = 0;
  if(degrees < 20) {
    pulseMicros = 800;
  } else if (degrees > 160) {
    pulseMicros = map(130, 0, 180, 600, 2380);
  } else {
    pulseMicros = map(degrees, 0, 180, 600, 2380); // 600 = 0, 2380 = 180, 9.88 per degree;
  }  

  Serial.print("servo");
  Serial.println(degrees);
  noInterrupts();
  for(int i=0; i<24; i++) { //gets about 90 degrees movement, call twice or change i<16 to i<32 if 180 needed; set to 24 for 140;
    digitalWrite(servopin, HIGH);
    delayMicroseconds(pulseMicros);
    digitalWrite(servopin, LOW);
    
    //delayMicroseconds(pulseMicros);
    delay(25);
  }
  interrupts();
}

void gas(int speed) {
  if(externalControl) {        
    pinMode(7, INPUT);
    return;
  }
      
  pinMode(7, OUTPUT);
  int translatedSpeed = map(speed, 0, 100, 50, 100); //translate input speed only to forward rotation;
  int pulseMicros = pulseMicros = map(translatedSpeed, 0, 100, 600, 2380); // 600 = 0, 2380 = 180, 9.88 per degree;

  Serial.print("servo");
  //Serial.println(degrees);
  noInterrupts();
  for(int i=0; i<32; i++) { //gets about 90 degrees movement, call twice or change i<16 to i<32 if 180 needed; set to 24 for 140;
    digitalWrite(7, HIGH);
    delayMicroseconds(pulseMicros);
    digitalWrite(7, LOW);
    
    //delayMicroseconds(pulseMicros);
    delay(25);
  }
  interrupts();
}



void servoPosition(int servopin, int degrees){  
  
  // 600 = 0
  // 2380 = 180 
  // 9.88 per degree
  int value = readChannel(2, -100, 100, 0);
  Serial.println(value);
  if(value <-1) {    
    pinMode(servopin, INPUT);
    externalControl = true;
    //moveServo(200, 7);
    Serial.println("Steering off");
    //int value2 = readChannel(0, -100, 100, 0);
    //int remoteDegr = map(value2, 0, 180, -100, 100);
    
    //Serial.println(value2);
    //moveServo(remoteDegr, servopin);
    return;
  }
  externalControl = false;
  
  pinMode(servopin, OUTPUT);
  
  
  //Serial.println("Steering on");
  
  moveServo(degrees, servopin);
  
  //moveServo(90, servopin);

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
int BoatController::adjustHeading(double relativeBearing, int speed)
{
  //Serial.println("adjustHeading");
  double absRelativeBearing = abs(relativeBearing);
  int turnSpeed;
  
  int servoValue = (180 - map(relativeBearing, -90, 90, 0, 180));
  
  #ifdef DEBUG
    //Serial.print("Servo: ");
    //Serial.println(servoValue); 
  Serial.print("relativeBearing");  
  Serial.println(relativeBearing);
  #endif 
  
  //analogWrite(11, servoValue);
  //delay(1000);
  //int servoMilis = map(servoValue, 0, 180, 600, 2380); // 600 = 0; 2380 = 180, 9.88 per degree
  //Serial.println(servoMilis);
  
  servoPosition(6, servoValue);
  gas(speed);
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

  
  #ifdef DEBUG
  Serial.print("\nSpeed: ");
  Serial.print(speed);
  //Serial.print(" ");
  #endif 
   
  if (relativeBearing > 0) // positive bearing, turn left
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

  return servoValue;
}


/**********************************************
 * stopEngines()
 * I feel like this one is pretty obvious.
 **********************************************/
 void BoatController::stopEngines(int servoPin)
 {
  
    //analogWrite(leftEnginePin, 0);
    //analogWrite(rightEnginePin, 0);
    pinMode(servoPin, INPUT);
    #ifdef DEBUG
    Serial.println("Stopping");
    #endif
 }
