import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/widgets/button_widget.dart';
import 'package:motogo_frontend/src/core/widgets/input_widgat.dart';
import 'package:motogo_frontend/src/features/password_recovery/presentation/bloc/email_verification_bloc.dart';

class EmailVerificationWidget extends StatefulWidget {
  const EmailVerificationWidget({super.key});

  @override
  State<EmailVerificationWidget> createState() =>
      _EmailVerificationWidgetState();
}

class _EmailVerificationWidgetState extends State<EmailVerificationWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomInputWidget(
              controller: _emailCtrl,
              labelText: 'Correo electrónico',
              prefixIcon: const Icon(Icons.email_outlined),
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  value == null || value.trim().isEmpty || !value.contains('@')
                  ? 'Introduce un email válido'
                  : null,
            ),
            const SizedBox(height: 24),
            BlocConsumer<
              EmailRecoveryVerificationBloc,
              EmailRecoveryVerificationState
            >(
              listener: (context, state) {
                ScaffoldMessenger.of(context).clearSnackBars();

                if (state is EmailRecoveryVerificationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Correo enviado ✉️'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else if (state is EmailRecoveryVerificationFailure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error.message),
                      duration: const Duration(seconds: 3),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is EmailRecoveryVerificationLoading;

                return CustomButtonWidget(
                  title: 'Enviar correo de recuperación',
                  isLoading: isLoading,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<EmailRecoveryVerificationBloc>().add(
                        EmailRecoveryVerificationSubmitted(
                          email: _emailCtrl.text.trim(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
