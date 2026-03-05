import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kiwi/kiwi.dart';
import 'package:motogo_frontend/src/core/constants/branch_detail_constants.dart';
import 'package:motogo_frontend/src/features/service_ratings/presentation/bloc/service_rating_bloc.dart';

/// Bottom sheet for rating a service item within a completed service.
///
/// Shows interactive stars, a comment field, and a submit button.
/// Connects to [ServiceRatingBloc] for submitting the rating.
class RatingBottomSheet extends StatefulWidget {
  final String completedServiceId;
  final String itemId;
  final String serviceName;

  const RatingBottomSheet({
    super.key,
    required this.completedServiceId,
    required this.itemId,
    required this.serviceName,
  });

  /// Shows this bottom sheet as a modal from the given [context].
  static Future<bool?> show(
    BuildContext context, {
    required String completedServiceId,
    required String itemId,
    required String serviceName,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider(
        create: (_) => KiwiContainer().resolve<ServiceRatingBloc>(),
        child: RatingBottomSheet(
          completedServiceId: completedServiceId,
          itemId: itemId,
          serviceName: serviceName,
        ),
      ),
    );
  }

  @override
  State<RatingBottomSheet> createState() => _RatingBottomSheetState();
}

class _RatingBottomSheetState extends State<RatingBottomSheet> {
  int _selectedRating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ServiceRatingBloc, ServiceRatingState>(
      listener: (context, state) {
        if (state is ServiceRatingSuccess) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
        } else if (state is ServiceRatingError) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandleBar(),
            const SizedBox(height: 16),
            _buildTitle(),
            const SizedBox(height: 20),
            _buildStarSelector(),
            const SizedBox(height: 20),
            _buildCommentField(),
            const SizedBox(height: 16),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandleBar() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          BranchDetailConstants.rateTitle,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          widget.serviceName,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildStarSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return GestureDetector(
          onTap: () => setState(() => _selectedRating = starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              starValue <= _selectedRating ? Icons.star : Icons.star_border,
              size: 40,
              color: Colors.amber,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCommentField() {
    return TextField(
      controller: _commentController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: BranchDetailConstants.rateCommentHint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<ServiceRatingBloc, ServiceRatingState>(
      builder: (context, state) {
        final isSubmitting = state is ServiceRatingSubmitting;
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _selectedRating > 0 && !isSubmitting
                ? () => _submitRating(context)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    BranchDetailConstants.rateSubmit,
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        );
      },
    );
  }

  void _submitRating(BuildContext context) {
    final comment = _commentController.text.trim();
    context.read<ServiceRatingBloc>().add(
      SubmitServiceRating(
        completedServiceId: widget.completedServiceId,
        itemId: widget.itemId,
        rating: _selectedRating,
        comment: comment.isEmpty ? null : comment,
      ),
    );
  }
}
