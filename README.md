# MotoGo Frontend

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.8.1-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.14.0-blue)](CHANGELOG.md)
[![SonarCloud](https://img.shields.io/badge/SonarCloud-Analyzed-F3702A?logo=sonarcloud)](https://sonarcloud.io/project/overview?id=EstebanGitPro_motogo_frontend)

> Aplicación móvil de **MotoGo** — ayuda a los motociclistas a encontrar talleres confiables, comparar servicios adaptados a sus vehículos registrados y solicitar cotizaciones o diagnósticos antes de visitarlos.

---

## 📖 Tabla de Contenido

- [Visión](#-visión)
- [Características Principales](#-características-principales)
- [Stack Tecnológico](#-stack-tecnológico)
- [Arquitectura](#-arquitectura)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Primeros Pasos](#-primeros-pasos)
- [Comandos Disponibles](#-comandos-disponibles)
- [Testing](#-testing)
- [Build & Release](#-build--release)
- [Contribución](#-contribución)
- [Créditos](#-créditos)
- [Licencia](#-licencia)

---

## 🎯 Visión

Para los motociclistas que no cuentan con un mecanismo que permita encontrar establecimientos confiables que brinden servicios técnicos y/o venta de consumibles que se ajuste a sus necesidades, **MotoGo** es una aplicación móvil que permite a los usuarios ahorrar tanto su tiempo como su dinero en la búsqueda de los servicios para su motocicleta.

A diferencia de **Yelp**, **4WorldLover**, **Google Maps** y **Páginas Amarillas**, nuestro producto permite:

- ✅ Acceder al **catálogo de servicios** dependiendo de los vehículos que cada usuario tiene registrados en su perfil
- ✅ Acceso a la información de los **servicios más cercanos** al usuario con descubrimiento basado en mapa
- ✅ La posibilidad de **solicitar una cotización o un diagnóstico aproximado** antes de dirigirse al lugar

---

## ✨ Características Principales

| Módulo | Funcionalidades |
|--------|-----------------|
| **Autenticación** | Login, registro, recuperación de contraseña, verificación de correo |
| **Perfil de Usuario** | Edición de perfil, cambio de contraseña, eliminación de cuenta |
| **Motocicletas** | Registro, edición, imágenes de perfil, galería de evidencias, eliminación |
| **Descubrimiento de Sucursales** | Búsqueda cercana basada en mapa, detalle de sucursal, información de horarios |
| **Gestión de Sucursales** | Registro/edición de sucursales, gestión de franquicia, servicios, horarios |
| **Catálogo de Servicios** | Consulta de servicios filtrados por vehículo, catálogos técnicos |
| **Diagnósticos** | Solicitud de diagnóstico, integración con WhatsApp, manejo de permisos |
| **Historial de Servicios** | Servicios completados, historial de servicios por motocicleta |
| **Calificaciones** | Reseñas y calificaciones de servicios |
| **Administración** | Dashboard administrativo, gestión administrativa de servicios |

---

## 🛠 Stack Tecnológico

| Categoría | Tecnología |
|-----------|------------|
| **Framework** | Flutter 3.8.1 |
| **Lenguaje** | Dart 3.8.1 |
| **State Management** | [BLoC](https://bloclibrary.dev/) (flutter_bloc) |
| **Dependency Injection** | [Kiwi](https://pub.dev/packages/kiwi) + kiwi_generator |
| **HTTP Client** | [Dio](https://pub.dev/packages/dio) |
| **Authentication** | Firebase Auth |
| **File Storage** | Firebase Storage |
| **Maps** | Mapbox Maps Flutter |
| **Geolocation** | Geolocator + Permission Handler |
| **Secure Storage** | flutter_secure_storage |
| **Localization** | easy_localization |
| **Testing** | flutter_test, mockito, bloc_test |
| **Code Quality** | SonarCloud, flutter_lints, Husky pre-commit hooks |
| **Architecture** | Clean Architecture (3 capas) |

---

## 🏗 Arquitectura

MotoGo Frontend sigue un patrón de **Clean Architecture Feature-First** con 3 capas por feature:

```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│         (Pages, Widgets, BLoC / Cubit)              │
├─────────────────────────────────────────────────────┤
│                    Domain Layer                      │
│       (Entities, Use Cases, Repository Contracts)    │
├─────────────────────────────────────────────────────┤
│                     Data Layer                       │
│      (Models, DataSources, Repository Impl)          │
└─────────────────────────────────────────────────────┘
```

**Principios clave:**

- Cada **feature** es autocontenido con sus propias capas `data/`, `domain/` y `presentation/`
- **BLoC** maneja toda la gestión de estado con eventos y estados claros
- **Kiwi** proporciona dependency injection en tiempo de compilación
- La capa Domain define interfaces de repositorio; la capa Data las implementa
- El módulo **Core** provee utilidades compartidas, widgets, networking y constantes

---

## 📁 Estructura del Proyecto

```
motogo_frontend/
├── lib/
│   ├── main.dart                      # Punto de entrada de la aplicación
│   └── src/
│       ├── core/                      # Infraestructura compartida
│       │   ├── catalogs/              # Lógica de catálogos compartida
│       │   ├── config/                # Configuración de la app
│       │   ├── constants/             # Constantes basadas en features
│       │   ├── errors/                # Manejo de errores y failures
│       │   ├── geocoding/             # Servicio de geocodificación
│       │   ├── injector/              # Configuración de Kiwi DI
│       │   ├── mixins/                # Mixins compartidos
│       │   ├── models/                # Modelos del core
│       │   ├── network/               # HTTP client, interceptors
│       │   ├── routes/                # Enrutamiento de la app
│       │   ├── services/              # Servicios compartidos
│       │   ├── user/                  # Gestión de sesión de usuario
│       │   ├── utils/                 # Funciones utilitarias
│       │   ├── validators/            # Validadores de entrada
│       │   └── widgets/               # Widgets reutilizables
│       └── features/                  # Módulos de features (36 features)
│           ├── login/                 # Autenticación
│           ├── register_person/       # Registro de usuario
│           ├── user_home/             # Home del usuario (descubrimiento en mapa)
│           ├── my_motorcycles/        # Gestión de motocicletas
│           ├── my_branches/           # Listado de sucursales
│           ├── register_branch/       # Registro de sucursal
│           ├── diagnostic/            # Flujo de diagnóstico
│           ├── service_ratings/       # Reseñas de servicios
│           ├── admin_home/            # Dashboard administrativo
│           └── ...                    # 27 módulos de features más
├── test/                              # Tests unitarios y de widgets (estructura espejo)
├── assets/
│   ├── lang/                          # Archivos de traducción i18n
│   └── icons/                         # Íconos de la app
├── scripts/
│   ├── run_dev.sh                     # Ejecutar con variables de entorno
│   ├── build_release.sh               # Construir APK/AAB con secrets
│   └── emu-pixel.sh                   # Lanzar emulador Pixel
├── android/                           # Configuración de plataforma Android
├── ios/                               # Configuración de plataforma iOS
├── .env.example                       # Plantilla de variables de entorno
├── analysis_options.yaml              # Reglas del linter de Dart
├── pubspec.yaml                       # Dependencias
└── sonar-project.properties           # Configuración de SonarCloud
```

---

## 🚀 Primeros Pasos

**Tiempo estimado:** 10–15 minutos

### Prerrequisitos

| Herramienta | Versión | Propósito |
|-------------|---------|-----------|
| **Flutter** | ≥ 3.8.1 | Framework |
| **Dart** | ≥ 3.8.1 | Lenguaje (incluido con Flutter) |
| **Android Studio** o **VS Code** | Última | IDE con plugin de Flutter |
| **Xcode** | Última (solo macOS) | Desarrollo iOS |
| **Emulador Android** o dispositivo físico | — | Testing |

### Paso 1: Clonar el Repositorio

```bash
git clone https://github.com/EstebanGitPro/motogo_frontend.git
cd motogo_frontend
```

### Paso 2: Instalar Dependencias de Flutter

```bash
flutter pub get
```

### Paso 3: Generar Código (Kiwi DI)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Paso 4: Configurar Entorno (Opcional)

> **Nota:** La app funciona de inmediato con la configuración por defecto.
> El token de Mapbox y la URL del backend (`http://localhost:8085/motogo/api/v1`) están embebidos como valores por defecto.

Para sobrescribir algún valor por defecto, copiar `.env.example` y ajustar:

```bash
cp .env.example .env
```

| Variable | Valor por Defecto | Propósito |
|----------|-------------------|-----------|
| `BASE_URL` | `http://localhost:8085/motogo/api/v1` | URL del API backend |
| `MAPBOX_ACCESS_TOKEN` | Embebido (token del proyecto) | Renderizado de mapas y geocodificación |

O pasar valores directamente en tiempo de ejecución:

```bash
flutter run --dart-define=BASE_URL=https://your-server.com/motogo/api/v1
```

### Paso 5: Configuración de Firebase

El archivo de configuración de Firebase ya está incluido en el repositorio:

- **Android**: `android/app/google-services.json` ✅ (incluido)

> **⚠️ Nota de proyecto de grado:** Las claves de Firebase incluidas son claves de cliente (no secretos de servidor). Están diseñadas para distribuirse dentro de la aplicación. La seguridad se gestiona mediante Firebase Security Rules en el servidor. En un entorno de producción real, estas claves se gestionarían mediante variables de entorno y restricciones por dominio/SHA.

### Paso 6: Instalar Husky Pre-commit Hooks

```bash
npm install
```

### Paso 7: Ejecutar la Aplicación

```bash
# Inicio rápido (usa valores por defecto embebidos — recomendado)
flutter run

# Usando el script de desarrollo (carga overrides desde .env)
./scripts/run_dev.sh

# O manualmente con backend personalizado
flutter run --dart-define=BASE_URL=https://your-server.com/motogo/api/v1
```

### ✅ Verificación

| Chequeo | Cómo Verificar |
|---------|----------------|
| La app inicia | Aparece la pantalla de splash con el logo de MotoGo |
| El mapa carga | La pantalla home del usuario muestra el mapa de Mapbox |
| Backend conectado | La pantalla de login puede comunicarse con el API |

> **Nota:** La app requiere el [MotoGo Backend](https://github.com/EstebanGitPro/motogo_backend_f) ejecutándose en `localhost:8085` para funcionalidad completa.

---

## 📋 Comandos Disponibles

| Comando | Descripción |
|---------|-------------|
| `flutter pub get` | Instalar dependencias |
| `flutter run` | Ejecutar en modo debug |
| `flutter test` | Ejecutar todos los tests |
| `flutter test --coverage` | Ejecutar tests con reporte de cobertura |
| `flutter analyze` | Ejecutar análisis estático (linter) |
| `dart run build_runner build` | Generar código (Kiwi DI) |
| `dart run build_runner watch` | Modo watch para generación de código |
| `./scripts/run_dev.sh` | Ejecutar con variables de entorno cargadas |
| `./scripts/build_release.sh apk` | Construir APK de release |
| `./scripts/build_release.sh appbundle` | Construir AAB de release (Play Store) |
| `./scripts/emu-pixel.sh` | Lanzar emulador Pixel |

---

## 🧪 Testing

### Ejecutar Todos los Tests

```bash
flutter test
```

### Reporte de Cobertura

```bash
flutter test --coverage
# Output: coverage/lcov.info

# Generar reporte HTML (requiere lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Patrones de Testing

| Capa | Framework | Patrón |
|------|-----------|--------|
| **BLoC** | `bloc_test` | Testear transiciones events → states |
| **Use Cases** | `mockito` | Mockear repositorio, testear lógica de negocio |
| **Repositories** | `mockito` | Mockear data source, testear mapeo de datos |
| **Models** | `flutter_test` | Testear serialización JSON, `copyWith`, equality |

---

## 📦 Build & Release

### Debug APK

```bash
flutter build apk --debug
```

### Release APK

```bash
./scripts/build_release.sh apk
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Play Store Bundle (AAB)

```bash
./scripts/build_release.sh appbundle
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 🤝 Contribución

Por favor lee [CONTRIBUTING.md](CONTRIBUTING.md) para detalles sobre nuestro flujo de desarrollo, estándares de código y proceso de pull requests.

---

## 🏆 Créditos

Ver [CREDITS.md](CREDITS.md) para atribuciones de terceros.

---

## 🛡️ Seguridad

Para reportar una vulnerabilidad, por favor lee nuestra [Política de Seguridad](SECURITY.md).

---

## 📄 Licencia

Este proyecto está licenciado bajo la [Licencia MIT](LICENSE).

---

<p align="center">
  <sub>Hecho con ❤️ por el equipo de MotoGo</sub>
</p>
