# 🧪 Integration Tests — MotoGo

## ¿Qué son?

Los **integration tests** (pruebas de integración) ejecutan la app completa en un dispositivo real o emulador y simulan la interacción del usuario (tocar botones, escribir texto, navegar entre pantallas).

A diferencia de los **unit tests** y **widget tests** (que ya tienes en `test/`), estos prueban el flujo completo del usuario.

---

## Comparación de tipos de test

| Tipo              | Velocidad | Confiabilidad | ¿Qué prueba?                    |
|-------------------|-----------|---------------|----------------------------------|
| **Unit Test**     | ⚡ Rápido  | Media         | Lógica pura (BLoC, Use Cases)    |
| **Widget Test**   | ⚡ Rápido  | Alta          | UI de widgets individuales       |
| **Integration**   | 🐌 Lento   | Muy Alta      | Flujo completo del usuario       |

---

## Cómo ejecutar

### En un emulador o dispositivo conectado

```bash
# Ejecutar todos los integration tests
flutter test integration_test/

# Ejecutar un archivo específico
flutter test integration_test/app_test.dart

# En un dispositivo específico
flutter test integration_test/app_test.dart -d emulator-5554
```

### En Chrome (web)

```bash
flutter test integration_test/ -d chrome
```

---

## Estructura de archivos

```
integration_test/
├── README.md              ← Este archivo
├── app_test.dart           ← Test principal (splash + navegación)
└── helpers/                ← (Opcional) Utilidades compartidas
    └── test_helpers.dart
```

---

## Cómo escribir un integration test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:motogo_frontend/main.dart' as app;

void main() {
  // 1. Inicializar el binding
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('descripción del test', (WidgetTester tester) async {
    // 2. Lanzar la app
    app.main();
    await tester.pumpAndSettle();

    // 3. Interactuar con la UI
    await tester.tap(find.byKey(Key('loginButton')));
    await tester.pumpAndSettle();

    // 4. Escribir texto
    await tester.enterText(find.byKey(Key('emailField')), 'test@motogo.com');
    await tester.pumpAndSettle();

    // 5. Verificar resultados
    expect(find.text('Bienvenido'), findsOneWidget);
  });
}
```

---

## Tips

- **`pumpAndSettle()`** espera a que todas las animaciones terminen.
- **`pump(Duration(seconds: 2))`** avanza el reloj N segundos (útil para timers).
- Usa **`Key('miBoton')`** en tus widgets para encontrarlos fácilmente en tests.
- Los integration tests **requieren** un emulador o dispositivo real corriendo.

---

## Finders útiles

```dart
find.text('MotoGo');                    // Por texto visible
find.byKey(Key('loginButton'));         // Por Key
find.byType(ElevatedButton);           // Por tipo de widget
find.byIcon(Icons.search);             // Por icono
find.descendant(                        // Dentro de un widget padre
  of: find.byType(AppBar),
  matching: find.byIcon(Icons.menu),
);
```
