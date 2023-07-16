#include <Arduino.h>
#include "BoatController.h"
#include "SmartBoat_Compass.h"
#include <IBusBM.h>
#include <Adafruit_PWMServoDriver.h>

HardwareSerial& ibusRcSerial = Serial1;
IBusBM ibusRc;
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();
boolean externalControl = true;

//#define DEBUG // enable serial output for debugging
#define EXTERNAL_CONTROL 8

uint8_t STEERING_CHANNEL = 0;
uint8_t GAS_CHANNEL = 1;
uint8_t RIGHT_LOAD = 2;
uint8_t LEFT_LOAD = 3;

/**********************************************
 * BoatController() - Constructor
 * Creating a boatcontroller object requires 
 * passing the constructor a left engine pin 
 * and a right engine pin number.
 **********************************************/
BoatController::BoatController()
{
   pinMode(EXTERNAL_CONTROL, OUTPUT);   
   digitalWrite(EXTERNAL_CONTROL, HIGH);  
   ibusRc.begin(ibusRcSerial);
}

int readChannel(byte channelInput, int minLimit, int maxLimit, int defaultValue){
  uint16_t ch = ibusRc.readChannel(channelInput);
  if (ch < 100) return defaultValue;
  return map(ch, 1000, 2000, minLimit, maxLimit);
}


void BoatController::beginServo(void) {  
  pwm.begin();
  pwm.setPWMFreq(50);
  pwm.setPWM(RIGHT_LOAD, 0, 410);
  pwm.setPWM(LEFT_LOAD, 0, 190);
}

void steer(int degrees) {  
  // 90 degrees = 310
  // min 180
  // max 440
  //degrees = 85;
  if(externalControl) {
    return;
  }
  int pulseMicros = map(degrees+6, 0, 180, 180, 440);
  pwm.setPWM(STEERING_CHANNEL, 0, pulseMicros);
}

void openRightLoad() {
  if(externalControl) {
    return;
  }
   pwm.setPWM(RIGHT_LOAD, 0, 190);
   delay(3000);
   pwm.setPWM(RIGHT_LOAD, 0, 420);
}


void openLeftLoad() {
  if(externalControl) {
    return;
  }
  pwm.setPWM(LEFT_LOAD, 0, 420);
  delay(3000);
  pwm.setPWM(LEFT_LOAD, 0, 190);
}

void BoatController::gas() {
  if(externalControl) {
    return;
  }
  int translatedSpeed = map(speed, 0, 100, 310, 400); //translate input speed only to forward rotation;
  pwm.setPWM(GAS_CHANNEL, 0, translatedSpeed);
}



void servoPosition(int degrees){  
  int value = readChannel(2, -100, 100, 0);
  if(value < 1) {    
    externalControl = true;
    digitalWrite(EXTERNAL_CONTROL, HIGH);
    //Serial.println("Steering off");
    return;
  }
  externalControl = false;
  digitalWrite(EXTERNAL_CONTROL, LOW);  
  steer(degrees);
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
  
  int servoValue = map(relativeBearing, -90, 90, 0, 180);
  
  #ifdef DEBUG
    Serial.print("relativeBearing");  
    Serial.println(relativeBearing);
  #endif 
  
  servoPosition(servoValue);
  gas();  
 
  #ifdef DEBUG
  Serial.print("\nRelBearing: ");
  Serial.print(relativeBearing);
  #endif 

  
  #ifdef DEBUG
  Serial.print("\nSpeed: ");
  Serial.print(speed);
  #endif 

  return servoValue;
}

 void BoatController::stopEngines()
 {
    externalControl = true;
    digitalWrite(EXTERNAL_CONTROL, HIGH);
    #ifdef DEBUG
      Serial.println("Stopping");
    #endif
 }

 void BoatController::setSpeed(int sp)
 {
    speed = sp;
 }
