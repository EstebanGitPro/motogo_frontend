import 'package:flutter/material.dart';

class LegalPage extends StatelessWidget {
  const LegalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de y Legal'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Acerca de',
              body:
                  'MotoGo es una plataforma para conectar motociclistas con '
                  'talleres y tiendas. Este texto es un placeholder y debe '
                  'ser reemplazado por la descripción oficial del producto.',
            ),
            _buildSection(
              title: 'Términos y condiciones de uso',
              body:
                  'Contenido pendiente de redacción legal. Debe incluir reglas '
                  'de uso, responsabilidades, limitaciones y aceptación del '
                  'usuario.',
            ),
            _buildSection(
              title: 'Política de privacidad',
              body:
                  'Contenido pendiente de redacción legal. Debe explicar qué '
                  'datos se recolectan, con qué finalidad, y cómo se protegen.',
            ),
            _buildSection(
              title: 'Tratamiento de datos personales',
              body:
                  'Contenido pendiente de redacción legal. Debe incluir la '
                  'base legal del tratamiento, derechos del titular y canales '
                  'de contacto.',
            ),
            _buildSection(
              title: 'Seguridad de la información',
              body:
                  'Contenido pendiente de redacción legal. Debe describir las '
                  'medidas de seguridad y buenas prácticas aplicadas.',
            ),
            _buildSection(
              title: 'Licencias y créditos',
              body:
                  'Motorcycle icons created by sonnycandra - Flaticon. '
                  'Fuente: https://www.flaticon.com/free-icons/motorcycle',
            ),
            const SizedBox(height: 16),
            Text(
              'Última actualización: pendiente de definición.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String body}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}
