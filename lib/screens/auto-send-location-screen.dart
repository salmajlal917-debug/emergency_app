import 'package:flutter/material.dart';

class AutoSendLocationScreen extends StatefulWidget {
  const AutoSendLocationScreen({super.key});

  @override
  State<AutoSendLocationScreen> createState() => _AutoSendLocationScreenState();
}

class _AutoSendLocationScreenState extends State<AutoSendLocationScreen> {
  bool _isEnabled = true;
  final bool _sendOnSOS = true;
  final bool _sendPeriodically = false;
  bool _shareLiveLocation = false;
  bool _includeAddress = true;
  bool _includeBatteryLevel = true;

  int _updateInterval = 5; 
  int _duration = 60; 

  final List<String> _triggerEvents = [
    'SOS Activation',
    'No Movement (5 mins)',
  ];

  final List<bool> _selectedTriggers = [true, false, false, false, false];

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 380;
    final padding = isSmallScreen ? 16.0 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Auto-Send Location',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.help_outline_rounded, size: 20),
            ),
            onPressed: _showLocationGuide,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          
              _buildStatusCard(),

              const SizedBox(height: 32),

              
              _buildMainToggle(),

              if (_isEnabled) ...[
                const SizedBox(height: 32),

                
                _buildTriggerEventsSection(),

                const SizedBox(height: 32),

              
                _buildLocationSettings(),

                const SizedBox(height: 32),

                
                _buildAdvancedSettings(),

                const SizedBox(height: 32),

                
                _buildPreviewCard(),
              ],

              const SizedBox(height: 32),

            
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.withOpacity(0.2), Colors.red.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automatic Location Sharing',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isEnabled
                      ? 'Location will be automatically sent to your emergency contacts based on your trigger settings.'
                      : 'Enable to automatically share your location during emergencies.',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isEnabled
                  ? Colors.red.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.location_searching_rounded,
              color: _isEnabled ? Colors.red : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-Send Location',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEnabled ? 'Enabled' : 'Disabled',
                  style: TextStyle(
                    color: _isEnabled ? Colors.green : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Switch(
              value: _isEnabled,
              onChanged: (value) => setState(() => _isEnabled = value),
              activeColor: Colors.red,
              inactiveTrackColor: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'TRIGGER EVENTS',
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            Text(
              '${_selectedTriggers.where((element) => element).length} selected',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: _triggerEvents.asMap().entries.map((entry) {
              final index = entry.key;
              final event = entry.value;
              return _buildTriggerItem(event, index);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTriggerItem(String event, int index) {
    final isSelected = _selectedTriggers[index];
    final icons = [
      Icons.emergency_rounded,
      Icons.battery_alert_rounded,
      Icons.vibration_rounded,
      Icons.mic_rounded,
      Icons.access_time_rounded,
    ];

    final colors = [
      Colors.red,
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
    ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.vertical(
          top: index == 0 ? const Radius.circular(16) : Radius.zero,
          bottom: index == _triggerEvents.length - 1
              ? const Radius.circular(16)
              : Radius.zero,
        ),
        onTap: () => setState(
          () => _selectedTriggers[index] = !_selectedTriggers[index],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: index < _triggerEvents.length - 1
                ? Border(bottom: BorderSide(color: Colors.grey[800]!))
                : null,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors[index].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icons[index], color: colors[index], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getTriggerDescription(event),
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.red.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? Colors.red : Colors.grey[700]!,
                  ),
                ),
                child: Icon(
                  isSelected ? Icons.check_rounded : Icons.close_rounded,
                  color: isSelected ? Colors.red : Colors.grey,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTriggerDescription(String event) {
    switch (event) {
      case 'SOS Activation':
        return 'When SOS button is pressed';
      case 'No Movement (5 mins)':
        return 'No movement detected for 5 minutes';
      default:
        return '';
    }
  }

  Widget _buildLocationSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOCATION SETTINGS',
          style: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildLocationSettingSwitch(
                'Share Live Location',
                'Continuously update location for better tracking',
                _shareLiveLocation,
                (value) => setState(() => _shareLiveLocation = value),
              ),
              _buildLocationSettingSwitch(
                'Include Address',
                'Add street address to location data',
                _includeAddress,
                (value) => setState(() => _includeAddress = value),
              ),
              _buildLocationSettingSwitch(
                'Include Battery Level',
                'Share current battery percentage',
                _includeBatteryLevel,
                (value) => setState(() => _includeBatteryLevel = value),
              ),
            ],
          ),
        ),

        if (_shareLiveLocation) ...[
          const SizedBox(height: 20),
          _buildIntervalSlider(),
        ],
      ],
    );
  }

  Widget _buildLocationSettingSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.red,
              inactiveTrackColor: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer_rounded, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Text(
                'UPDATE INTERVAL',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Update every $_updateInterval minutes',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Slider(
            value: _updateInterval.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            onChanged: (value) =>
                setState(() => _updateInterval = value.round()),
            activeColor: Colors.red,
            inactiveColor: Colors.grey[800],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 min',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              Text(
                '30 mins',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ADVANCED SETTINGS',
          style: TextStyle(
            color: Colors.grey[500],
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.settings_rounded, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'DURATION SETTINGS',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Share for $_duration minutes',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              Slider(
                value: _duration.toDouble(),
                min: 5,
                max: 240,
                divisions: 47,
                onChanged: (value) => setState(() => _duration = value.round()),
                activeColor: Colors.blue,
                inactiveColor: Colors.grey[800],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '5 mins',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  Text(
                    '4 hours',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_rounded, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Text(
                'LOCATION SHARING PREVIEW',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '📍 Live Location Sharing Active\n'
            '📱 Battery Level: 78%\n'
            '🏠 Address: 123 Main Street\n'
            '⏰ Updates: Every $_updateInterval mins\n'
            '🕒 Duration: $_duration minutes\n'
            '🚨 Triggers: ${_getActiveTriggers()}',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getActiveTriggers() {
    final activeTriggers = <String>[];
    for (int i = 0; i < _selectedTriggers.length; i++) {
      if (_selectedTriggers[i]) {
        activeTriggers.add(_triggerEvents[i]);
      }
    }
    return activeTriggers.join(', ');
  }

  Widget _buildSaveButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _saveSettings,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.withOpacity(0.9),
                Colors.red.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.save_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Save Location Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSettings() {
    // Save logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: const Text('Location settings saved successfully'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showLocationGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.location_on_rounded, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              'Location Sharing Guide',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Text(
          '• Location sharing helps emergency contacts find you quickly\n'
          '• Live location provides real-time updates\n'
          '• Choose triggers that match your safety needs\n'
          '• Battery level sharing helps assess device status\n'
          '• Address information improves location accuracy',
          style: TextStyle(color: Colors.grey[300], height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('UNDERSTOOD', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
