import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:google_maps_flutter_web/google_maps_flutter_web.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_remix/flutter_remix.dart';

class MapDisp extends StatefulWidget {
  const MapDisp({super.key});

  @override
  State<MapDisp> createState() => _MapDispState();
}

class _MapDispState extends State<MapDisp> {
  void initState() {
    super.initState();
    _determinePosition();
     }
  final user = FirebaseAuth.instance.currentUser!;
  //Map<String, dynamic>? 
  Map<MarkerId, Marker> _markers = <MarkerId, Marker>{};
    initMarker(request) {
    var p = request['lat'];
    var markerIdVal = request['name'];
    final MarkerId markerId = MarkerId(markerIdVal);
    final Marker marker = Marker(
        markerId: markerId,
        position:
            LatLng(p[0], p[1]),
        infoWindow: InfoWindow(
          title: request['name'],
        ));
    setState(() {
      _markers[markerId] = marker;

    });
  }
   Future _populateMarks() async{
    //initMarker({'name':'Example','lat':[10.851274920328036, 77.0527618629687]});
    FirebaseFirestore.instance.collection('hospitals').get().then((QuerySnapshot doc){
      if(doc.docs.isNotEmpty){
        print(doc.docs[0].data);
        for(int i = 0; i < doc.docs.length; i++){
          initMarker(doc.docs[i].data);
        }
      }
    });
  }

  Completer<GoogleMapController> _controller = Completer();

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
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
    return Scaffold(
      body: GoogleMap(
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
        onMapCreated: (GoogleMapController controller) async{
          _controller.complete(controller);
          await _populateMarks();
        },
      ),
      floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          child: Icon(
            FlutterRemix.user_location_line,
            color: Colors.black,
          ),
          onPressed: () async {
            Position position = await _determinePosition();
            final GoogleMapController controller = await _controller.future;
            await _populateMarks();
            print(_markers);
            //print(_hospitalData);
            controller
                .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                    target: LatLng(
                      position.latitude,
                      position.longitude,
                    ),
                    zoom: 14.4746)));
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
