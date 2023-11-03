#include "Navigator.h"
#include <TinyGPS++.h>
#include <SoftwareSerial.h>

//#define TEST_DATA;

static const int RXPin = 11, TXPin = 12;
static const uint32_t GPSBaud = 9600;
const int numReadings = 10;
float readings[numReadings]; 
int readIndex = 0;

TinyGPSPlus gps;
SoftwareSerial ss(RXPin, TXPin);



/**********************************************
 * Interrupt Vector
 * This function is called every millisecond
 * to check for new GPS data.
 **********************************************/
//SIGNAL(TIMER0_COMPA_vect) 
//{
  //GPS.read();
//}

/**********************************************
 * useInterrupt()
 * Activates or deactivates the interrupt.
 **********************************************/
void Navigator::useInterrupt(boolean v) 
{
  //if (v) 
  //{
    // See datasheet to understand this lower-level sorcery
  //  OCR0A = 0xAF;
  //  TIMSK0 |= _BV(OCIE0A);
  //  usingInterrupt = true;
  //} 
  //else 
  //{
    // do not call the interrupt function COMPA anymore
   //TIMSK0 &= ~_BV(OCIE0A);
    usingInterrupt = false;
  //}
}

void Navigator::begin(void)
{
  // *** GPS ***
  ss.begin(GPSBaud);
  useInterrupt(false);
  // *** Comapss ***
  //compass.begin();  

  #ifdef TEST_DATA
    testData[0] = {lat: 44.40361347409284, lng: 26.1065200269528};
    testData[1] = {lat: 44.4042393773705, lng: 26.107497350419745};
    testData[2] = {lat: 44.403700188955085, lng: 26.10517095331531};
    testData[3] = {lat: 44.40401008393323, lng: 26.106513105476964};
    testData[4] = {lat: 44.40439223915705, lng: 26.10727560351663};
    testData[5] = {lat: 44.404217142891625, lng: 26.106518940921145};
    testData[6] = {lat: 44.40416850494713, lng: 26.10539075504613};
    testData[7] = {lat: 44.404321366922275, lng: 26.106513105476964};
    testData[8] = {lat: 44.404503411117034, lng: 26.107059692081933};
    testData[9] = {lat: 44.40437834264718, lng: 26.106516995773084};
    testData[10] = {lat: 44.40424910494743, lng: 26.10524875923773};
    testData[11] = {lat: 44.404468669902236, lng: 26.106513105476964};
    testData[12] = {lat: 44.4044936835889, lng: 26.10652283122215};
    testData[13] = {lat: 44.40447839745438, lng: 26.10567474666783};
    testData[14] = {lat: 44.40476466439481, lng: 26.106513105501197};
    //testData[15] = {lat: 44.4047712212359, lng: 26.106709707119737};
    //testData[16] = {lat: 44.4047625982959, lng: 26.106700319388686};
    //testData[17] = {lat: 44.404753960198214, lng: 26.10668608266575};//second waypoint
  #endif

}


void addValue(float value) {
  // Shift all values to the left
  for (int i = 0; i < numReadings - 1; i++) {
    readings[i] = readings[i + 1];
  }

  // Add the new value at the end
  readings[numReadings - 1] = value;
}

float getAverage() {
  float total = 0.0;
  for (int i = 0; i < numReadings; i++) {
    total += readings[i];
  }
  return total / numReadings;
}

double Navigator::getDistance(void)
{
  while (ss.available()) {
    if(gps.encode(ss.read())) {
      break;
    }
                        
  }
  
  double deltaLat = getLat() - targetLat;
  double deltaLon = getLng() - targetLon;
  double distance = sqrt(deltaLat * deltaLat + deltaLon * deltaLon) * 100000;
  #ifdef TEST_DATA
    runningTestIndex++;
  #endif
  return distance;
}

void Navigator::setTarget(double lat, double lon)
{
  targetLat = lat;
  targetLon = lon; 
}

double Navigator::readCompass(void)
{
  double heading = gps.course.deg() + MAGNETIC_DECLINATION;
  if(heading < 0) {
    heading  = heading + 360;
  } else if(heading > 360) {
    heading = heading - 360;
  }
  return heading;
  
}

float Navigator::getLat() {  
  #ifdef TEST_DATA
    return testData[runningTestIndex].lat;
  #endif
  return gps.location.lat();
}


float Navigator::getLng() {
  #ifdef TEST_DATA
    return testData[runningTestIndex].lng;
  #endif
  return gps.location.lng();
}

void Navigator::setCompassCalibration(int c) {
  CALIBRATION = c;
}

/**********************************************
 * getRelativeBearing()
 * Calculate the angle from the front of the
 * boat to the target. If the target is to the
 * right of the boat, the angle will negative.
 **********************************************/
double Navigator::getRelativeBearing(double* headingValue)
{
  double bearing = atan2(targetLon - getLng(), targetLat - getLat() ) * 180 / 3.14159265359;
  
  //read heading from compass
  //double headingDegrees = gps.course.deg();
  double headingDegrees = readCompass();
  
  
  *headingValue = headingDegrees;
  
  double relativeBearing = headingDegrees - bearing;
  
  // Normalize such that the front of the boat reresents 0 degrees, and left is negative
  if (relativeBearing > 180) {
    relativeBearing -= 360;
  }
    

    //Serial.println(relativeBearing);


  return relativeBearing; 
}

bool Navigator::hasFix()
{  
  while(gps.satellites.value() < 4 || gps.hdop.hdop() > 2) {
    bool hasFix = false;
    while (ss.available()) {
      if(gps.encode(ss.read())) 
         if(gps.location.isValid())
            hasFix = true;
    }
    if(hasFix) {
      return true;
    }
    else return false;
  }
}
