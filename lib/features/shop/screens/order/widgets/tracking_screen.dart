import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  int currentStep = 1; // example: 0=Accepted, 1=Processing, etc.
  late GoogleMapController mapController;

  final LatLng origin = const LatLng(14.5995, 120.9842); // example start
  final LatLng destination = const LatLng(14.6095, 120.9842); // example end

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking Order'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Map container
          SizedBox(
            height: 300,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: origin, zoom: 14),
              markers: {
                Marker(markerId: const MarkerId('origin'), position: origin),
                Marker(
                  markerId: const MarkerId('destination'),
                  position: destination,
                ),
              },
              onMapCreated: (controller) => mapController = controller,
            ),
          ),

          // Curved container below map
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stepper/status tracker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStep('Accepted', 0),
                      _buildStep('Processing', 1),
                      _buildStep('Pickup', 2),
                      _buildStep('Delivered', 3),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Rider info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=5', // sample rider image
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'James Wiliams',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Delivering by Motorcycle',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      // Message button
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.message),
                        color: Colors.green,
                      ),
                      // Call button
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.call),
                        color: Colors.blue,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Text('Tip your shopper'),
                  const SizedBox(height: 8),

                  // Tip buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _tipButton('\$2'),
                      _tipButton('\$5'),
                      _tipButton('\$10'),
                      _tipButton('\$15'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String label, int stepIndex) {
    bool isActive = stepIndex <= currentStep;
    return Column(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isActive ? Colors.green : Colors.grey[300],
          child: isActive
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _tipButton(String label) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black,
      ),
      child: Text(label),
    );
  }
}
