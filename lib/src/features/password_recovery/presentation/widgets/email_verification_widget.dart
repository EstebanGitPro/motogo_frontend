import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty || !value.contains('@')
                  ? 'Introduce un email válido'
                  : null,
            ),
            const SizedBox(height: 24),
            BlocConsumer<EmailRecoveryVerificationBloc, EmailRecoveryVerificationState>(
              listener: (context, state) {
                if (state is EmailRecoveryVerificationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Correo enviado ✉️')),
                  );
                } else if (state is EmailRecoveryVerificationFailure) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.error.message)));
                }
              },
              builder: (context, state) {
                final isLoading = state is EmailRecoveryVerificationLoading;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              context.read<EmailRecoveryVerificationBloc>().add(
                                EmailRecoveryVerificationSubmitted(
                                  email: _emailCtrl.text.trim(),
                                ),
                              );
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Enviar correo de recuperación'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
