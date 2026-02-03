// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projec/screens/AI-chat-screen.dart';
import 'package:projec/widget/animated_emergency_button.dart';
import 'package:projec/widget/animated_quick_action.dart';
import 'package:projec/widget/pulse_animation.dart';
import '../models/emergency_model.dart';
import 'settings_screen.dart';
import 'nearby_facilities_screen.dart';
import 'share_location_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // Data
  final List<EmergencyContact> _emergencyContacts = [
    EmergencyContact(
      name: 'Amal Ali',
      phoneNumber: '+966500000001',
      relationship: 'Wife',
    ),
    EmergencyContact(
      name: 'Khaled Ahmed',
      phoneNumber: '+966500000002',
      relationship: 'Brother',
    ),
  ];

  final List<EmergencyService> _emergencyServices = [
    EmergencyService(
      name: 'Police',
      phoneNumber: '999',
      type: 'Police',
      icon: '🚔',
    ),
    EmergencyService(
      name: 'Ambulance',
      phoneNumber: '997',
      type: 'Medical',
      icon: '🚑',
    ),
    EmergencyService(
      name: 'Fire Department',
      phoneNumber: '998',
      type: 'Fire',
      icon: '🚒',
    ),
    EmergencyService(
      name: 'Traffic Police',
      phoneNumber: '993',
      type: 'Police',
      icon: '🚦',
    ),
  ];

  // State
  bool _isRecording = false;
  bool _isSendingSOS = false;
  LocationData? _currentLocation;

  // Animations
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _getCurrentLocation();
    _startEntranceAnimation();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _backgroundColorAnimation = ColorTween(
      begin: const Color(0xFF0A0A0A),
      end: const Color(0xFF111111),
    ).animate(_controller);
  }

  void _startEntranceAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _controller.forward();
  }

  void _getCurrentLocation() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _currentLocation = LocationData(
        latitude: 24.7136,
        longitude: 46.6753,
        address: 'Duhok, Kurdistan Region, Iraq',
      );
    });
  }

  // Core Actions
  void _triggerSOS() async {
    HapticFeedback.heavyImpact();

    setState(() => _isSendingSOS = true);

    _controller.reverse().then((_) => _controller.forward());

    await Future.delayed(const Duration(seconds: 3));

    setState(() => _isSendingSOS = false);

    _showSuccessSnackbar('SOS alert sent successfully!', Colors.green);
  }

  void _startRecording() async {
    HapticFeedback.mediumImpact();
    setState(() => _isRecording = true);

    await Future.delayed(const Duration(seconds: 5));

    setState(() => _isRecording = false);

    _showSuccessSnackbar('Recording saved to secure storage', Colors.blue);
  }

  void _callEmergency(String number) {
    HapticFeedback.lightImpact();
    // Implement phone call functionality
  }

  void _showNearbyFacilities() {
    _navigateTo(const NearbyFacilitiesScreen());
  }

  void _showShareLocation() {
    _navigateTo(const ShareLocationScreen());
  }

  void _showEmergencyInfo() {
    _showSuccessSnackbar('Emergency information loaded', Colors.purple);
  }

  void _openAIChat() {
    _navigateTo(const AIChatScreen());
  }

  // Navigation & UI Helpers
  void _navigateTo(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showSuccessSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: _backgroundColorAnimation.value,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Header Section
                _buildHeaderSliver(),

                // SOS Button Section
                _buildSOSSliver(),

                // Quick Actions Section
                _buildQuickActionsSliver(),

                // AI Chat Button Section
                _buildAIChatSliver(),

                // Emergency Services Section
                _buildEmergencyServicesSliver(),

                // Emergency Contacts Section
                _buildEmergencyContactsSliver(),

                // Bottom Padding
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        );
      },
    );
  }

  // Sliver Widgets
  SliverToBoxAdapter _buildHeaderSliver() {
    return SliverToBoxAdapter(
      child: Transform.translate(
        offset: Offset(0, _slideAnimation.value),
        child: Opacity(
          opacity: _fadeAnimation.value,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(),
                const SizedBox(height: 24),
                _buildLocationCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'WELCOME',
            //   style: TextStyle(
            //     fontSize: 14,
            //     fontWeight: FontWeight.w600,
            //     color: Colors.grey[500],
            //     letterSpacing: 1.5,
            //   ),
            // ),
            const SizedBox(height: 4),
            const Text(
              'SafeGuard',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        _buildSettingsButton(),
      ],
    );
  }

  Widget _buildSettingsButton() {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.elasticOut),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: IconButton(
          onPressed: () => _navigateTo(const SettingsScreen()),
          icon: Icon(
            Icons.settings_rounded,
            color: Colors.white.withOpacity(0.8),
            size: 22,
          ),
          splashRadius: 20,
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    if (_currentLocation == null) return const SizedBox();

    return PulseAnimation(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: Colors.red[400],
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT LOCATION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentLocation!.address,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green[400],
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.green[400],
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSOSSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: AnimatedEmergencyButton(
          isActive: !_isSendingSOS,
          isSending: _isSendingSOS,
          onPressed: _triggerSOS,
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildQuickActionsSliver() {
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
              ),
            ),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 0.9),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    'QUICK ACTIONS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                  ),
                  children: [
                    AnimatedQuickAction(
                      icon: Icons.record_voice_over_rounded,
                      title: _isRecording ? 'Recording...' : 'Record Evidence',
                      color: _isRecording ? Colors.red : Colors.blue,
                      onTap: _startRecording,
                      isActive: _isRecording,
                      animationDelay: 0,
                    ),
                    AnimatedQuickAction(
                      icon: Icons.local_hospital_rounded,
                      title: 'Nearby Help',
                      color: Colors.green,
                      onTap: _showNearbyFacilities,
                      animationDelay: 100,
                    ),
                    AnimatedQuickAction(
                      icon: Icons.share_location_rounded,
                      title: 'Share Location',
                      color: Colors.orange,
                      onTap: _showShareLocation,
                      animationDelay: 200,
                    ),
                    AnimatedQuickAction(
                      icon: Icons.emergency_rounded,
                      title: 'Emergency Info',
                      color: Colors.purple,
                      onTap: _showEmergencyInfo,
                      animationDelay: 300,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildAIChatSliver() {
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.5, 0.9, curve: Curves.easeOutCubic),
              ),
            ),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.6, 0.9),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: GestureDetector(
              onTap: _openAIChat,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color.fromARGB(255, 255, 0, 0).withOpacity(0.1),
                      Colors.red.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 255, 0, 0),
                              Colors.red,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.smart_toy_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Emergency Assistant',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Get instant help and guidance',
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildEmergencyServicesSliver() {
    return SliverToBoxAdapter(
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _controller,
                curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
              ),
            ),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.6, 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'EMERGENCY SERVICES',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                ..._emergencyServices.asMap().entries.map((entry) {
                  final index = entry.key;
                  final service = entry.value;
                  return _buildServiceItem(service, index);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem(EmergencyService service, int index) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.6 + (index * 0.15), 1.0, curve: Curves.easeOutCubic),
    );

    return ScaleTransition(
      scale: animation,
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(service.icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            title: Text(
              service.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              service.type,
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            trailing: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => _callEmergency(service.phoneNumber),
                icon: Icon(
                  Icons.phone_rounded,
                  color: Colors.white.withOpacity(0.9),
                  size: 18,
                ),
                splashRadius: 20,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildEmergencyContactsSliver() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.7, 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'EMERGENCY CONTACTS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(0.8, 1.0, curve: Curves.elasticOut),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _showSuccessSnackbar(
                          'Add contact feature',
                          Colors.blue,
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white.withOpacity(0.8),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._emergencyContacts.asMap().entries.map((entry) {
                final index = entry.key;
                final contact = entry.value;
                return _buildContactItem(contact, index);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(EmergencyContact contact, int index) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(0.7 + (index * 0.2), 1.0, curve: Curves.easeOutCubic),
    );

    return ScaleTransition(
      scale: animation,
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.person_rounded,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            title: Text(
              contact.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '${contact.relationship} • ${contact.phoneNumber}',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}
