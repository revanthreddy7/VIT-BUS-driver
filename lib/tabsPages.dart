import 'dart:async';

import 'package:driver_app/AllScreens/RegisterationScreen.dart';
import 'package:driver_app/AllWidgets/configMaps.dart';
import 'package:driver_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTabpage extends StatefulWidget
{
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  _HomeTabpageState createState() => _HomeTabpageState();
}

class _HomeTabpageState extends State<HomeTabpage> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();

  GoogleMapController newGoogleMapController;

  Position currentPosition;

  var geoLocator = Geolocator();

  String driverStatus = "OFFLINE Now";

  Color driverStatusColor = Colors.black87;

  bool isDriverAvailable = false;

  void locatePosition() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;
    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition = new CameraPosition(target: latLatPosition, zoom: 14);

    newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(

            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: HomeTabpage._kGooglePlex,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller)
            {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              locatePosition();

            }),

        //online offline driver container
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(

            height: 110,
              width: double.infinity,
            color: Colors.black54,



          ),
        ),

            Positioned(
              bottom: 75,
              left: 0,
              right: 0,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(driverStatus,
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        letterSpacing: 2
                      )
                    )
                  ),
                ],
              ),
            ),
        Positioned(
          bottom: 65,
          left: 0,
          right: 0,
          child:Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("click 'GO' to change",
                  style: GoogleFonts.lato(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 2
                      )
                  )
              ),
            ],
          ),
        ),



        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child:Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ButtonTheme(
                  height: 50,
                  minWidth: 100,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                    primary: driverStatusColor,
                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(40.0)),
                    ),



                    onPressed: (){


                      if(isDriverAvailable != true)
                        {
                          makeDriverOnlineNow();
                          getLocationLiveUpdates();

                          setState(() {
                            driverStatusColor = Colors.green;
                            driverStatus = "ONLINE now";
                            isDriverAvailable = true;
                          });

                          displayToastMessage("You are ONLINE Now", context);
                        }
                      else
                        {
                          makeDriverOffline();
                          displayToastMessage("You are OFFLINE Now", context);

                          setState(() {
                            driverStatusColor = Colors.black87;
                            driverStatus = "OFFLINE now";
                            isDriverAvailable = false;
                          });

                        }


                    },

                    child: Padding(
                      padding: EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                      child: Row(
                        children: [
                          Text("GO", style: TextStyle(fontSize: 30.0, color:Colors.black54),),

                        ],
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),



      ],
    );
  }

  void makeDriverOnlineNow() async
  {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    currentPosition = position;

    Geofire.initialize("availableDrivers");
    Geofire.setLocation(currentfirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);

    rideRequestRef.onValue.listen((event) {

    });
  }

  void getLocationLiveUpdates(){

    homeTabPageStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      currentPosition = position;
      if(isDriverAvailable == true)
        {
          Geofire.setLocation(currentfirebaseUser.uid, position.latitude, position.longitude);

        }
      LatLng latLng = LatLng(position.latitude,position.longitude);
      newGoogleMapController.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }
  void makeDriverOffline(){
    Geofire.removeLocation(currentfirebaseUser.uid);
    rideRequestRef.onDisconnect();
    rideRequestRef.remove();
  }
}
