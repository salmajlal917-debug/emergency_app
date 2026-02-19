import 'package:flutter/material.dart';
import 'package:projec/screens/auto-send-location-screen.dart';
import 'package:projec/screens/countdwon-timer-screen.dart';
import 'package:projec/screens/edit-profile-screen.dart';
import 'package:projec/screens/emergency_message_screen.dart';
import 'package:projec/screens/sos_contacs_screen.dart';
import 'phone_signin_screen.dart'; // Import to navigate back to sign in
import 'package:projec/services/user_service.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _logout(BuildContext context) async {
  // Clear user data
  await UserService.logout();
  
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const PhoneSignInScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Section
          _buildProfileSection(context),

          const SizedBox(height: 32),

          _buildSettingsSection('EMERGENCY SETTINGS', [
            _buildModernSettingsItem(
              'SOS Contacts',
              Icons.contacts_rounded,
              'Manage emergency contacts',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SOSContactsScreen(),
                  ),
                );
              },
            ),
            _buildModernSettingsItem(
              'Emergency Message',
              Icons.message_rounded,
              'Customize emergency message',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EmergencyMessageScreen(),
                  ),
                );
              },
            ),
            _buildModernSettingsItem(
              'Auto-Send Location',
              Icons.location_on_rounded,
              'Automatically share location',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AutoSendLocationScreen(),
                  ),
                );
              },
            ),
            _buildModernSettingsItem(
              'Countdown Timer',
              Icons.timer_rounded,
              'Set emergency countdown',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CountdownTimerScreen(),
                  ),
                );
              },
            ),
          ]),

          const SizedBox(height: 32),

          _buildSettingsSection('APP SETTINGS', [
            _buildModernSettingsItem(
              'Language',
              Icons.language_rounded,
              'English (US)',
              () {},
            ),
            _buildModernSettingsItem(
              'Theme',
              Icons.dark_mode_rounded,
              'Dark',
              () {},
            ),
          ]),

          const SizedBox(height: 48),

          // Action buttons
          _buildActionButton(
            'Export Data',
            Icons.file_download_rounded,
            Colors.red.withOpacity(0.1),
            Colors.red,
            'Download your emergency data and settings',
            () {
              _showExportOptions(context);
            },
          ),

          const SizedBox(height: 12),

          _buildActionButton(
            'Clear Cache',
            Icons.cleaning_services_rounded,
            Colors.red.withOpacity(0.1),
            Colors.red,
            'Free up space and clear temporary files',
            () {
              _showClearCacheDialog(context);
            },
          ),

          const SizedBox(height: 32),

          // Logout button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: ListTile(
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                ),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              trailing: Padding(
                padding: const EdgeInsets.all(4),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.red.withOpacity(0.7),
                    size: 16,
                  ),
                ),
              ),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
  return FutureBuilder<String?>(
    future: UserService.getCurrentUserPhone(),
    builder: (context, phoneSnapshot) {
      if (!phoneSnapshot.hasData || phoneSnapshot.data == null) {
        return _buildDefaultProfile(); // Show default if no phone
      }
      
      return FutureBuilder<Map<String, dynamic>?>(
        future: UserService.getUserProfile(phoneSnapshot.data!),
        builder: (context, profileSnapshot) {
          final userData = profileSnapshot.data;
          
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Profile Avatar
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(0.8),
                          Colors.red.withOpacity(0.4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Profile Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData?['name']?.toString().isNotEmpty == true
                              ? userData!['name']
                              : 'No Name Set',  // 👈 THIS SHOWS REAL NAME OR DEFAULT
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userData?['email']?.toString().isNotEmpty == true
                              ? userData!['email']
                              : 'No Email Set',  // 👈 THIS SHOWS REAL EMAIL OR DEFAULT
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                color: Colors.green,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Active',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ),
                      ],
                    ),
                  ),

                  // Edit Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit_rounded, color: Colors.red, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildDefaultProfile() {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.red.withOpacity(0.8),
                  Colors.red.withOpacity(0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.red.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Guest User',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please sign in',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Colors.orange,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Not Signed In',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              ],
            ),
          ),

          // Edit Button
          Container(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: IconButton(
              onPressed: () {
                // This will navigate to edit profile which requires sign in
              },
              icon: Icon(Icons.edit_rounded, color: Colors.red, size: 20),
            ),
          ),
        ],
      ),
    ),
  );
}



  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey[500],
              fontWeight: FontWeight.w600,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(children: items),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSettingsItem(
    String title,
    IconData icon,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[800]!.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.red, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey[800]!.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey[400],
            size: 16,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color bgColor,
    Color iconColor,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.2), width: 1),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: iconColor,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: iconColor.withOpacity(0.7), fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.chevron_right_rounded,
            color: iconColor.withOpacity(0.7),
            size: 16,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Export Data As',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildExportOption(
              'PDF Document',
              Icons.picture_as_pdf,
              Colors.red,
              () {},
            ),
            _buildExportOption('JSON File', Icons.code, Colors.red, () {}),
            _buildExportOption(
              'Text File',
              Icons.text_snippet,
              Colors.red,
              () {},
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('Clear Cache?', style: TextStyle(color: Colors.white)),
        content: Text(
          'This will clear temporary files and free up storage space. Your important data like contacts and settings will not be affected.',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showClearedSnackbar(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }

  void _showClearedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: const Text('Cache cleared successfully'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text('Logout?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }
}
