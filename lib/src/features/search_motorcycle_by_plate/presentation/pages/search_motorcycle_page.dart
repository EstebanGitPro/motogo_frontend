import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/entities/motorcycle_detail_entity.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/presentation/bloc/search_motorcycle_bloc.dart';

/// Page for searching motorcycles by license plate (HU47).
///
/// Allows workshop representatives to lookup motorcycle
/// information using the plate number.
class SearchMotorcyclePage extends StatelessWidget {
  const SearchMotorcyclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchMotorcycleBloc(),
      child: const _SearchMotorcycleView(),
    );
  }
}

class _SearchMotorcycleView extends StatefulWidget {
  const _SearchMotorcycleView();

  @override
  State<_SearchMotorcycleView> createState() => _SearchMotorcycleViewState();
}

class _SearchMotorcycleViewState extends State<_SearchMotorcycleView> {
  final _plateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  void _onSearch() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<SearchMotorcycleBloc>().add(
        SearchByPlate(_plateController.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MotorcycleConstants.searchByPlateTitle),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<SearchMotorcycleBloc, SearchMotorcycleState>(
        listener: (context, state) {
          if (state is SearchMotorcycleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearchCard(state),
                const SizedBox(height: 24),
                if (state is SearchMotorcycleLoaded)
                  _buildResultCard(state.motorcycle),
                if (state is SearchMotorcycleLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchCard(SearchMotorcycleState state) {
    final isLoading = state is SearchMotorcycleLoading;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '🔍 ${MotorcycleConstants.searchByPlateTitle}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _plateController,
                enabled: !isLoading,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: MotorcycleConstants.licensePlateLabel,
                  hintText: MotorcycleConstants.searchByPlateHint,
                  prefixIcon: const Icon(Icons.directions_bike),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return MotorcycleConstants.licensePlateRequired;
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _onSearch(),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _onSearch,
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.search),
                label: Text(
                  isLoading
                      ? MotorcycleConstants.searchByPlateLoading
                      : MotorcycleConstants.searchByPlateButton,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(MotorcycleDetailEntity motorcycle) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with plate
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.two_wheeler,
                    color: Colors.blue[700],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        motorcycle.licensePlate,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        '${motorcycle.reference.brandName} ${motorcycle.reference.model}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            // Technical specs
            _buildSpecRow(Icons.calendar_today, 'Año', '${motorcycle.year}'),
            const SizedBox(height: 12),
            _buildSpecRow(
              Icons.speed,
              'Kilometraje',
              '${motorcycle.currentMileage} km',
            ),
            const SizedBox(height: 12),
            _buildSpecRow(
              Icons.category,
              'Categoría',
              motorcycle.reference.category,
            ),
            const SizedBox(height: 12),
            _buildSpecRow(
              Icons.settings,
              'Cilindraje',
              '${motorcycle.reference.engineDisplacementCc} cc',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
