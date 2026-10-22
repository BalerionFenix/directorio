# CLAUDE.md

Guía para Claude Code al trabajar en este repositorio.

## Proyecto

**Directorio de Contactos** es una app web en Flutter (Chrome) con arquitectura por capas y **Cubit (flutter_bloc)**. Muestra un directorio de contactos leído desde `assets/contacts.json`, con búsqueda, filtro por departamento, detalle, favoritos y layout responsive. No hay base de datos local.

### Stack

- **Framework**: Flutter (web / Chrome)
- **Estado**: flutter_bloc (Cubit)
- **Rutas**: go_router
- **UI**: Material Design 3
- **Animaciones**: animated_switcher_plus
- **Datos**: `assets/contacts.json` (sin backend, sin base de datos)
- **Favoritos**: shared_preferences (en web se guarda en el `localStorage` del navegador)

No se usan Dio, Google Fonts, Firebase ni sqflite.

## Arquitectura

```
lib/
├── main.dart                     → solo runApp
├── core/
│   ├── constants/
│   │   ├── app_strings.dart      → todos los textos
│   │   ├── app_colors.dart       → paleta centralizada
│   │   ├── app_routes.dart       → nombres y paths de rutas
│   │   ├── app_assets.dart       → 'assets/contacts.json'
│   │   └── app_dimens.dart       → breakpoint 900, espaciados, duraciones
│   └── router/app_router.dart    → GoRouter único con todas las rutas (estilo Angular)
├── data/
│   ├── models/contact.dart       → Contact.fromJson
│   └── repositories/contact_repository.dart
├── features/
│   ├── contacts/
│   │   ├── cubit/
│   │   │   ├── contacts_cubit.dart
│   │   │   └── contacts_state.dart
│   │   └── presentation/contacts_page.dart
│   ├── contact_detail/
│   │   ├── cubit/
│   │   │   ├── contact_detail_cubit.dart
│   │   │   └── contact_detail_state.dart
│   │   └── presentation/contact_detail_page.dart
│   └── error/
│       ├── cubit/
│       │   ├── error_cubit.dart
│       │   └── error_state.dart
│       └── presentation/error_page.dart
└── shared/widgets/               → contact_card, contact_avatar, search_field,
                                    department_chips, empty_state, loading_skeleton,
                                    contact_detail_view, favorite_button
```

### Flujo de datos

```
Página (presentation)  →  Cubit (cubit)  →  ContactRepository (data)  →  assets/contacts.json
        ▲                      │
        └── BlocBuilder / BlocListener ◄── emite estados
```

- La página no conoce el repositorio: solo llama métodos del cubit y pinta el estado.
- El cubit llama al repositorio, captura errores y emite estados.
- Cada página crea su propio `BlocProvider`.

## Reglas

### Estados
- Un archivo `*_state.dart` por cubit, con **sealed classes**:
  ```dart
  sealed class ContactsState {}
  class ContactsInitial extends ContactsState {}
  class ContactsLoading extends ContactsState {}
  class ContactsSuccess extends ContactsState { ... }
  class ContactsError extends ContactsState {
    final String message;
    ContactsError(this.message);
  }
  ```
- Los estados representan lo que la UI debe mostrar.

### Vistas
- `BlocListener` para efectos (navegación a `/error`, snackbars).
- `BlocBuilder` para reconstruir la UI.
- Cada página debe tener **menos de 500 líneas**. La interfaz larga va a `shared/widgets/`.

### Constantes
- Ningún texto, color, ruta, ruta de asset ni medida va escrito directamente en un widget:
  todo sale de `core/constants/`.
- Para navegar se usan las constantes de `AppRoutes` (ej. `context.go(AppRoutes.contacts)`).

### Repositorio
- `ContactRepository` espera 800 ms (`Future.delayed`) antes de devolver los datos.
- **Una llamada = una carga de la lista** (`getContacts`): falla la nº 2 y después una de cada 4
  (2, 6, 10…). El contador se guarda en el storage del navegador y sobrevive a recargas.
- El detalle (`getContactById`) **no cuenta como llamada**: usa la caché de la última carga exitosa
  o espera la carga de la lista que está en curso.
- Navegación (`core/router/app_navigation.dart`):
  - `context.goToError(mensaje)` lleva a `/error` **sin dejarlo en el historial**; recargar en
    `/error` reintenta la ruta `from`.
  - `context.goReplacing(ruta)` navega reemplazando la entrada actual (filtros, reintento, volver).
  - Los filtros viven en la URL (`?q=&dept=&status=`) y se sincronizan con el cubit en las dos
    direcciones; al abrir/cerrar el detalle se conservan.
- Accesibilidad: lo que se toca usa `InkWell` (enfocable con Tab, Enter/Espacio), no `GestureDetector`.
- Favoritos: se guardan en el storage del navegador con shared_preferences, así se mantienen al
  navegar entre vistas y al recargar la página.

### Cubits
- Cada vista tiene su propio cubit: `contacts`, `contact_detail` y `error`.

### Nombres
- Carpetas y archivos: snake_case (`contact_detail`, `contacts_cubit.dart`)
- Clases: PascalCase (`ContactsCubit`, `ContactDetailPage`)

## Comandos

```bash
flutter pub get
dart analyze lib/
dart format lib/
flutter run -d chrome
flutter test
```

Ver `PLAN.md` para la planificación por fases.
