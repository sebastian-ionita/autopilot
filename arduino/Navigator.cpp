#include "Navigator.h"

#include <TinyGPS++.h>
#include <SoftwareSerial.h>

//SoftwareSerial softSerial(8, 7); // These pins may change depending on what board you're using
//Adafruit_GPS GPS(&softSerial);

static const int RXPin = 11, TXPin = 10;
static const uint32_t GPSBaud = 9600;

// The TinyGPS++ object
TinyGPSPlus gps;

// The serial connection to the GPS device
SoftwareSerial ss(RXPin, TXPin);


/**********************************************
 * Interrupt Vector
 * This function is called every millisecond
 * to check for new GPS data.
 **********************************************/
SIGNAL(TIMER0_COMPA_vect) 
{
  //GPS.read();
}


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
   // TIMSK0 &= ~_BV(OCIE0A);
   // usingInterrupt = false;
  //}
}


/**********************************************
 * begin()
 * Initialize all the navigational subsystems.
 **********************************************/
void Navigator::begin(void)
{
  // *** GPS ***
  ss.begin(GPSBaud);

  // *** Comapss ***
  if(!mag.begin())
  {
    /* There was a problem detecting the HMC5883 ... check your connections */
    Serial.println("Ooops, no HMC5883 detected ... Check your wiring!");
    while(1);
  }

}


/**********************************************
 * getDistance()
 * Returns distance from the current target.
 * The distance is not measured in a known unit.
 * Under the assumption that the boat is not 
 * going to traverse any long distance, the
 * cartesian distance between to lat/lon points
 * is used for distance, and then scaled up to
 * an integer value. Basically were assuming
 * the earth is flat. 
 **********************************************/
double Navigator::getDistance(void)
{  
   while (ss.available()) {
    if(gps.encode(ss.read()))
        break;                    
  }
  double deltaLat = gps.location.lat() - targetLat;
  double deltaLon = gps.location.lng() - targetLon;
  return sqrt(deltaLat * deltaLat + deltaLon * deltaLon) * 100000;
}


/**********************************************
 * setTarget()
 * Used to set the lat/lon of the current
 * target from which the navigational operations
 * will be calculated.
 **********************************************/
void Navigator::setTarget(double lat, double lon)
{
  targetLat = lat;
  targetLon = lon; 
}


/**********************************************
 * readCompass()
 * Read the raw magnometer data and return it
 * as degrees.
 **********************************************/
double Navigator::readCompass(void)
{
  //lsm.read(); // Read from magnometer
  sensors_event_t event; 
  mag.getEvent(&event);
  float heading = atan2(event.magnetic.y, event.magnetic.x) * 180 / 3.14159265359; // Convert to degrees  
  //heading += 180; //I have the compass sitting sideways  
  
  // Normalize to 0-360
  if (heading < 0)
    heading = 360 + heading;
    
  return heading; 
}

/**********************************************
 * getRelativeBearing()
 * Calculate the angle from the front of the
 * boat to the target. If the target is to the
 * right of the boat, the angle will negative.
 **********************************************/
double Navigator::getRelativeBearing(void)
{
 
  // Calculate angle from current position to target with respect to North
  double bearing = atan2(targetLon - gps.location.lat(), targetLat - gps.location.lng() ) * 180 / 3.14159265359;;
  
  // Relative bearing
  double relativeBearing = readCompass() - bearing + MAGNETIC_DECLINATION + CALIBRATION;
  
  // Normalize such that the front of the boat reresents 0 degrees, and left is negative
  if (relativeBearing > 180)
    relativeBearing -= 360;

  Serial.print("Bearing:"); Serial.println(relativeBearing);
  return relativeBearing; 
}


/**********************************************
 * hasFix()
 * Returns true if the GPS has a signal fix
 **********************************************/
bool Navigator::hasFix()
{
  while(gps.satellites.value() < 4 || gps.hdop.hdop() > 2) {
    bool hasFix = false;
    while (ss.available()) {
      if(gps.encode(ss.read())) 
         if(gps.location.isValid())
            hasFix = true;
    }
    if(hasFix) return true;
    else return false;
  }
}
