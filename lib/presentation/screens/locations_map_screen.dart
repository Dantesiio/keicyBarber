import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/location.dart';

class LocationsMapScreen extends StatefulWidget {
  final List<Location> locations;
  final String? selectedLocationId;

  const LocationsMapScreen({
    super.key,
    required this.locations,
    this.selectedLocationId,
  });

  @override
  State<LocationsMapScreen> createState() => _LocationsMapScreenState();
}

class _LocationsMapScreenState extends State<LocationsMapScreen> {
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Si hay una ubicación seleccionada, animar a ella
    if (widget.selectedLocationId != null) {
      _animateToLocation(widget.selectedLocationId!);
    }
  }

  void _animateToLocation(String locationId) {
    final location = widget.locations.firstWhere(
      (loc) => loc.id == locationId && loc.latitude != null && loc.longitude != null,
      orElse: () => widget.locations.first,
    );
    
    if (location.latitude != null && location.longitude != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(location.latitude!, location.longitude!),
          15.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar ubicaciones que tengan coordenadas
    final locationsWithCoordinates = widget.locations
        .where((loc) => loc.latitude != null && loc.longitude != null)
        .toList();

    if (locationsWithCoordinates.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF2B705),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          title: const Text(
            'Ubicaciones',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay coordenadas disponibles para las sedes',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Calcular el centro del mapa basado en todas las ubicaciones
    double avgLat = 0;
    double avgLng = 0;
    for (var loc in locationsWithCoordinates) {
      avgLat += loc.latitude!;
      avgLng += loc.longitude!;
    }
    avgLat /= locationsWithCoordinates.length;
    avgLng /= locationsWithCoordinates.length;

    // Crear marcadores para cada ubicación
    final Set<Marker> markers = {};
    for (var location in locationsWithCoordinates) {
      final isSelected = location.id == widget.selectedLocationId;
      markers.add(
        Marker(
          markerId: MarkerId(location.id),
          position: LatLng(location.latitude!, location.longitude!),
          infoWindow: InfoWindow(
            title: location.name,
            snippet: location.address,
          ),
          icon: isSelected
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2B705),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Ubicaciones de Sedes',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(avgLat, avgLng),
              zoom: widget.selectedLocationId != null ? 15.0 : 12.0,
            ),
            markers: markers,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapType: MapType.normal,
            zoomControlsEnabled: true,
          ),
          // Lista de ubicaciones en la parte inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: locationsWithCoordinates.length,
                itemBuilder: (context, index) {
                  final location = locationsWithCoordinates[index];
                  final isSelected = location.id == widget.selectedLocationId;
                  return GestureDetector(
                    onTap: () {
                      _animateToLocation(location.id);
                    },
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF2B705).withOpacity(0.2)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFF2B705)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: isSelected
                                    ? const Color(0xFFF2B705)
                                    : Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isSelected
                                        ? const Color(0xFFF2B705)
                                        : Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            location.address,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

