import 'package:flutter/material.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/motorcycle_references/domain/entities/motorcycle_reference_entity.dart';
import 'package:motogo_frontend/src/features/motorcycle_references/domain/usecases/get_motorcycle_references_usecase.dart';

/// Widget for selecting a motorcycle reference from the catalog.
///
/// Provides a searchable dropdown with all available motorcycle references.
/// The selected reference ID is passed to the parent via [onReferenceSelected].
class MotorcycleReferenceSelector extends StatefulWidget {
  /// Callback when a reference is selected or cleared.
  /// Passes null when the selection is cleared.
  final void Function(MotorcycleReferenceEntity? reference) onReferenceSelected;

  /// Optional initial reference to pre-select.
  final MotorcycleReferenceEntity? initialReference;

  const MotorcycleReferenceSelector({
    super.key,
    required this.onReferenceSelected,
    this.initialReference,
  });

  @override
  State<MotorcycleReferenceSelector> createState() =>
      _MotorcycleReferenceSelectorState();
}

class _MotorcycleReferenceSelectorState
    extends State<MotorcycleReferenceSelector> {
  final _searchController = TextEditingController();

  List<MotorcycleReferenceEntity> _allReferences = [];
  List<MotorcycleReferenceEntity> _filteredReferences = [];
  MotorcycleReferenceEntity? _selectedReference;
  bool _isLoadingReferences = true;
  String? _referencesError;
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _selectedReference = widget.initialReference;
    _loadReferences();
    _searchController.addListener(_filterReferences);
  }

  Future<void> _loadReferences() async {
    final useCase = InjectorApp.resolve<GetMotorcycleReferencesUseCase>();
    final result = await useCase();

    if (mounted) {
      setState(() {
        result.fold(
          (error) {
            _referencesError = error.message;
            _isLoadingReferences = false;
          },
          (references) {
            _allReferences = references;
            _filteredReferences = references;
            _isLoadingReferences = false;
          },
        );
      });
    }
  }

  void _filterReferences() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredReferences = _allReferences;
      } else {
        _filteredReferences = _allReferences.where((ref) {
          return ref.displayName.toLowerCase().contains(query) ||
              ref.brandName.toLowerCase().contains(query) ||
              ref.model.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected reference or trigger field
        GestureDetector(
          onTap: () {
            setState(() => _showDropdown = !_showDropdown);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Row(
              children: [
                Icon(Icons.motorcycle_outlined, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: _selectedReference != null
                      ? Text(
                          _selectedReference!.displayName,
                          style: const TextStyle(fontSize: 16),
                        )
                      : Text(
                          'Seleccionar referencia (opcional)',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
                if (_selectedReference != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      setState(() {
                        _selectedReference = null;
                        _searchController.clear();
                      });
                      widget.onReferenceSelected(null);
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                else
                  Icon(
                    _showDropdown ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.grey[600],
                  ),
              ],
            ),
          ),
        ),

        // Dropdown content
        if (_showDropdown) _buildDropdownContent(),
      ],
    );
  }

  Widget _buildDropdownContent() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar marca o modelo...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
            ),
          ),

          // References list
          _buildReferencesList(),
        ],
      ),
    );
  }

  Widget _buildReferencesList() {
    if (_isLoadingReferences) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_referencesError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(_referencesError!, style: TextStyle(color: Colors.red[600])),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isLoadingReferences = true;
                  _referencesError = null;
                });
                _loadReferences();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200),
      child: _filteredReferences.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No se encontraron referencias'),
            )
          : ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredReferences.length,
              itemBuilder: (context, index) {
                final ref = _filteredReferences[index];
                final isSelected = _selectedReference?.id == ref.id;
                return ListTile(
                  title: Text(
                    '${ref.brandName} ${ref.model}',
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${ref.category ?? 'Sin categoría'} - ${ref.engineDisplacementCc ?? 0}cc',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  selected: isSelected,
                  selectedTileColor: Colors.blue[50],
                  onTap: () {
                    setState(() {
                      _selectedReference = ref;
                      _showDropdown = false;
                      _searchController.clear();
                    });
                    widget.onReferenceSelected(ref);
                  },
                );
              },
            ),
    );
  }
}
