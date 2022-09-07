import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:url_launcher/url_launcher.dart';

class MapDisp extends StatefulWidget {
  const MapDisp({super.key});

  @override
  State<MapDisp> createState() => _MapDispState();
}

class _MapDispState extends State<MapDisp> {
  List<Marker> markers = [];

  void initState() {
    super.initState();
    _determinePosition();
    markers.add(Marker(
        markerId: MarkerId('mymarker'),
        draggable: false,
        onTap: () => print('tapped'),
        position: LatLng(0, 0),
        infoWindow: InfoWindow()));
  }

  bool _isHospitalSelected = false;
  final user = FirebaseAuth.instance.currentUser!;
  //Map<String, dynamic>?
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
  initMarker(request) {
    var p = request['lat'];
    var markerIdVal = request['name'];
    bool isPresent = request['isPresent'];
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
        icon: isPresent
            ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
            : BitmapDescriptor.defaultMarker,
        markerId: markerId,
        position: LatLng(p[0], p[1]),
        infoWindow: InfoWindow(
          title: request['name'],
          onTap: () {
            launchUrl(Uri.parse("google.navigation:q=${p[0]},${p[1]}"));
            setState(() {
              _isHospitalSelected = !_isHospitalSelected;
              _hospitalSelected = markerIdVal;
            });
          },
        ));
    setState(() {
      _markers[markerId] = marker;
    });
  }

  Future _populateMarks() async {
    FirebaseFirestore.instance
        .collection('hospitals')
        .get()
        .then((value) => value.docs.forEach((element) {
              initMarker(element);
            }));
  }

  String _hospitalSelected = '';

  Completer<GoogleMapController> _controller = Completer();

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      var snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'An Error Occurred',
          message:
              'Location Services are disabled.\nPlease try Again with location enabled',
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.bottomCenter, children: [
      GoogleMap(
        myLocationEnabled: true,
        zoomControlsEnabled: false,
        markers: Set.of(_markers.values),
        mapType: MapType.normal,
        myLocationButtonEnabled: false,
        initialCameraPosition: CameraPosition(
          // target: position == null
          //     ? LatLng(0.0, 0.0)
          //     : LatLng(position!.latitude, position!.longitude),
          target: LatLng(143.2, 154.78),
          zoom: 14.4746,
        ),
        onMapCreated: (GoogleMapController controller) async {
          _controller.complete(controller);
        },
      ),
      if (_isHospitalSelected)
        Align(
            alignment: Alignment.center,
            child: Card(
                color: Colors.indigoAccent,
                child: Text("Selected ${_hospitalSelected}"))),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 50,
          child: FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.white,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      FlutterRemix.user_location_line,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "Tap to get Data near your location",
                    style: TextStyle(color: Colors.black),
                  )
                ],
              ),
              onPressed: () async {
                Position position = await _determinePosition();
                final GoogleMapController controller = await _controller.future;
                await _populateMarks();
                //print(_hospitalData);
                controller.animateCamera(
                    CameraUpdate.newCameraPosition(CameraPosition(
                        target: LatLng(
                          position.latitude,
                          position.longitude,
                        ),
                        zoom: 14.4746)));
              }),
        ),
      ),
    ]);
  }
}
