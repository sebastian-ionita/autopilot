#include <SPI.h>
#include <LoRa.h>
#include "LoRaMessenger.h"

/*******************************************************************************************/

void LoRaMessenger::begin(void (*onReceive)(int))
{
  Serial.println("LoRaMessenger");
  if (!LoRa.begin(433E6)) {             // initialize ratio at 915 MHz
    Serial.println("LoRa init failed. Check your connections.");
    while (true);                       // if failed, do nothing
  }
  LoRa.setTxPower(20);
  LoRa.onReceive(onReceive);
  LoRa.receive();
}

/*******************************************************************************************/

void LoRaMessenger::send(String message)
{
  //noInterrupts();
  LoRa.beginPacket();
  LoRa.print(message);
  LoRa.endPacket(true);
  LoRa.receive();  
  //interrupts();  
}

double LoRaMessenger::parseDouble(String message, String startMarker) {
  int startIndex = message.indexOf(startMarker); // Find the start marker
  int endIndex = message.indexOf(endMarker, startIndex + startMarker.length()); // Find the end marker
  double value = 0.0;

  if (startIndex >= 0 && endIndex > startIndex) {
    String doubleStr = message.substring(startIndex + startMarker.length(), endIndex); // Extract the substring between markers

    for (int i = 0; i < doubleStr.length(); i++) {
      char ch = doubleStr[i];
      if (!isdigit(ch) && ch != '.') {
        return 0.0; // Return 0.0 immediately upon encountering an invalid character
      }
    }

    char* endPtr;
    value = strtod(doubleStr.c_str(), &endPtr); // Convert the substring to a double
    if (doubleStr == endPtr) {
      value = 0.0; // Conversion failed, assign default value
    }
  }
  
  return value;
}

int LoRaMessenger::parseInt(String message, const String startMarker) {
  int result = -1;

  int startIndex = message.indexOf(startMarker); // Find the start marker
  int endIndex = message.indexOf(endMarker, startIndex + startMarker.length()); // Find the end marker

  if (startIndex >= 0 && endIndex > startIndex) {
    String intStr = message.substring(startIndex + startMarker.length(), endIndex); // Extract the substring between markers

    String digits = "";
    for (int i = 0; i < intStr.length(); i++) {
      char digit = intStr[i];

      // Check if the character is a valid digit
      if (isdigit(digit)) {
        digits += digit;
      } else {
        digits = ""; // Reset the digits string if an invalid character is found
        break;
      }
    }

    if (digits.length() > 0) {
      result = digits.toInt(); // Convert the valid digits to an int
    }
  }

  return result;
}



int LoRaMessenger::parseInt(String message, const String startMarker, const String endMarker) {
  int result = -1;

  int startIndex = message.indexOf(startMarker); // Find the start marker
  int endIndex = message.indexOf(endMarker, startIndex + startMarker.length()); // Find the end marker

  if (startIndex >= 0 && endIndex > startIndex) {
    String intStr = message.substring(startIndex + startMarker.length(), endIndex); // Extract the substring between markers

    String digits = "";
    for (int i = 0; i < intStr.length(); i++) {
      char digit = intStr[i];

      // Check if the character is a valid digit
      if (isdigit(digit)) {
        digits += digit;
      } else {
        digits = ""; // Reset the digits string if an invalid character is found
        break;
      }
    }

    if (digits.length() > 0) {
      result = digits.toInt(); // Convert the valid digits to an int
    }
  }

  return result;
}

LoraLatLong LoRaMessenger::parseLatLong(String message, String startMarker) {
  String delimiter = "@,";
  String tankDelimiter = "||";
  String indexDelimiter = "##";
  LoraLatLong result = {
    lat: 0.00,
    lng: 0.00,
    tankLeft: -1,
    tankRight: -1,
    index: -1
  };
  
  int startIndex = message.indexOf(startMarker); // Find the start marker
  int endIndex = message.indexOf(tankDelimiter, startIndex + startMarker.length()); // Find the end marker

  if (startIndex >= 0 && endIndex > startIndex) {
    String doubleStr = message.substring(startIndex + startMarker.length(), endIndex); // Extract the substring between markers

    int delimiterIndex = doubleStr.indexOf(delimiter); // Find the delimiter index
    if (delimiterIndex >= 0) {
      String double1Str = "";
      String double2Str = "";

      // Parse the first double substring
      for (int i = 0; i < delimiterIndex; i++) {
        char ch = doubleStr[i];
        if (isdigit(ch) || ch == '.') {
          double1Str += ch;
        } else {
          return result; // return immediately upon encountering an invalid character
        }
      }

      // Parse the second double substring
      for (int i = delimiterIndex + delimiter.length(); i < doubleStr.length(); i++) {
        char ch = doubleStr[i];
        if (isdigit(ch) || ch == '.') {
          double2Str += ch;
        } else {
          return result; // Return immediately upon encountering an invalid character
        }
      }

      char* endPtr;
      result.lat = strtod(double1Str.c_str(), &endPtr); // Convert the first substring to a double
      if (double1Str == endPtr) {
        result.lat = 0.0; // Conversion failed, assign default value
      }

      endPtr = nullptr;
      result.lng = strtod(double2Str.c_str(), &endPtr); // Convert the second substring to a double
      if (double2Str == endPtr) {
        result.lng = 0.0; // Conversion failed, assign default value
      }
    }
  }

  //WP:123.22@,33.44||1@,0##1-*

  String secondMessage = message.substring(endIndex, message.length());
  int tank1 = parseInt(secondMessage, tankDelimiter, delimiter);
  int tank2 = parseInt(secondMessage, delimiter, indexDelimiter);
  int index = parseInt(secondMessage, indexDelimiter, endMarker);
  if(tank1 ==-1 || tank2 == -1 || index == -1) {
      LoraLatLong resultDefault = {
      lat: 0.00,
      lng: 0.00,
      tankLeft: -1,
      tankRight: -1,
      index: -1
    };
    return resultDefault;
  }


  result.tankLeft = tank1;
  result.tankRight = tank2;
  result.index = index;
  
  return result;
}
