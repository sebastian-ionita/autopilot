#include "Navigator.h"

#include <TinyGPS++.h>
#include <SoftwareSerial.h>

//SoftwareSerial softSerial(8, 7); // These pins may change depending on what board you're using
//Adafruit_GPS GPS(&softSerial);

static const int RXPin = 11, TXPin = 12;
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
    //usingInterrupt = false;
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
  useInterrupt(false);
  // *** Comapss ***
  if(!compass.begin())
  {
    /* There was a problem detecting the HMC5883 ... check your connections */
    Serial.println("Ooops, no HMC5883 detected ... Check your wiring!");
    while(1);
  }
  if(compass.isHMC()){
        Serial.println("Initialize HMC5883");
        compass.setRange(HMC5883L_RANGE_1_3GA);
        compass.setMeasurementMode(HMC5883L_CONTINOUS);
        compass.setDataRate(HMC5883L_DATARATE_15HZ);
        compass.setSamples(HMC5883L_SAMPLES_8);
    }
   else if(compass.isQMC()){
        Serial.println("Initialize QMC5883");
        compass.setRange(QMC5883_RANGE_2GA);
        compass.setMeasurementMode(QMC5883_CONTINOUS); 
        compass.setDataRate(QMC5883_DATARATE_50HZ);
        compass.setSamples(QMC5883_SAMPLES_8);
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
  double distance = sqrt(deltaLat * deltaLat + deltaLon * deltaLon) * 100000;
  return distance;
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
  Vector norm = compass.readNormalize();
  // Calculate heading
  float heading = atan2(norm.YAxis, norm.XAxis);
  // Set declination angle on your location and fix heading
  // You can find your declination on: http://magnetic-declination.com/
  // (+) Positive or (-) for negative
  // For Bytom / Poland declination angle is 4'26E (positive)
  // Formula: (deg + (min / 60.0)) / (180 / M_PI);
  float declinationAngle = (6.0 + (13.0 / 60.0)) / (180 / PI);
  heading += declinationAngle;
  // Correct for heading < 0deg and heading > 360deg
  if (heading < 0){
    heading += 2 * PI;
  }
  if (heading > 2 * PI){
    heading -= 2 * PI;
  }
  // Convert to degrees
  float headingDegrees = heading * 180/M_PI; 
  
  //return 360 - headingDegrees;
  #ifdef DEBUG
  Serial.print("heading:");
  Serial.println(headingDegrees);
  #endif
  return headingDegrees;
  
  
  // Output
  //Serial.print(" Heading = ");
  //Serial.print(heading);
  //Serial.print(" Degress = ");
  //maybe remove this 360 orientation change
  //Serial.print(360 - headingDegrees);
  //Serial.print(" Azimuth direction = ");
  //Serial.print(getAzimuthHeading(headingDegrees));
  //Serial.println();
  //lsm.read(); // Read from magnometer
  //sensors_event_t event; 
  //mag.getEvent(&event);
  //float heading = atan2(event.magnetic.y, event.magnetic.x) * 180 / 3.14159265359; // Convert to degrees  
  //heading += 180; //I have the compass sitting sideways  
  //Serial.print("Heading:"); 
  //Serial.println(heading);
  // Normalize to 0-360
  //if (heading < 0)
  //  heading = 360 + heading;
    
  //return heading; 
}

float Navigator::getLat() {
  return gps.location.lat();
}


float Navigator::getLng() {
  return gps.location.lng();
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
  double bearing = atan2(targetLon - gps.location.lat(), targetLat - gps.location.lng() ) * 180 / 3.14159265359;
  #ifdef DEBUG
  Serial.print("bearing:");
  Serial.println(bearing);
  #endif
  
  
  // Relative bearing
  //double relativeBearing = readCompass() - bearing + MAGNETIC_DECLINATION + CALIBRATION;
  double relativeBearing = readCompass() - bearing + CALIBRATION;
  
  // Normalize such that the front of the boat reresents 0 degrees, and left is negative
  if (relativeBearing > 180)
    relativeBearing -= 360;

  //Serial.print("Bearing:"); Serial.println(relativeBearing);
  return relativeBearing; 
}


/**********************************************
 * hasFix()
 * Returns true if the GPS has a signal fix
 **********************************************/
bool Navigator::hasFix()
{
  
  while(gps.satellites.value() < 4 || gps.hdop.hdop() > 2) {
    //Serial.println(gps.satellites.value());
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
