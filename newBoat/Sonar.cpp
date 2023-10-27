
#include <Arduino.h>
#include "Sonar.h"

#define TRIG_PIN 6
#define ECHO_PIN 7

unsigned long previousMillis = 0;
const long interval = 100; // Interval for distance reading (in milliseconds)
long duration;
float waterDepth = 0.00;

void Sonar::begin() {
    pinMode(TRIG_PIN, OUTPUT); 
    pinMode(ECHO_PIN, INPUT);  
}

void Sonar::update() {
    unsigned long currentMillis = millis();

if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;

    // Generate ultrasonic wave
    digitalWrite(TRIG_PIN, LOW);
    delayMicroseconds(2);
    digitalWrite(TRIG_PIN, HIGH);
    delayMicroseconds(10);
    digitalWrite(TRIG_PIN, LOW);

    // Measure how long the echo pin was high
    duration = pulseIn(ECHO_PIN, HIGH);

    // Calculate distance
    waterDepth = (duration * 0.1500) / 2; // Speed of sound in freshwater is approx 1500m/s or 0.1500 cm/microsecond
    //waterDepth = (duration * 0.0344) / 2; // Speed of sound in air is approx 343m/s or 0.0344 cm/microsecond


    // Print distance
    Serial.print("Underwater Distance: ");
    Serial.print(waterDepth);
    Serial.println(" cm");
  }
}

double Sonar::read() {
   return waterDepth;
}