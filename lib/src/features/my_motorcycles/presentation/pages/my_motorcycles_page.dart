import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/common_constants.dart';
import 'package:motogo_frontend/src/core/constants/motorcycle_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/delete_motorcycle/domain/usecases/delete_motorcycle_usecase.dart';
import 'package:motogo_frontend/src/features/edit_motorcycle/presentation/pages/edit_motorcycle_page.dart';
import 'package:motogo_frontend/src/features/motorcycle_history/presentation/pages/motorcycle_history_page.dart';
import 'package:motogo_frontend/src/features/motorcycle_history/presentation/bloc/motorcycle_history_bloc.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/domain/usecases/get_my_motorcycles_usecase.dart';
import 'package:motogo_frontend/src/features/my_motorcycles/presentation/bloc/my_motorcycles_bloc.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/domain/entities/motorcycle_entity.dart';
import 'package:motogo_frontend/src/features/register_motorcycle/presentation/pages/register_motorcycle_page.dart';

/// Page that displays the user's registered motorcycles.
class MyMotorcyclesPage extends StatelessWidget {
  const MyMotorcyclesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyMotorcyclesBloc(
        getMyMotorcyclesUseCase: InjectorApp.resolve<GetMyMotorcyclesUseCase>(),
        deleteMotorcycleUseCase: InjectorApp.resolve<DeleteMotorcycleUseCase>(),
      )..add(const LoadMyMotorcycles()),
      child: const _MyMotorcyclesView(),
    );
  }
}

class _MyMotorcyclesView extends StatelessWidget {
  const _MyMotorcyclesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MotorcycleConstants.myMotorcyclesTitle),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToRegister(context),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<MyMotorcyclesBloc, MyMotorcyclesState>(
        listener: (context, state) {
          if (state is MyMotorcycleDeleted) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green[600],
                ),
              );
          }
          if (state is MyMotorcycleDeleteError) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red[600],
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is MyMotorcyclesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MyMotorcyclesError) {
            return _buildErrorState(context, state.message);
          }

          if (state is MyMotorcyclesLoaded) {
            if (state.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildMotorcycleList(state.motorcycles);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<MyMotorcyclesBloc>().add(const LoadMyMotorcycles());
            },
            icon: const Icon(Icons.refresh),
            label: const Text(CommonConstants.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.two_wheeler, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              MotorcycleConstants.noMotorcyclesFound,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              MotorcycleConstants.emptyStateSubtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _navigateToRegister(context),
              icon: const Icon(Icons.add),
              label: const Text(MotorcycleConstants.registerButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotorcycleList(List<MotorcycleEntity> motorcycles) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: motorcycles.length,
      itemBuilder: (context, index) {
        return _MotorcycleCard(motorcycle: motorcycles[index]);
      },
    );
  }

  void _navigateToRegister(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterMotorcyclePage()),
    );

    if (result == true && context.mounted) {
      context.read<MyMotorcyclesBloc>().add(const LoadMyMotorcycles());
    }
  }
}

/// Card widget for displaying a motorcycle.
class _MotorcycleCard extends StatelessWidget {
  final MotorcycleEntity motorcycle;

  const _MotorcycleCard({required this.motorcycle});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _navigateToHistory(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Motorcycle icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.two_wheeler,
                  size: 32,
                  color: Colors.blue[600],
                ),
              ),
              const SizedBox(width: 16),
              // Motorcycle details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      motorcycle.licensePlate.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildDetails(),
                    if (motorcycle.ownerNotes != null &&
                        motorcycle.ownerNotes!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        '"${motorcycle.ownerNotes}"',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // Edit button
              IconButton(
                icon: Icon(Icons.edit_outlined, color: Colors.blue[600]),
                onPressed: () async {
                  final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditMotorcyclePage(motorcycle: motorcycle),
                    ),
                  );
                  if (result == true && context.mounted) {
                    context.read<MyMotorcyclesBloc>().add(
                      const LoadMyMotorcycles(),
                    );
                  }
                },
              ),
              // Delete button
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red[600]),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetails() {
    final details = <String>[];

    if (motorcycle.year != null) {
      details.add('${MotorcycleConstants.yearPrefix}${motorcycle.year}');
    }

    if (motorcycle.currentMileage != null) {
      final formatted = _formatMileage(motorcycle.currentMileage!);
      details.add('$formatted km');
    }

    if (details.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      details.join(' | '),
      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
    );
  }

  String _formatMileage(int mileage) {
    if (mileage >= 1000) {
      return '${(mileage / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
    }
    return mileage.toString();
  }

  void _navigateToHistory(BuildContext context) {
    if (motorcycle.id == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              InjectorApp.resolve<MotorcycleHistoryBloc>()
                ..add(LoadMotorcycleHistory(motorcycle.id!)),
          child: MotorcycleHistoryPage(motorcycle: motorcycle),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(MotorcycleConstants.deleteMotorcycleTitle),
        content: Text(
          '¿Estás seguro de que deseas eliminar la moto ${motorcycle.licensePlate.toUpperCase()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(CommonConstants.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(MotorcycleConstants.deleteMotorcycleButton),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted && motorcycle.id != null) {
        context.read<MyMotorcyclesBloc>().add(DeleteMotorcycle(motorcycle.id!));
      }
    });
  }
}
