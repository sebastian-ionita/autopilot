import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:print_color/print_color.dart';
import 'package:smart_boat/services/secure_storage_service.dart';
import 'boat_data.dart';
import 'fishing_trip.dart';

class AppState extends ChangeNotifier {
  AppState({required this.boatLocation, required this.fishingTrips}) {}
  SecureStorageService secureStorageService = SecureStorageService();

  late LatLng? boatLocation;
  late BoatData? boatLiveData;
  late List<FishingTrip> fishingTrips = [];
  late FishingTrip? selectedFishingTrip = null;
  late GoogleMapController mapController;
  bool listening = false;
  List<String> receivedMessages = [];

  void addMessage(String message) {
    receivedMessages.add(message);
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
    saveState();
    notifyListeners();
  }

  void setBoatLocation(LatLng loc) {
    boatLocation = loc;
    notifyListeners();
    saveState();
  }

  void setLiveData(String distance, String heading, String relativeBearing,
      String rudderPosition, String motorSpeed) {
    boatLiveData = BoatData(
        distance: distance,
        heading: heading,
        relativeBearing: relativeBearing,
        motorSpeed: motorSpeed,
        rudderPosition: rudderPosition);
    notifyListeners();
    saveState();
  }

  void removeFishingTrip(FishingTrip tripToRemove) {
    if (selectedFishingTrip != null &&
        selectedFishingTrip!.name == tripToRemove.name) {
      selectedFishingTrip = null;
    }

    fishingTrips.removeWhere((ft) => ft.name == tripToRemove.name);
    notifyListeners();
    saveState();
  }

  void setSelectedFishingTrip(FishingTrip trip) {
    selectedFishingTrip = trip;

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
