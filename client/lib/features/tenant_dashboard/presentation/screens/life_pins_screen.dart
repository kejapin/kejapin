import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../profile/data/life_pin_repository.dart';
import '../../../profile/domain/life_pin_model.dart';

class LifePinsScreen extends StatefulWidget {
  const LifePinsScreen({super.key});

  @override
  State<LifePinsScreen> createState() => _LifePinsScreenState();
}

class _LifePinsScreenState extends State<LifePinsScreen> {
  final LifePinRepository _repository = LifePinRepository();
  List<LifePin> _pins = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPins();
  }

  Future<void> _loadPins() async {
    try {
      final pins = await _repository.getLifePins();
      setState(() {
        _pins = pins;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // In a real app, handle error properly. For now, empty list or snackbar.
      // ScaffoldMessenger might not be available in initState async, but it's fine here as it's after await.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pins: $e')),
        );
      }
    }
  }

  Future<void> _addPin() async {
    await showDialog(
      context: context,
      builder: (context) => _AddPinDialog(
        onSave: (pin) async {
          await _repository.createLifePin(pin);
          _loadPins();
        },
      ),
    );
  }

  Future<void> _deletePin(String id) async {
    await _repository.deleteLifePin(id);
    _loadPins();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: const CustomAppBar(title: 'Life Pins', showSearch: false),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pins.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pin_drop_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No Life Pins yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.structuralBrown),
                      ),
                      const SizedBox(height: 8),
                      const Text('Add locations like Work, Gym, or School\nto see commute times.', textAlign: TextAlign.center),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pins.length,
                  itemBuilder: (context, index) {
                    final pin = _pins[index];
                    return Dismissible(
                      key: Key(pin.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deletePin(pin.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: GlassContainer(
                          borderRadius: BorderRadius.circular(12),
                          blur: 10,
                          opacity: 0.8,
                          color: Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.mutedGold.withOpacity(0.2),
                              child: Icon(
                                _getIconForMode(pin.transportMode),
                                color: AppColors.structuralBrown,
                              ),
                            ),
                            title: Text(
                              pin.label,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text('${pin.transportMode} • ${pin.latitude.toStringAsFixed(4)}, ${pin.longitude.toStringAsFixed(4)}'),
                            trailing: pin.isPrimary
                                ? const Icon(Icons.star, color: AppColors.mutedGold)
                                : null,
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPin,
        backgroundColor: AppColors.structuralBrown,
        icon: const Icon(Icons.add_location_alt, color: Colors.white),
        label: const Text('Add Pin', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  IconData _getIconForMode(String mode) {
    switch (mode) {
      case 'DRIVE':
        return Icons.directions_car;
      case 'WALK':
        return Icons.directions_walk;
      case 'CYCLE':
        return Icons.directions_bike;
      case 'PUBLIC_TRANSPORT':
        return Icons.directions_bus;
      default:
        return Icons.location_on;
    }
  }
}

class _AddPinDialog extends StatefulWidget {
  final Function(LifePin) onSave;

  const _AddPinDialog({required this.onSave});

  @override
  State<_AddPinDialog> createState() => _AddPinDialogState();
}

class _AddPinDialogState extends State<_AddPinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  String _transportMode = 'DRIVE';
  LatLng _selectedLocation = const LatLng(-1.2921, 36.8219); // Default Nairobi

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Life Pin',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _labelController,
                  decoration: const InputDecoration(
                    labelText: 'Label (e.g., Work, Gym)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _transportMode,
                  decoration: const InputDecoration(
                    labelText: 'Transport Mode',
                    border: OutlineInputBorder(),
                  ),
                  items: ['DRIVE', 'WALK', 'CYCLE', 'PUBLIC_TRANSPORT']
                      .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
                      .toList(),
                  onChanged: (value) => setState(() => _transportMode = value!),
                ),
                const SizedBox(height: 16),
                const Text('Tap to select location:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: _selectedLocation,
                        initialZoom: 13,
                        onTap: (_, point) => setState(() => _selectedLocation = point),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.kejapin.client',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocation,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final pin = LifePin(
                        id: '', // Server generates ID
                        label: _labelController.text,
                        latitude: _selectedLocation.latitude,
                        longitude: _selectedLocation.longitude,
                        transportMode: _transportMode,
                      );
                      widget.onSave(pin);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.structuralBrown,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Save Pin', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
