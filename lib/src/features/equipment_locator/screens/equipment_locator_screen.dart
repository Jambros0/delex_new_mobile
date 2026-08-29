import 'dart:convert';
import 'dart:ui' as ui;

import 'package:deex_bloc_mobile_app_dev/src/features/equipment_locator/bloc/equipment_locator_bloc.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/equipment_locator/bloc/equipment_locator_events.dart';
import 'package:deex_bloc_mobile_app_dev/src/features/functional_areas/data/models/location_model.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/auth_util.dart';
import 'package:deex_bloc_mobile_app_dev/src/utils/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:deex_bloc_mobile_app_dev/src/features/ex_register/data/models/ex_register_model.dart';
import '../bloc/equipment_locator_state.dart';

class EquipmentLocatorScreen extends StatefulWidget {
  final String? gpsCord;
  final dynamic assetId;
  const EquipmentLocatorScreen({super.key, this.gpsCord, this.assetId});

  @override
  EquipmentLocatorScreenState createState() => EquipmentLocatorScreenState();
}

class EquipmentLocatorScreenState extends State<EquipmentLocatorScreen> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  late CameraPosition cameraPosition;
  final DBHelper _dbHelper = DBHelper();
  final AuthUtils authUtils = AuthUtils();
  @override
  void initState() {
    super.initState();
    cameraPosition =
        const CameraPosition(target: LatLng(13.084301, 80.270462), zoom: 8);
    BlocProvider.of<EquipmentLocatorBloc>(context).add(LoadEquipmentLocator());
    // _searchController.addListener(() {
    //   if (_searchController.text.isEmpty) {
    //     _loadAllMarkers();
    //   }
    // });
    // _initMapData();
  }

  void _loadAllMarkers(EquipmentLocatorLoaded state) async {
    final groupedAssets = <String, List<ExRegister>>{};

    for (var asset in state.assets) {
      if (asset.locationId.isNotEmpty &&
          asset.locationLatitude?.isNotEmpty == true &&
          asset.locationLongitude?.isNotEmpty == true) {
        groupedAssets.putIfAbsent(asset.locationId, () => []).add(asset);
      }
    }

    final List<Future<Marker?>> markerFutures = [];

    for (var entry in groupedAssets.entries) {
      final assetsInLocation = entry.value;
      final representative = assetsInLocation.first;
      final matchingLocation = state.locationCollection
          .where((ele) => ele.id == representative.locationId)
          .firstOrNull;
      final lat = matchingLocation == null
          ? double.tryParse(representative.locationLatitude!.trim())
          : double.tryParse(matchingLocation.locationLatitude ?? '');
      final lng = matchingLocation == null
          ? double.tryParse(representative.locationLongitude!.trim())
          : double.tryParse(matchingLocation.locationLongitude ?? '');

      if (lat != null && lng != null) {
        final count = assetsInLocation.length;
        final customIcon =
            await createCustomMarkerFromAssetWithText(count.toString());

        markerFutures.add(Future.value(Marker(
          icon: customIcon,
          markerId: MarkerId(entry.key),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
              title: 'Assets: $count', snippet: representative.rfidRef),
        )));
      }
    }

    final markersList = await Future.wait(markerFutures);
    final markers = markersList.whereType<Marker>().toSet();

    if (mounted) {
      setState(() {
        _markers = markers;
        if (markers.isNotEmpty) {
          final first = markers.first.position;
          cameraPosition = CameraPosition(target: first, zoom: 8);
        }
      });
    }
  }

  void _initMapData(EquipmentLocatorLoaded state) async {
    if (widget.gpsCord != null && widget.gpsCord!.isNotEmpty) {
      final parts = widget.gpsCord!.split(',');
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) {
          // const double tolerance = 0.00001;
          // final matchingAssets = state.assets.where((a) {
          Location? location = state.locationCollection.where((ele) {
            final eleLat = double.tryParse(ele.locationLatitude ?? '');
            final eleLng = double.tryParse(ele.locationLongitude ?? '');
            double? roundTo5(double? value) =>
                value != null ? double.parse(value.toStringAsFixed(5)) : null;

            final rEleLat = roundTo5(eleLat);
            final rEleLng = roundTo5(eleLng);
            final rLat = roundTo5(lat);
            final rLng = roundTo5(lng);

            return rEleLat == rLat && rEleLng == rLng;
          }).firstOrNull;
          final String? userType = await authUtils.getUserType();
          final functionalAreaData = (userType == 'onshore')
              ? await _dbHelper.getFunctionalAreaByIdOnshore(widget.assetId)
              : await _dbHelper.getFunctionalAreaById(widget.assetId);
          final functionalAreaJson = functionalAreaData == null
              ? null
              : jsonDecode(functionalAreaData['functional_area_json']);
          Location getLocation =
              Location.fromJson(functionalAreaJson['location']);
          Location? loc = state.locationCollection
              .where((ele) => ele.id == getLocation.id)
              .firstOrNull;

          final matchingAssets =
              state.assets.where((a) => a.locationId == location?.id).toList();

          //   final aLat = double.tryParse(loc?.locationLatitude ?? '') ??
          //       double.tryParse(a.locationLatitude ?? '');
          //   final aLng = double.tryParse(loc?.locationLongitude ?? '') ??
          //       double.tryParse(a.locationLongitude ?? '');

          //   return aLat == lat && aLng == lng;
          final count = matchingAssets.length.toString();
          var gpsCordVal =
              "${loc?.locationLatitude}, ${loc?.locationLongitude}";
          _addMarkerFromCoords(gpsCordVal, '', count);
        }
      }
    } else {
      _loadAllMarkers(state);
    }
  }

  void _addMarkerFromCoords(String coords, String query, String count) async {
    final parts = coords.split(',');
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat != null && lng != null) {
        final customIcon = await createCustomMarkerFromAssetWithText(count);
        final marker = Marker(
          icon: customIcon,
          markerId: const MarkerId("selected_location"),
          position: LatLng(lat, lng),
          infoWindow: const InfoWindow(title: 'Selected Location'),
        );

        if (mounted) {
          setState(() {
            _markers.clear();
            _markers.add(marker);
            cameraPosition = CameraPosition(target: LatLng(lat, lng), zoom: 12);
            _updateSearchAndMap(lat, lng, query);
          });
          try {
            await _mapController
                ?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15));
          } catch (_) {
            // Ignore PlatformException if map channel is closed
          }
        }
      }
    }
  }

  void _updateSearchAndMap(double lat, double lng, String query) {
    setState(() {
      _searchController.text = query.isEmpty ? '$lat,$lng' : query;
    });
  }

  void _searchLocation() async {
    final query = _searchController.text.trim();
    final state = BlocProvider.of<EquipmentLocatorBloc>(context).state;

    if (state is! EquipmentLocatorLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Asset data not loaded yet")),
      );
      return;
    }

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a search query")),
      );
      return;
    }

    // Case 1: Direct GPS input
    if (query.contains(',') && query.split(',').length == 2) {
      final parts = query.split(',');
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());

      if (lat != null && lng != null) {
        final matchingAssets = state.assets.where((a) {
          Location? loc = state.locationCollection
              .where((ele) => ele.id == a.locationId)
              .firstOrNull;

          final aLat = double.tryParse(loc?.locationLatitude ?? '') ??
              double.tryParse(a.locationLatitude ?? '');
          final aLng = double.tryParse(loc?.locationLongitude ?? '') ??
              double.tryParse(a.locationLongitude ?? '');

          return aLat == lat && aLng == lng;
        }).toList();

        final count = matchingAssets.length.toString();
        _addMarkerFromCoords(query, '', count);
        return;
      }
    }

    // Case 2: RFID or Equipment Tag Number
    ExRegister? asset = state.assets
        .where(
          (a) => a.rfidRef == query || a.eqpmtTag == query,
        )
        .firstOrNull;

    if (asset != null) {
      Location? location = state.locationCollection
          .where((ele) => ele.id == asset.locationId)
          .firstOrNull;

      final lat = double.tryParse(location?.locationLatitude ?? '') ??
          double.tryParse(asset.locationLatitude ?? '');
      final lng = double.tryParse(location?.locationLongitude ?? '') ??
          double.tryParse(asset.locationLongitude ?? '');

      if (lat != null && lng != null) {
        final sameLocationAssets = state.assets.where(
          (a) => a.locationId == asset.locationId,
        );

        final count = sameLocationAssets.length;
        final icon =
            await createCustomMarkerFromAssetWithText(count.toString());

        final marker = Marker(
          markerId: MarkerId(asset.rfidRef),
          icon: icon,
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: 'Assets: $count',
            snippet: asset.rfidRef,
          ),
        );

        if (!mounted) return;
        setState(() {
          _markers = {marker};
          cameraPosition = CameraPosition(target: LatLng(lat, lng), zoom: 12);
        });

        try {
          await _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15),
          );
        } catch (_) {
          // Ignore PlatformException if map channel is closed
        }

        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No asset found for the given input")),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EquipmentLocatorBloc, EquipmentLocatorState>(
      listener: (context, state) {
        if (state is EquipmentLocatorLoaded) {
          _initMapData(state);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 72),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 24.0, left: 24, right: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: _buildSearchBar()),
                          const SizedBox(height: 24),
                          _buildEquipmentCountHeader(),
                          _buildMapContainer(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0xFFD0D3D8)),
                borderRadius: BorderRadius.circular(8),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x0C1B2029),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Center(
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                          Color(0xFF3B475B), BlendMode.srcIn),
                      child: SvgPicture.asset(
                        'lib/src/features/landing_page/assets/svg/search_icon.svg',
                        height: 18,
                        width: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          'Enter GPS Coordinates/ Equipment Tag Number/ RFID Reference',
                      hintStyle: GoogleFonts.inter(
                        color: const Color(0xFF979797),
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              padding: EdgeInsets.zero,
                              icon: SvgPicture.asset(
                                'lib/src/features/equipment_locator/assets/locator_cancel_icon.svg',
                                width: 18,
                                height: 18,
                              ),
                              onPressed: () {
                                final state =
                                    BlocProvider.of<EquipmentLocatorBloc>(
                                            context)
                                        .state;
                                if (state is EquipmentLocatorLoaded) {
                                  _loadAllMarkers(state);
                                }
                                _searchController.clear();
                              },
                              constraints: const BoxConstraints(),
                              iconSize: 18,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _searchLocation,
          child: Container(
            width: 120,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: ShapeDecoration(
              color: const Color(0xFF1E90FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              shadows: const [
                BoxShadow(
                  color: Color(0x3D1A85EC),
                  blurRadius: 2,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Go',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFFFEFEFE),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentCountHeader() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD0D3D8), width: 1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Total Equipments:',
            style: GoogleFonts.inter(
              color: const Color(0xFF4B4B4B),
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 4),
          BlocBuilder<EquipmentLocatorBloc, EquipmentLocatorState>(
            builder: (context, state) {
              int equipmentCount = 0;
              if (state is EquipmentLocatorLoaded) {
                equipmentCount = state.assets.length;
              }
              return Text(
                '$equipmentCount Nos',
                style: GoogleFonts.inter(
                  color: const Color(0xFF212121),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapContainer() {
    return Container(
      height: 410,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD0D3D8), width: 1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        child: GoogleMap(
          rotateGesturesEnabled: true,
          scrollGesturesEnabled: true,
          compassEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          liteModeEnabled: false,
          tiltGesturesEnabled: true,
          fortyFiveDegreeImageryEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          trafficEnabled: true,
          initialCameraPosition: cameraPosition,
          markers: _markers,
          onCameraIdle: () async {
            try {
              // LatLngBounds bounds = await _mapController!.getVisibleRegion();
              // LatLng northeast = bounds.northeast;
              // LatLng southwest = bounds.southwest;
            } catch (e) {}
          },
          onMapCreated: (controller) async {
            try {
              _mapController = controller;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                await Future.delayed(const Duration(milliseconds: 500));
                try {
                  // LatLngBounds bounds = await _mapController!.getVisibleRegion();
                  // LatLng northeast = bounds.northeast;
                  // LatLng southwest = bounds.southwest;
                } catch (e) {}
              });
            } catch (_) {
              // Ignore PlatformException if channel is closed during map creation
            }
          },
        ),
      ),
    );
  }

  Future<BitmapDescriptor> createCustomMarkerFromAssetWithText(
      String text) async {
    const int imageSize = 100; // Fixed icon size

    final ByteData data = await rootBundle
        .load('lib/src/features/notification/asset/Locator_Icon.png');
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: imageSize,
      targetHeight: imageSize,
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    final ui.Image baseImage = frame.image;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint();

    // Draw the base icon
    canvas.drawImage(baseImage, Offset.zero, paint);

    // Try to shrink text size to fit
    double fontSize = text.length >= 6 ? 14 : 17; // Start from max size
    TextPainter textPainter;
    do {
      final textStyle = TextStyle(
        fontSize: fontSize,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      );

      textPainter = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(maxWidth: imageSize.toDouble() * 0.9); // 90% width
      fontSize -= 1;
    } while (
        textPainter.width > imageSize * 0.9 && fontSize > 8); // Minimum size

    // Center the text on icon
    final Offset textOffset = Offset(
      (imageSize - textPainter.width) / 2,
      (imageSize - textPainter.height) / 3.5,
    );
    textPainter.paint(canvas, textOffset);

    final ui.Image finalImage = await pictureRecorder.endRecording().toImage(
          imageSize,
          imageSize,
        );

    final ByteData? finalBytes =
        await finalImage.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(finalBytes!.buffer.asUint8List());
  }
}
