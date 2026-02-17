import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/features/completed_services/presentation/pages/service_list_page.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/diagnostic/domain/entity/diagnostic_entity.dart';
import 'package:motogo_frontend/src/features/motorcycle_evidence/domain/entities/motorcycle_evidence_entity.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/domain/entities/motorcycle_detail_entity.dart';
import 'package:motogo_frontend/src/features/search_motorcycle_by_plate/presentation/bloc/search_motorcycle_bloc.dart';
import 'package:motogo_frontend/src/features/completed_services/presentation/widgets/register_service_bottom_sheet.dart';

/// Page for searching motorcycles by license plate (HU47).
///
/// Allows workshop representatives to lookup motorcycle
/// information using the plate number. Displays diagnostics
/// history with evidence photos for workshop evaluation.
class SearchMotorcyclePage extends StatelessWidget {
  const SearchMotorcyclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InjectorApp.resolve<SearchMotorcycleBloc>(),
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
          if (state is SearchMotorcycleLoaded) {
            if (state.solutionMessage != null &&
                state.solutionMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.solutionMessage!),
                  backgroundColor: Colors.green,
                ),
              );
            }
            if (state.solutionError != null &&
                state.solutionError!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.solutionError!),
                  backgroundColor: Colors.red,
                ),
              );
            }
            // Service registration feedback
            if (state.serviceRegistrationMessage != null &&
                state.serviceRegistrationMessage!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.serviceRegistrationMessage!),
                  backgroundColor: Colors.green,
                ),
              );
            }
            if (state.serviceRegistrationError != null &&
                state.serviceRegistrationError!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.serviceRegistrationError!),
                  backgroundColor: Colors.red,
                ),
              );
            }
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
                if (state is SearchMotorcycleLoaded) ...[
                  _buildResultCard(state.motorcycle),
                  const SizedBox(height: 24),
                  _buildEvidenceGallery(state.motorcycle.evidence),
                  const SizedBox(height: 24),
                  _buildDiagnosticsSection(state.motorcycle.diagnostics),
                  const SizedBox(height: 24),
                  _buildRegisterServiceButton(state),
                  const SizedBox(height: 24),
                  _buildServicesCard(state),
                ],
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
              const Text(
                '🔍 ${MotorcycleConstants.searchByPlateTitle}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _plateController,
                enabled: !isLoading,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [UpperCaseTextFormatter()],
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
            _buildSpecRow(
              Icons.calendar_today,
              MotorcycleConstants.yearDetailLabel,
              '${motorcycle.year}',
            ),
            const SizedBox(height: 12),
            _buildSpecRow(
              Icons.speed,
              MotorcycleConstants.mileageDetailLabel,
              '${motorcycle.currentMileage} km',
            ),
            const SizedBox(height: 12),
            _buildSpecRow(
              Icons.category,
              MotorcycleConstants.categoryDetailLabel,
              motorcycle.reference.category,
            ),
            const SizedBox(height: 12),
            _buildSpecRow(
              Icons.settings,
              MotorcycleConstants.engineDisplacementLabel,
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

  // === Motorcycle Evidence Gallery ===

  Widget _buildEvidenceGallery(List<MotorcycleEvidenceEntity> evidence) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.photo_library, color: Colors.teal[700], size: 24),
            const SizedBox(width: 8),
            Text(
              MotorcycleConstants.motorcycleEvidenceTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${evidence.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[700],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (evidence.isEmpty)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      MotorcycleConstants.motorcycleNoEvidence,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: evidence.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = evidence[index];
                return GestureDetector(
                  onTap: () => _showFullScreenImage(context, item.imageUrl),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item.imageUrl,
                          width: 120,
                          height: 110,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 120,
                            height: 110,
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                      if (item.angle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.angle!,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === Diagnostics Section ===

  Widget _buildDiagnosticsSection(List<DiagnosticEntity> diagnostics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.assignment, color: Colors.blue[700], size: 24),
            const SizedBox(width: 8),
            Text(
              MotorcycleConstants.diagnosticsSectionTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${diagnostics.length}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (diagnostics.isEmpty)
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      MotorcycleConstants.diagnosticNoDiagnostics,
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...diagnostics.map(_buildDiagnosticCard),
      ],
    );
  }

  Widget _buildDiagnosticCard(DiagnosticEntity diagnostic) {
    final hasSolution =
        diagnostic.possibleSolution != null &&
        diagnostic.possibleSolution!.isNotEmpty;
    final dateFormatted =
        '${diagnostic.date.day.toString().padLeft(2, '0')}/${diagnostic.date.month.toString().padLeft(2, '0')}/${diagnostic.date.year}';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          leading: Icon(
            hasSolution ? Icons.check_circle : Icons.pending,
            color: hasSolution ? Colors.green : Colors.orange,
            size: 28,
          ),
          title: Text(
            dateFormatted,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          children: [
            // Problem description (full)
            _buildDetailRow(
              Icons.report_problem,
              MotorcycleConstants.diagnosticProblemLabel,
              diagnostic.problemDescription,
              Colors.orange,
            ),
            const SizedBox(height: 12),

            // Editable solution field
            _buildEditableSolutionField(diagnostic),

            // Evidence photos
            if (diagnostic.evidence.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.photo_library, size: 18, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    '${MotorcycleConstants.diagnosticEvidenceLabel} (${diagnostic.evidence.length})',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: diagnostic.evidence.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final evidence = diagnostic.evidence[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        evidence.imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEditableSolutionField(DiagnosticEntity diagnostic) {
    final solutionController = TextEditingController(
      text: diagnostic.possibleSolution ?? '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb,
              size: 18,
              color: (diagnostic.possibleSolution?.isNotEmpty ?? false)
                  ? Colors.green
                  : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              MotorcycleConstants.diagnosticSolutionLabel,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: solutionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: MotorcycleConstants.solutionHint,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final solution = solutionController.text.trim();
                if (solution.isNotEmpty) {
                  context.read<SearchMotorcycleBloc>().add(
                    SetDiagnosticSolution(
                      diagnosticId: diagnostic.id,
                      solution: solution,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(MotorcycleConstants.solutionSaveButton),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterServiceButton(SearchMotorcycleLoaded state) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue[50],
      child: InkWell(
        onTap: state.isRegisteringService
            ? null
            : () => _showRegisterServiceSheet(state),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.build_circle,
                size: 40,
                color: state.isRegisteringService
                    ? Colors.grey
                    : Colors.blue[700],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MotorcycleConstants.registerServiceButton,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: state.isRegisteringService
                            ? Colors.grey
                            : Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Registrar un servicio realizado para esta motocicleta',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (state.isRegisteringService)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.blue[700],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRegisterServiceSheet(SearchMotorcycleLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return RegisterServiceBottomSheet(
          motorcycleId: state.motorcycle.id,
          onSubmit:
              ({
                required String branchId,
                required List<String> serviceIds,
                double? quotedPrice,
                double? finalPrice,
                String? representativeNotes,
              }) {
                context.read<SearchMotorcycleBloc>().add(
                  RegisterCompletedService(
                    branchId: branchId,
                    motorcycleId: state.motorcycle.id,
                    serviceIds: serviceIds,
                    quotedPrice: quotedPrice,
                    finalPrice: finalPrice,
                    representativeNotes: representativeNotes,
                  ),
                );
              },
        );
      },
    );
  }

  Widget _buildServicesCard(SearchMotorcycleLoaded state) {
    final count = state.serviceHistory.length;
    final hasServices = count > 0;
    final pluralSuffix = count > 1 ? 's' : '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: state.loadingHistory
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<SearchMotorcycleBloc>(),
                      child: ServiceListPage(services: state.serviceHistory),
                    ),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                Icons.build_circle,
                size: 40,
                color: state.loadingHistory ? Colors.grey : Colors.orange[700],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      MotorcycleConstants.servicesCardTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: state.loadingHistory
                            ? Colors.grey
                            : Colors.orange[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasServices
                          ? '$count servicio$pluralSuffix registrado$pluralSuffix'
                          : MotorcycleConstants.servicesCardSubtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (state.loadingHistory)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else ...[
                if (hasServices)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                        fontSize: 13,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: Colors.orange[700],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Formatter that converts all input text to uppercase.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
