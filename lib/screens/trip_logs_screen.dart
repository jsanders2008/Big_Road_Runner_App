import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/trip_log.dart';
import '../providers/app_state.dart';

class TripLogsScreen extends StatelessWidget {
  final AppState appState;

  const TripLogsScreen({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final numberFormat = NumberFormat('#,##0');
    final trips = appState.filteredTrips;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              onChanged: (val) => appState.setTripSearchQuery(val),
              decoration: InputDecoration(
                hintText: 'Search trips by city, status, or notes...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFFC107)),
                suffixIcon: appState.tripSearchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => appState.setTripSearchQuery(''),
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Summary Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${trips.length} Runs Logged',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFC107),
                    ),
                  ),
                  Text(
                    'Total: ${numberFormat.format(appState.totalMilesDriven)} mi | ${currencyFormat.format(appState.totalFuelSpent)}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Trip Cards List
            Expanded(
              child: trips.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_shipping_outlined,
                            size: 64,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            appState.tripSearchQuery.isNotEmpty
                                ? 'No trips match "${appState.tripSearchQuery}"'
                                : 'No trip logs recorded yet.',
                            style: TextStyle(color: Colors.grey[400], fontSize: 15),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tap "+ LOG NEW TRIP" below to record a haul!',
                            style: TextStyle(color: Color(0xFFFFC107), fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: trips.length,
                      itemBuilder: (context, index) {
                        final trip = trips[index];
                        return _buildTripCard(context, trip);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add, fontWeight: FontWeight.bold),
        label: const Text(
          'LOG NEW TRIP',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        onPressed: () => _showAddTripSheet(context),
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, TripLog trip) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    Color statusColor;
    switch (trip.status.toLowerCase()) {
      case 'in transit':
        statusColor = Colors.lightBlueAccent;
        break;
      case 'scheduled':
        statusColor = Colors.orangeAccent;
        break;
      default:
        statusColor = Colors.greenAccent;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.amber.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFFFFC107)),
                    const SizedBox(width: 6),
                    Text(
                      dateFormat.format(trip.date),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor, width: 0.8),
                  ),
                  child: Text(
                    trip.status,
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Route Cities
            Row(
              children: [
                Expanded(
                  child: Text(
                    trip.origin,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Icon(Icons.arrow_forward_rounded, color: Color(0xFFFFC107)),
                ),
                Expanded(
                  child: Text(
                    trip.destination,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stats row
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniStat('DISTANCE', '${trip.totalMiles.toStringAsFixed(0)} mi'),
                  _buildMiniStat('FUEL COST', currencyFormat.format(trip.fuelCost)),
                  _buildMiniStat('AVG MPG', '${trip.avgMpg.toStringAsFixed(1)} MPG'),
                ],
              ),
            ),

            if (trip.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${trip.notes}',
                style: TextStyle(color: Colors.grey[400], fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                label: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                onPressed: () => _confirmDelete(context, trip),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFFFC107)),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, TripLog trip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Trip Log?'),
        content: Text('Are you sure you want to remove the haul from ${trip.origin} to ${trip.destination}?'),
        actions: [
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('DELETE'),
            onPressed: () {
              appState.deleteTrip(trip.id);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showAddTripSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final originController = TextEditingController();
    final destController = TextEditingController();
    final startOdoController = TextEditingController();
    final endOdoController = TextEditingController();
    final gallonsController = TextEditingController();
    final costController = TextEditingController();
    final notesController = TextEditingController();

    String status = 'Delivered';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                        'Log New Haul / Trip',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFC107),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: originController,
                              decoration: const InputDecoration(
                                labelText: 'Origin City, State',
                                prefixIcon: Icon(Icons.location_on),
                              ),
                              validator: (val) =>
                                  (val == null || val.isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: destController,
                              decoration: const InputDecoration(
                                labelText: 'Destination City, State',
                                prefixIcon: Icon(Icons.flag),
                              ),
                              validator: (val) =>
                                  (val == null || val.isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: startOdoController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Start Odometer',
                                prefixIcon: Icon(Icons.speed),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Required';
                                if (double.tryParse(val) == null) return 'Number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: endOdoController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'End Odometer',
                                prefixIcon: Icon(Icons.speed),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Required';
                                if (double.tryParse(val) == null) return 'Number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: gallonsController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Fuel Gallons',
                                prefixIcon: Icon(Icons.local_gas_station),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Required';
                                if (double.tryParse(val) == null) return 'Number';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: costController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Fuel Cost (\$)',
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) return 'Required';
                                if (double.tryParse(val) == null) return 'Number';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(
                          labelText: 'Trip Status',
                          prefixIcon: Icon(Icons.assignment),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
                          DropdownMenuItem(value: 'In Transit', child: Text('In Transit')),
                          DropdownMenuItem(value: 'Scheduled', child: Text('Scheduled')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => status = val);
                        },
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        controller: notesController,
                        decoration: const InputDecoration(
                          labelText: 'Trip Notes / Cargo Info',
                          prefixIcon: Icon(Icons.notes),
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
                              final startOdo = double.parse(startOdoController.text);
                              final endOdo = double.parse(endOdoController.text);

                              if (endOdo < startOdo) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('End odometer must be greater than start odometer!'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final newTrip = TripLog(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                date: DateTime.now(),
                                origin: originController.text.trim(),
                                destination: destController.text.trim(),
                                startOdometer: startOdo,
                                endOdometer: endOdo,
                                fuelGallons: double.parse(gallonsController.text),
                                fuelCost: double.parse(costController.text),
                                status: status,
                                notes: notesController.text.trim(),
                              );

                              appState.addTrip(newTrip);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Trip log recorded successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'SAVE TRIP LOG',
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
