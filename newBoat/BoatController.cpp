#include <Arduino.h>
#include "BoatController.h"
#include "SmartBoat_Compass.h"
#include <IBusBM.h>
#include <avr/wdt.h>
#include <Adafruit_PWMServoDriver.h>
#include "Timer.h"

HardwareSerial& ibusRcSerial = Serial1;
IBusBM ibusRc;
Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();
Timer controllerTimer;
Timer calibrationTimer;

//#define DEBUG // enable serial output for debugging
#define OPEN_TANK_DURATION 5000

boolean externalControl = true;
boolean enginesEnabled = true;
boolean isAdjustingCourse = false;
boolean isStabilisingCourse = false;

uint8_t STEERING_CHANNEL = 0;
uint8_t GAS_CHANNEL = 1;
uint8_t RIGHT_LOAD = 2;
uint8_t LEFT_LOAD = 3;
int STEERING_CALIBRATION = 5;
int STEERING_DELAY = 1000;

const int calSampleSize = 3;
int calRuns = 0;
double calValues[] = {};
bool calibrationRun = false;
bool calibrationFinished = false;
double rBearing = 0;

void updateCalibration(void* context) { 
  if(!calibrationRun) {
    return;
  }
  if(calRuns < calSampleSize) {
    calValues[calRuns] = rBearing;
    calibrationFinished = false;
  } else {    
    calibrationRun = false;
    calibrationFinished = true;
  }
}

void BoatController::calibrate() {
  if(!calibrationFinished) {
    return;
  }
  double sum = 0;
  for(int i = 0; i < calSampleSize; i++) {
    sum += calValues[i];
  }
  double avg = sum / calSampleSize;
  Serial.println(avg);
  avg = avg / 2;
  calibrationFinished = false;
  if(avg > 6 && avg < -6) {
    STEERING_CALIBRATION = avg;
    storage.store(storage.CALIBRATION_ADDRESS, avg);
  }
}

void BoatController::startCalibration() {
  calibrationRun = true;
  calibrationFinished = false;
  calRuns = 0;
}

BoatController::BoatController()
{
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
  calibrationTimer.every(1000, updateCalibration, (void*)4);  
  //STEERING_CALIBRATION = storage.read(storage.CALIBRATION_ADDRESS);
  
}

void steer(void* degrees) {  
  // 90 degrees = 310
  // min 180
  // max 440
  
  if(externalControl) {
    return;
  }
  if(isStabilisingCourse) {
    degrees = 90;
  }
  //degrees = 90;
  //Serial.println(degrees);
  int pulseMicros = map((int)degrees + STEERING_CALIBRATION, 0, 180, 180, 440);
  pwm.setPWM(STEERING_CHANNEL, 0, pulseMicros);
}

void setCourseEnded(void* context) { 
  isAdjustingCourse = false;
}

int getSteeringDuration(int degrees) {
  int translatedDegrees = 0;
  if(degrees - 90 > 0) {
    translatedDegrees = degrees - 90;
  } else {
    translatedDegrees = 90 - degrees;
  }

  return STEERING_DELAY;

  if(translatedDegrees < 50) {
    return 500;
  }
  
  if(translatedDegrees < 70) {
    return 1000;
  }
  return 2000;
}

void adjustCourse(int degrees) {
  if(isAdjustingCourse) {
    return;
  }
  isAdjustingCourse = true; 
  int waitToSteer = getSteeringDuration(degrees);
  steer((void*)degrees);
  controllerTimer.after(waitToSteer, steer, (void*)90);
  controllerTimer.after(waitToSteer + 1000, setCourseEnded, (void*)1);
}

void BoatController::setCourseStabilisation(bool active) {
  isStabilisingCourse = active;
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
  controllerTimer.update();
  calibrationTimer.update();
  int value = readChannel(2, -100, 100, 0);
  if(value < 1) {    
    externalControl = true;    
    int engine = readChannel(1, -100, 100, 0);//motor
    int translatedSpeed = map(engine, -100, 100, 200, 420); //translate input speed only to forward rotation;
    pwm.setPWM(GAS_CHANNEL, 0, translatedSpeed);

    int steer = readChannel(0, -100, 100, 0) - STEERING_CALIBRATION;//carma
    int pulseMicros = map(steer, -100, 100, 180, 440);
    pwm.setPWM(STEERING_CHANNEL, 0, pulseMicros);


    int rightTank = readChannel(5, -100, 100, 0);//right
    int leftTank = readChannel(4, -100, 100, 0);//left
    if(rightTank == 89) {
      closeRightTank();
    }
    if(rightTank == -100) {
      openRightTank();
    }
    if(leftTank == -105) {
      closeLeftTank();
    }
    if(leftTank == 81) {
      openLeftTank();
    } 
    return;
  }
  externalControl = false;
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
int BoatController::adjustHeading(double relativeBear, int speedComand)
{    

  if(speedComand == 100 && !calibrationRun) {
    startCalibration();
  }

  if(speedComand > 50) {
      float s = (speed/100.0) * speedComand;
      signalSpeed = int(s);
  } else {
    signalSpeed = speedComand;
  }

  rBearing = relativeBear;
  
  int servoValue = map(relativeBear, -90, 90, 0, 180);  

  //steer(servoValue);
  adjustCourse(servoValue);
  gas();

  return servoValue;
}

 void BoatController::stopEngines()
 {
    enginesEnabled = false;
    if(externalControl) {
      return;
    }
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
 void BoatController::setSteeringCalibration(int c) {
  STEERING_CALIBRATION = c;
}
 void BoatController::setSteeringDelay(int c) {
  STEERING_DELAY = c;
}

 int BoatController::getSteeringCalibration() {
  return STEERING_CALIBRATION;
}
 int BoatController::getSteeringDelay() {
  return STEERING_DELAY;
}
