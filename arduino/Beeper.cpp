#include "Beeper.h"
#include <Arduino.h>

void Beeper::begin(int speaker_pin)
{
  pin = speaker_pin;
  pinMode(pin, OUTPUT);  
  digitalWrite(pin, HIGH);
  
}

void Beeper::beep(int ms)
{
  digitalWrite(pin, LOW);
  delay(ms);
  digitalWrite(pin, HIGH);
}

void Beeper::beep3(void)
{
  digitalWrite(pin, LOW);
  delay(100);
  digitalWrite(pin, HIGH);
  delay(100);
  digitalWrite(pin, LOW);
  delay(100);
  digitalWrite(pin, HIGH);
  delay(100);
  digitalWrite(pin, LOW);
  delay(100);
  digitalWrite(pin, HIGH);
}

void Beeper::countdown(int mins)
{
  for(int i = 0; i < mins; i++)
  {
    beep(1000);
    delay(60000);
  }
  beep3();
}
