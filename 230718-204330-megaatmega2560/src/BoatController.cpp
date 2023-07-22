#include <Arduino.h>
#include "BoatController.h"
#include "SmartBoat_Compass.h"
#include <IBusBM.h>
#include <avr/wdt.h>
#include <Adafruit_PWMServoDriver.h>

HardwareSerial& ibusRcSerial = Serial1;
IBusBM ibusRc;
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

//#define DEBUG // enable serial output for debugging
#define EXTERNAL_CONTROL 8
#define OPEN_TANK_DURATION 5000
#define STEERING_CALIBRATION 0

boolean externalControl = true;
boolean enginesEnabled = true;
uint8_t STEERING_CHANNEL = 0;
uint8_t GAS_CHANNEL = 1;
uint8_t RIGHT_LOAD = 2;
uint8_t LEFT_LOAD = 3;

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
  closeRightTank();
  closeLeftTank();
}

void steer(int degrees) {  
  // 90 degrees = 310
  // min 180
  // max 440
  
  if(externalControl) {
    return;
  }
  int pulseMicros = map(degrees + STEERING_CALIBRATION, 0, 180, 180, 440);
  pwm.setPWM(STEERING_CHANNEL, 0, pulseMicros);
}

void BoatController::openRightTank() {
  #ifdef DEBUG
    Serial.println("openRightTank");
  #endif
   pwm.setPWM(RIGHT_LOAD, 0, 190);
}

void BoatController::closeRightTank() {
  #ifdef DEBUG
    Serial.println("closeRightTank");
  #endif
   pwm.setPWM(RIGHT_LOAD, 0, 420);
}


void BoatController::openLeftTank() {
  #ifdef DEBUG
    Serial.println("openLeftTank");
  #endif
  pwm.setPWM(LEFT_LOAD, 0, 420);
}

void BoatController::closeLeftTank() {
  #ifdef DEBUG
    Serial.println("closeLeftTank");
  #endif
  pwm.setPWM(LEFT_LOAD, 0, 190);
}

void BoatController::unloadAllTanks() {
  #ifdef DEBUG
    Serial.println("unloadAllTanks");
  #endif
  openLeftTank();
  openRightTank();
  delay(OPEN_TANK_DURATION);
  wdt_reset();
  closeLeftTank();
  closeRightTank();
}

void BoatController::unloadLeftTank() {
  #ifdef DEBUG
    Serial.println("unloadLeftTank");
  #endif
  openLeftTank();
  delay(OPEN_TANK_DURATION);
  wdt_reset();
  closeLeftTank();
}

void BoatController::unloadRightTank() {
  #ifdef DEBUG
    Serial.println("unloadRightTank");
  #endif
  openRightTank();
  delay(OPEN_TANK_DURATION);
  wdt_reset();
  closeRightTank();
}

void BoatController::gas() {
  if(externalControl) {
    return;
  }

  int s = signalSpeed;
  if(!enginesEnabled) {
    s = 0;
  }
  
  int translatedSpeed = map(s, 0, 100, 310, 420); //translate input speed only to forward rotation;
  pwm.setPWM(GAS_CHANNEL, 0, translatedSpeed);
}

void sendStopSignal() {
  pwm.setPWM(GAS_CHANNEL, 0, 310);
}

void BoatController::update() {
  int value = readChannel(2, -100, 100, 0);
  if(value < 1) {    
    externalControl = true;
    digitalWrite(EXTERNAL_CONTROL, HIGH);   
    return;
  }
  externalControl = false;
  digitalWrite(EXTERNAL_CONTROL, LOW);  
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
int BoatController::adjustHeading(double relativeBearing, int speedComand)
{    
  if(speedComand > 50) {
      float s = (speed/100.0) * speedComand;
      signalSpeed = int(s);
  } else {
    signalSpeed = speedComand;
  }
  
  int servoValue = map(relativeBearing, -90, 90, 0, 180);  

  steer(servoValue);
  gas();

  return servoValue;
}

 void BoatController::stopEngines()
 {
    enginesEnabled = false;
    sendStopSignal();
    #ifdef DEBUG
      Serial.println("Stopping engines");
    #endif
 }

 void BoatController::startEngines()
 {
    enginesEnabled = true;
    #ifdef DEBUG
      Serial.println("Starting engines");
    #endif
 }

 void BoatController::setSpeed(int sp)
 {
  #ifdef DEBUG
      Serial.println("Set speed: " + String(sp));
    #endif
    speed = sp;
 }
