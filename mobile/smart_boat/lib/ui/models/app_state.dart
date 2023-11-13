import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:print_color/print_color.dart';
import 'package:smart_boat/services/secure_storage_service.dart';
import 'package:smart_boat/ui/models/boat_config.dart';
import 'package:smart_boat/ui/models/data_received_provider.dart';
import 'package:smart_boat/utils.dart';
import 'boat_data.dart';
import 'fishing_trip.dart';

class AppState extends ChangeNotifier {
  AppState({required this.boatLocation, required this.fishingTrips}) {}
  SecureStorageService secureStorageService = SecureStorageService();

  late LatLng? boatLocation;
  late BoatData? boatLiveData = null;
  late BoatConfig? boatConfig = null;
  late List<FishingTrip> fishingTrips = [];
  late FishingTrip? selectedFishingTrip = null;
  late int? selectedFishingTripIndex;
  late GoogleMapController mapController;
  late DataReceived _dataReceived;
  bool listening = false;
  List<String> infoMessages = [];

  void setDataReceived(DataReceived dataReceivedProvider) {
    _dataReceived = dataReceivedProvider;
  }

  void addMessage(String message) {
    infoMessages.add(message);
    saveState();
    notifyListeners();
  }

  void setGoogleMapController(GoogleMapController controller) {
    mapController = controller;
  }

  void setListening(bool listen) {
    listening = listen;
    notifyListeners();
  }

  void addFishingTrip(FishingTrip trip) {
    fishingTrips.add(trip);
    //add fishing trip and save state
    setSelectedFishingTrip(trip);

    refresh();
  }

  void setBoatLocation(LatLng loc) {
    boatLocation = loc;
    notifyListeners();
    saveState();
  }

  void setFinishedRoutine(String routineId) {
    for (var trip in fishingTrips) {
      if (trip.routine!.id == routineId) {
        //set selected fishinf trip to the current routine trip
        if (selectedFishingTrip!.name != trip.name) {
          setSelectedFishingTrip(trip);
        }
        //set running routine
        trip.routine!.running = false;
        notifyListeners();

        return;
      }
    }
  }

  void setRunningRoutine(
      String routineId, int currentStepIndex, LatLng newPoint) {
    for (var trip in fishingTrips) {
      if (trip.routine!.id == routineId) {
        //set selected fishinf trip to the current routine trip
        if (selectedFishingTrip!.name != trip.name) {
          setSelectedFishingTrip(trip);
        }
        //set running routine
        trip.routine!.running = true;
        //set running index
        trip.routine!.steps[currentStepIndex].running = true;
        //set new point on the path
        if (trip.routine!.routinePath.isNotEmpty) {
          var lastPoint = trip.routine!.routinePath.last;
          if (LocationUtils.arePointsInRadius(newPoint, lastPoint, 10)) {
            trip.routine!.routinePath.add(newPoint); //add point
          }
        } else {
          //routine empty, add point
          trip.routine!.routinePath.add(newPoint); //add point
        }
        return;
      }
    }
  }

  void setReachedRoutineWaypointIndex(String routineId, int currentStepIndex) {
    for (var trip in fishingTrips) {
      if (trip.routine!.id == routineId) {
        //set running index
        trip.routine!.steps[currentStepIndex].reached = true;
        notifyListeners();

        return;
      }
    }
  }

  void setLiveData(String distance, String heading, String relativeBearing,
      String rudderPosition, String motorSpeed) {
    _dataReceived.setFlag();
    boatLiveData = BoatData(
        distance: distance,
        heading: heading,
        relativeBearing: relativeBearing,
        motorSpeed: motorSpeed,
        rudderPosition: rudderPosition);
    notifyListeners();
    saveState();
  }

  void setBoatConfig(
      String proximity, String rudderOffset, String rudderDelay) {
    boatConfig = BoatConfig(
        proximity: proximity,
        rudderOffset: rudderOffset,
        rudderDelay: rudderDelay);
    notifyListeners();
    saveState();
  }

  void removeFishingTrip(FishingTrip tripToRemove) {
    fishingTrips.removeWhere((ft) => ft.name == tripToRemove.name);
    if (fishingTrips.isNotEmpty) {
      setSelectedFishingTrip(fishingTrips.first);
    } else {
      setSelectedFishingTrip(null);
    }

    refresh();
  }

  void setSelectedFishingTrip(FishingTrip? trip) {
    if (trip != null) {
      trip.routine!.running = false;
      trip.routine!.routinePath = [];
      trip.routine!.clearProgress();
    }

    selectedFishingTrip = trip;
    selectedFishingTripIndex = trip != null ? fishingTrips.indexOf(trip) : -1;
    Print.cyan("Selected fishing trip index: $selectedFishingTripIndex");

    if (selectedFishingTrip != null) {
      var tripPosition = selectedFishingTrip!.mapPosition;
      if (tripPosition != null) {
        final position = CameraPosition(
          target: LatLng(tripPosition.targetLat, tripPosition.targetLng),
          zoom: tripPosition.zoom,
          bearing: tripPosition.rotation,
        );
        mapController.animateCamera(CameraUpdate.newCameraPosition(position));
      }
    }

    //set selected fishing trip and save state
    notifyListeners();
    saveState();
  }

  void refresh() {
    notifyListeners();
  }

  void saveState() {
    //save state to local storage
    secureStorageService.addItem("appState", jsonEncode(toJson()));
  }

  // Convert a JSON object into an AppState object.
  factory AppState.fromJson(Map<String, dynamic> json) {
    var fishingTripsList = json['fishingTrips'] as List;
    List<FishingTrip> fishingTrips =
        fishingTripsList.map((e) => FishingTrip.fromJson(e)).toList();

    return AppState(
        boatLocation: json['boatLocation'] != null
            ? LatLng.fromJson(json['boatLocation'])
            : null,
        fishingTrips: fishingTrips);
  }

  // Convert this AppState object into a JSON object.
  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> fishingTripsJson =
        fishingTrips.map((trip) => trip.toJson()).toList();

    return {
      'boatLocation': boatLocation != null ? boatLocation!.toJson() : null,
      'fishingTrips': fishingTripsJson
    };
  }
}
