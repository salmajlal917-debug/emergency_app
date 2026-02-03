import 'package:flutter/material.dart';

class NearbyFacilitiesScreen extends StatelessWidget {
  const NearbyFacilitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Nearby Facilities'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFacilityItem(
            'King Faisal Specialist Hospital',
            '2.3 km',
            '🚑',
            'Hospital',
          ),
          _buildFacilityItem(
            'Riyadh Police Station',
            '1.8 km',
            '🚔',
            'Police Station',
          ),
          _buildFacilityItem(
            'Al Yamamah Emergency Center',
            '3.1 km',
            '🏥',
            'Emergency Center',
          ),
          _buildFacilityItem(
            'Riyadh Fire Station',
            '2.7 km',
            '🚒',
            'Fire Station',
          ),
          _buildFacilityItem(
            'Security Forces Hospital',
            '4.2 km',
            '🚑',
            'Hospital',
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityItem(
    String name,
    String distance,
    String icon,
    String type,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  type,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                distance,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'OPEN',
                  style: TextStyle(
                    color: Colors.green[400],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
