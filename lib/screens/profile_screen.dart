import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/driver_profile.dart';
import '../providers/app_state.dart';
import '../widgets/big_roadrunner_logo.dart';

class ProfileScreen extends StatelessWidget {
  final AppState appState;

  const ProfileScreen({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    final profile = appState.profile;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver Badge Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E1C0C), Color(0xFF141414)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.15),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                const BigRoadrunnerLogo(width: 140, height: 75),
                const SizedBox(height: 12),
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  profile.carrierName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFFFC107),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildBadgeItem(
                      label: 'CDL Status',
                      value: profile.isCdlExpiringSoon ? 'Renewal Soon' : 'Active / Valid',
                      color: profile.isCdlExpiringSoon ? Colors.amber : Colors.greenAccent,
                      icon: Icons.verified_user_rounded,
                    ),
                    _buildBadgeItem(
                      label: 'Medical Card',
                      value: profile.isMedicalExpiringSoon ? 'Expires Soon' : 'Valid',
                      color: profile.isMedicalExpiringSoon ? Colors.amber : Colors.greenAccent,
                      icon: Icons.medical_services_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // CDL & Professional Credentials Card
          _buildSectionHeader('COMMERCIAL CREDENTIALS'),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_rounded, color: Color(0xFFFFC107)),
                  title: const Text('CDL License Number'),
                  subtitle: Text('${profile.cdlNumber} (${profile.cdlState})'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.event_available_rounded, color: Color(0xFFFFC107)),
                  title: const Text('CDL Expiration Date'),
                  subtitle: Text(
                    '${dateFormat.format(profile.cdlExpiration)} (${profile.daysUntilCdlExpires} days left)',
                  ),
                  trailing: profile.isCdlExpiringSoon
                      ? const Icon(Icons.warning_amber_rounded, color: Colors.amber)
                      : null,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.health_and_safety_rounded, color: Color(0xFFFFC107)),
                  title: const Text('DOT Medical Card Expiration'),
                  subtitle: Text(
                    '${dateFormat.format(profile.medicalCardExpiration)} (${profile.daysUntilMedicalExpires} days left)',
                  ),
                  trailing: profile.isMedicalExpiringSoon
                      ? const Icon(Icons.warning_amber_rounded, color: Colors.amber)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Truck Specs & USDOT Info Card
          _buildSectionHeader('EQUIPMENT & DISPATCH'),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.local_shipping_rounded, color: Color(0xFFFFC107)),
                  title: const Text('Assigned Tractor / Trailer'),
                  subtitle: Text(profile.truckNumber),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.pin_rounded, color: Color(0xFFFFC107)),
                  title: const Text('USDOT / MC Number'),
                  subtitle: Text(profile.dotNumber),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_in_talk_rounded, color: Color(0xFFFFC107)),
                  title: const Text('Emergency Dispatch Line'),
                  subtitle: Text(profile.emergencyContact),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // App Settings & Dark Theme Switcher
          _buildSectionHeader('SYSTEM PREFERENCES'),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_rounded, color: Color(0xFFFFC107)),
              title: const Text('Dark Mode Display'),
              subtitle: const Text('High-contrast night driving palette'),
              value: appState.isDarkMode,
              onChanged: (_) => appState.toggleDarkMode(),
              activeColor: const Color(0xFFFFC107),
            ),
          ),
          const SizedBox(height: 24),

          // Edit Profile Action Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              icon: const Icon(Icons.edit_note_rounded, fontWeight: FontWeight.bold),
              label: const Text(
                'EDIT DRIVER PROFILE',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
              onPressed: () => _showEditProfileSheet(context, appState),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFFFFC107),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildBadgeItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 11),
        ),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  void _showEditProfileSheet(BuildContext context, AppState state) {
    final prof = state.profile;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: prof.name);
    final cdlController = TextEditingController(text: prof.cdlNumber);
    final stateController = TextEditingController(text: prof.cdlState);
    final carrierController = TextEditingController(text: prof.carrierName);
    final truckController = TextEditingController(text: prof.truckNumber);
    final dotController = TextEditingController(text: prof.dotNumber);
    final contactController = TextEditingController(text: prof.emergencyContact);

    DateTime cdlExp = prof.cdlExpiration;
    DateTime medExp = prof.medicalCardExpiration;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final dateFormat = DateFormat('yyyy-MM-dd');
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Edit Driver Credentials',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFC107),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (val) =>
                            (val == null || val.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: cdlController,
                              decoration: const InputDecoration(
                                labelText: 'CDL License Number',
                                prefixIcon: Icon(Icons.badge),
                              ),
                              validator: (val) =>
                                  (val == null || val.isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: stateController,
                              decoration: const InputDecoration(
                                labelText: 'State',
                                prefixIcon: Icon(Icons.map),
                              ),
                              validator: (val) =>
                                  (val == null || val.isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: carrierController,
                        decoration: const InputDecoration(
                          labelText: 'Carrier Name',
                          prefixIcon: Icon(Icons.business),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: truckController,
                        decoration: const InputDecoration(
                          labelText: 'Truck Unit Info',
                          prefixIcon: Icon(Icons.local_shipping),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: dotController,
                        decoration: const InputDecoration(
                          labelText: 'USDOT / MC Number',
                          prefixIcon: Icon(Icons.pin),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: contactController,
                        decoration: const InputDecoration(
                          labelText: 'Emergency Dispatch Contact',
                          prefixIcon: Icon(Icons.phone),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date Pickers
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_month, color: Color(0xFFFFC107)),
                        title: const Text('CDL Expiration Date'),
                        subtitle: Text(dateFormat.format(cdlExp)),
                        trailing: OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: cdlExp,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 3650)),
                            );
                            if (picked != null) {
                              setModalState(() => cdlExp = picked);
                            }
                          },
                          child: const Text('Change'),
                        ),
                      ),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.medical_services, color: Color(0xFFFFC107)),
                        title: const Text('Medical Card Expiration Date'),
                        subtitle: Text(dateFormat.format(medExp)),
                        trailing: OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: medExp,
                              firstDate: DateTime.now().subtract(const Duration(days: 365)),
                              lastDate: DateTime.now().add(const Duration(days: 3650)),
                            );
                            if (picked != null) {
                              setModalState(() => medExp = picked);
                            }
                          },
                          child: const Text('Change'),
                        ),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC107),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final updated = DriverProfile(
                                name: nameController.text.trim(),
                                cdlNumber: cdlController.text.trim(),
                                cdlState: stateController.text.trim(),
                                cdlExpiration: cdlExp,
                                medicalCardExpiration: medExp,
                                carrierName: carrierController.text.trim(),
                                truckNumber: truckController.text.trim(),
                                dotNumber: dotController.text.trim(),
                                emergencyContact: contactController.text.trim(),
                              );
                              state.updateProfile(updated);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Driver profile saved successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'SAVE CHANGES',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
