import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/constants/common_constants.dart';
import 'package:motogo_frontend/src/core/constants/person_constants.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/delete_person/domain/usecases/delete_person_usecase.dart';
import 'package:motogo_frontend/src/features/edit_profile/presentation/bloc/edit_profile_bloc.dart';
import 'package:motogo_frontend/src/features/login/presentation/bloc/login_bloc.dart';

/// Shows a destructive confirmation dialog for account deletion.
///
/// Requires the user to type a confirmation word before enabling
/// the delete button. On success, clears session and navigates
/// to `/login`.
void showDeleteAccountDialog(BuildContext context) {
  final confirmController = TextEditingController();
  bool isConfirmValid = false;
  bool isDeleting = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (stateContext, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    PersonConstants.deleteAccountTitle,
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  PersonConstants.deleteAccountWarning,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  PersonConstants.deleteAccountConfirmPrompt,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmController,
                  enabled: !isDeleting,
                  decoration: InputDecoration(
                    hintText: PersonConstants.deleteAccountConfirmWord,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      isConfirmValid =
                          value.toLowerCase().trim() ==
                          PersonConstants.deleteAccountConfirmWord;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isDeleting
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: const Text(CommonConstants.cancel),
              ),
              TextButton(
                onPressed: (!isConfirmValid || isDeleting)
                    ? null
                    : () async {
                        setDialogState(() => isDeleting = true);
                        final deleteUseCase =
                            InjectorApp.resolve<DeletePersonUseCase>();
                        final result = await deleteUseCase();
                        result.fold(
                          (error) {
                            setDialogState(() => isDeleting = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(error.message),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                          (message) {
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                                backgroundColor: Colors.green,
                              ),
                            );
                            context.read<EditProfileBloc>().add(
                              const EditProfileReset(),
                            );
                            context.read<LoginBloc>().add(LoginLogout());
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          },
                        );
                      },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(PersonConstants.deleteAccountButton),
              ),
            ],
          );
        },
      );
    },
  );
}
