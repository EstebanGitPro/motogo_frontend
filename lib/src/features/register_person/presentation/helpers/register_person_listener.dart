import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/utils/translation_utils.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/bloc/register_person_bloc.dart';
import 'package:motogo_frontend/src/features/register_person/presentation/pages/verification_page.dart';

/// Builds the shared [BlocListener] for person registration pages.
///
/// Both [RegisterUserPage] and [RegisterRepresentativePage] share identical
/// success/failure SnackBar + navigation logic. This helper eliminates that
/// duplication.
BlocListener<RegisterPersonBloc, RegisterPersonState>
buildRegisterPersonListener({
  required BuildContext context,
  required bool isMobile,
  required Widget child,
}) {
  return BlocListener<RegisterPersonBloc, RegisterPersonState>(
    listener: (context, state) {
      if (state is RegisterPersonSuccess) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(
                getTranslateText(
                  context: context,
                  key: 'verification_email_sent',
                ),
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
                vertical: 16,
              ),
            ),
          );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationPage(email: state.email),
          ),
        );
      } else if (state is RegisterPersonFailure) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(state.errorModel.message),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
                vertical: 16,
              ),
            ),
          );
      }
    },
    child: child,
  );
}
