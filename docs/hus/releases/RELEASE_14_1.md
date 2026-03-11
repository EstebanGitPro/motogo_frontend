# Release 14.1: Fix Calificaciones por Sede

**Tag Git**: `v0.14.1`
**Estado**: ✅ Completado
**Fecha**: 2026-03-11

## Descripción

Corrección de un bug donde las calificaciones (reviews) de servicios se compartían entre todas las sedes en lugar de estar asociadas a la sede específica. Se agregó el parámetro `branchId` a lo largo de toda la cadena de datos (datasource → repository → usecase → BLoC → UI).

## Cambios Realizados

### Bug Fixes

| Archivo | Cambio |
|---------|--------|
| `service_rating_datasource.dart` | Agregar `branchId` al request de reviews |
| `service_rating_repository_impl.dart` | Propagar `branchId` en la implementación |
| `service_rating_repository.dart` | Agregar `branchId` al contrato del repositorio |
| `get_service_reviews_usecase.dart` | Incluir `branchId` en los parámetros del caso de uso |
| `service_reviews_bloc.dart` | Pasar `branchId` al cargar reviews |
| `service_reviews_page.dart` | Recibir y reenviar `branchId` |

### Integración UI

| Archivo | Cambio |
|---------|--------|
| `service_card_widget.dart` | Enviar `branchId` al navegar a reviews |
| `branch_services_tab.dart` | Propagar contexto de `branchId` |
| `branch_detail_page.dart` | Incluir `branchId` en navegación a reviews |

### Tests

| Archivo | Cambio |
|---------|--------|
| `service_rating_datasource_test.dart` | Validar `branchId` en requests |
| `service_rating_repository_impl_test.dart` | Verificar propagación del parámetro |
| `get_service_reviews_usecase_test.dart` | Actualizar assertions con `branchId` |
| `service_reviews_bloc_test.dart` | Validar estados del BLoC con `branchId` |

### Mantenimiento

- Regeneración de `injector.g.dart` y todos los archivos `.mocks.dart`
- Agregar `.kotlin/` al `.gitignore`
- Actualizar `integration_test/README.md`

## Historias de Usuario Relacionadas

| HU | Descripción | Estado |
|----|-------------|--------|
| HU2 | Registrar Información de la Calificación | ✅ Fix aplicado |
| HU3 | Consultar Información de la Calificación | ✅ Fix aplicado |

## Métricas

- **Cobertura de tests**: 88.3%
- **Issues SonarCloud**: 26 info (solo `directives_ordering` y `unawaited_futures`)

## PR

- [PR #46](https://github.com/EstebanGitPro/motogo_frontend/pull/46) - Release v0.14.1
