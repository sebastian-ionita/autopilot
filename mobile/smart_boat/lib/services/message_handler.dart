import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:print_color/print_color.dart';
import 'package:smart_boat/ui/base/utils/utils.dart';
import 'package:smart_boat/ui/models/app_state.dart';

const int XON = 0x11; // ASCII code for XON (Resume transmission)
const int XOFF = 0x13; // ASCII code for XOFF (Pause transmission)

class MessageHandlerService {
  AppState appState;
  BuildContext context;
  MessageHandlerService({required this.appState, required this.context});

  String receivedMessage = '';

  void onMessageReceived(List<int> messageBytes) {
    var message = String.fromCharCodes(messageBytes);
    if (message.contains(String.fromCharCode(XON))) {
      Print.red("Resume data transmission");
      // Resume data transmission
      // Implement any necessary actions here
    } else if (message.contains(String.fromCharCode(XOFF))) {
      Print.red("Pause data transmission");
    }

    if (message.endsWith("*")) {
      receivedMessage += message;
      handleMessage(receivedMessage);
      receivedMessage = ''; //reset message
    } else if (message.indexOf("*") > 0) {
      var messageInParts = message.split("*");
      receivedMessage += "${messageInParts[0]}*";
      handleMessage(receivedMessage);
      receivedMessage = messageInParts[1];
    } else {
      receivedMessage += message;
    }
  }

  final DateFormat formatter = DateFormat('hh:mm');

  void handleMessage(String messageToProcess) {
    messageToProcess = messageToProcess.replaceAll("*", ""); //rem flag
    appState.addMessage(
        "[${formatter.format(DateTime.now().toLocal())}] $messageToProcess");

    //package finished sending, handle the message and make receive message null
    Print.green(messageToProcess);
    if (messageToProcess.startsWith("N:")) {
      try {
        //boat location was received, update state property
        messageToProcess = messageToProcess.replaceAll("N:", "");
        //show notification
        Utils.showSnack(SnackTypes.Info, messageToProcess, context);

        appState.refresh();
      } catch (e) {
        Print.red("Error on handling notification message: $e");
      }
    } else if (messageToProcess.startsWith("BL:")) {
      //BOAT LOCATION
      try {
        //Print.green(receivedMessage);
        //boat location was received, update state property
        messageToProcess = messageToProcess.replaceAll("BL:", "");
        var params = messageToProcess.split(",");
        var lat = params[0];
        var lng = params[1];
        appState.setBoatLocation(LatLng(double.parse(lat), double.parse(lng)));
        appState.refresh();
      } catch (e) {
        Print.red("Error on parsing BOAT LOCATION: $e");
      }
    } else if (messageToProcess.startsWith("INFO:")) {
      //BOAT LOCATION
      try {
        //Print.green(receivedMessage);
        //boat location was received, update state property
        messageToProcess = messageToProcess.replaceAll("INFO:", "");

        Utils.showSnack(SnackTypes.Info, messageToProcess, context);
      } catch (e) {
        Print.red("Error on parsing BOAT LOCATION: $e");
      }
    } else if (messageToProcess.startsWith("SW:")) {
      //BOAT LOCATION
      try {
        Print.green(messageToProcess);
        //boat location was received, update state property
        var validationMessage = messageToProcess.replaceAll("SW:", "");
        appState.selectedFishingTrip!.routine!
            .validateSteps(appState, validationMessage);

        Utils.showSnack(SnackTypes.Info, messageToProcess, context);
      } catch (e) {
        Print.red("Error on parsing BOAT POINTS: $e");
      }
    } else if (messageToProcess.startsWith("LD:")) {
      //LIVE BOAT DATA
      try {
        Print.green(receivedMessage);
        //boat location was received, update state property
        messageToProcess = messageToProcess.replaceAll("LD:", "");
        Print.yellow(messageToProcess);

        var params = messageToProcess.split("|");

        var distance = params[0];
        var heading = params[1];
        var relativeBearing = params[2];
        var rudderPos = params[3];
        var motorSpeed = params[4];
        var locationData = params[5];
        //parse location
        var locationParams = locationData.split(",");
        var lat = locationParams[0];
        var lng = locationParams[1];

        appState.setBoatLocation(LatLng(double.parse(lat), double.parse(lng)));

        appState.setLiveData(
            distance, heading, relativeBearing, rudderPos, motorSpeed);

        //appState.refresh();
      } catch (e) {
        Print.red("Error on parsing boat LIVE DATA: $e");
      }
    } else {
      //Print.green(receivedMessage);
    }
  }
}
