# Directorio de Contactos — Planificación

App web en Flutter (Chrome) que muestra un directorio de contactos leído desde `assets/contacts.json`.
Sin base de datos local. Gestión de estado con **flutter_bloc (Cubit)** y navegación con **GoRouter**.
Cada página crea su propio `BlocProvider` y los estados son `sealed class`.

---

## 1. Arquitectura

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

**Regla de tamaño:** cada página solo arma el layout y conecta el cubit (menos de 500 líneas).
Toda la interfaz larga va en `shared/widgets/`.

---

## 2. Flujo entre capas

```
Página (presentation)
   │  BlocBuilder / BlocListener
   ▼
Cubit (cubit)  →  emite estados: cargando, éxito, vacío, error
   │
   ▼
ContactRepository (data/repositories)  →  lee assets/contacts.json
```

- La página **no** conoce el repositorio; solo llama métodos del cubit y pinta el estado.
- El cubit captura las excepciones del repositorio y las convierte en un estado de error con mensaje.

---

## 3. Repositorio — `ContactRepository`

| Método | Qué hace |
|---|---|
| `getContacts()` | `Future.delayed(800 ms)` → lee el asset → `List<Contact>` |
| `getContactById(id)` | Igual que el anterior y devuelve el contacto, o `null` si no existe |
| `getFavoriteIds()` | Lee los favoritos del storage del navegador |
| `toggleFavorite(id)` | Marca o desmarca y lo guarda en el storage |

- **Fallo forzado con contador interno:** falla la **llamada nº 2** y desde ahí una de cada 4
  (2, 6, 10…) lanzando una excepción. Así siempre se reproduce durante la sesión.
- **Favoritos en el storage del navegador** (`shared_preferences` → `localStorage` en web): se
  mantienen al ir de la lista al detalle y volver, y también al recargar la página.
- **Una llamada = una carga de la lista.** El detalle no cuenta: toma el contacto de la caché de la
  última carga exitosa, o espera la carga de la lista en curso (al abrir `/contacts/1` directo).
- El **contador de llamadas** se guarda en el storage del navegador: sigue contando aunque se
  recargue la página. Patrón por recarga: 1 ✔, 2 ✘, 3 ✔, 4 ✔, 5 ✔, 6 ✘, 7 ✔…

---

## 4. Estados (un cubit por vista)

### `ContactsState` (lista)
- `ContactsInitial`
- `ContactsLoading` → skeletons
- `ContactsSuccess(contacts, query, department, favoriteIds)`
- `ContactsEmpty(query, department)` → "No se encontraron contactos para «Pedro» en Diseño" + botón "Limpiar filtros"
- `ContactsError(message)` → redirige a la vista de error

Métodos: `loadContacts()`, `search(query)`, `filterByDepartment(dept)`, `toggleFavorite(id)`, `clearFilters()`.

**Búsqueda + filtro combinados:** el nombre se busca en tiempo real, sin distinguir mayúsculas ni
tildes ("matias" encuentra "Matías"), **y además** se aplica el departamento elegido.
Ejemplo: "Pedro" + "Ingeniería" muestra solo los Pedro de Ingeniería.
Chips: **Todos · Comercial · Diseño · Ingeniería · Personas**.

### `ContactDetailState` (detalle)
- `ContactDetailInitial`
- `ContactDetailLoading` → skeleton del detalle
- `ContactDetailSuccess(contact, isFavorite)`
- `ContactDetailNotFound` → "Contacto no encontrado" (ej. `/contacts/999`)
- `ContactDetailError(message)` → redirige a la vista de error

Métodos: `loadContact(id)`, `toggleFavorite()`.

### `ErrorState` (vista de error)
- `ErrorInitial(message, from)` → muestra el error recibido por la URL
- `ErrorRetrying` → animación mientras vuelve a intentar
- `ErrorRetryReady(from)` → navega de vuelta a la ruta `from`

Métodos: `retry()`.

---

## 5. Rutas — `AppRoutes` + `core/router/app_router.dart`

| Ruta | Vista |
|---|---|
| `/` | redirige a `/contacts` |
| `/contacts?q=pedro&dept=Diseño` | lista (búsqueda y filtro en la URL) |
| `/contacts/:id` | detalle del contacto |
| `/error?message=...&from=/contacts` | vista de error con botón **Reintentar** |

- **`ShellRoute` para lista + detalle:** `/contacts` y `/contacts/:id` comparten la misma
  `ContactsPage`. No cambia carpetas ni archivos: solo evita que la página de contactos se
  destruya al abrir un detalle. Sin esto, en pantalla ancha cada clic en un contacto recrearía la
  lista (otros 800 ms y otra llamada al contador de fallos), y el requisito pide que el detalle se
  actualice **sin recargar la lista**.
  - Ancha: `ContactsPage` pinta la lista a la izquierda y el detalle (o "Selecciona un contacto") a la derecha.
  - Angosta: `ContactsPage` pinta la lista, o el detalle a pantalla completa si la URL es `/contacts/:id`.
- **Vista de error:** cuando el cubit emite error, el `BlocListener` navega a `/error` con el
  mensaje en la URL (sobrevive a una recarga). **Reintentar** vuelve a la ruta `from` y carga de nuevo.
- **Historial del navegador:** buscar y filtrar **reemplazan** la URL (no llenan el historial con
  cada tecla); abrir un contacto **agrega** una entrada. El botón atrás vuelve a la lista con la
  búsqueda y el filtro que tenías.
- **Deep link:** pegar o recargar una URL (ej. `/contacts/7` o `/contacts?q=ana&dept=Diseño`)
  abre directamente esa vista con ese estado. Si el id no existe: "Contacto no encontrado".

---

## 6. Layout responsive (breakpoint en `app_dimens.dart`: 900 px lógicos)

**Pantalla ancha (≥ 900 px)** — maestro-detalle lado a lado
- Izquierda: contactos en **grilla de tarjetas** (`contact_card`): burbuja de contacto, nombre,
  rol, chip de departamento y estrella de favorito. Algo más de detalle que la lista, sin llegar a todo.
- Derecha: `contact_detail_view`. Al seleccionar otro contacto solo cambia el panel; la lista no se recarga.
- Sin selección: "Selecciona un contacto".

**Pantalla angosta (< 900 px)**
- Lista a pantalla completa: burbuja + nombre + rol + favorito.
- Al tocar un contacto se navega a `/contacts/:id` (`contact_detail_page`) con botón **volver**.

---

## 7. Detalle del contacto (`contact_detail_view`)

- Cabecera con burbuja grande (color del departamento), nombre y rol.
- Datos: departamento, email, teléfono, chip **Activo / Inactivo**.
- Botón de favorito.
- **Animación de giro:** la tarjeta del detalle hace un *flip* 3D al abrir o cambiar de contacto.

---

## 8. Fases

### Fase 1 — Base
- [x] Paquetes en `dependencies`: `flutter_bloc`, `go_router`, `animated_switcher_plus`, `shared_preferences`
- [x] Corregir `contacts.json` (ya corregido)
- [x] Constantes: `app_strings`, `app_colors`, `app_routes`, `app_assets`, `app_dimens`
- [x] `data/models/contact.dart` con `Contact.fromJson`
- [x] `data/repositories/contact_repository.dart` con delay de 800 ms, fallo en llamadas 2, 6, 10… y favoritos en el storage

### Fase 2 — Navegación
- [x] `core/router/app_router.dart` con `/contacts`, `/contacts/:id` y `/error`
      (lista y detalle dentro de un `ShellRoute` para que la lista no se recargue)
- [x] `main.dart` limpio (solo `runApp` + `MaterialApp.router`) con URLs sin `#`
- [x] `ErrorCubit` + `ErrorState`
- [x] `error_page.dart` con el mensaje recibido y botón Reintentar
- [x] Páginas base de lista y detalle (estructura responsive; su interfaz va en las Fases 3 y 4)

### Fase 3 — Lista
- [x] Fondo con manchas de color suaves + paneles tipo vidrio (glass), según `VISTAS.md`
- [x] Barra de métricas: total, activos, inactivos y favoritos (calculados de los datos)
- [x] `ContactsCubit` + `ContactsState`
- [x] `search_field` en tiempo real y `department_chips` (combinables)
- [x] `empty_state` con mensaje claro y "Limpiar filtros"
- [x] `loading_skeleton`
- [x] Aparición "pop" de las tarjetas, una tras otra (solo al cargar o filtrar, no al hacer scroll)
- [x] Filtro por estado (Todos · Activos · Inactivos), combinable; `?status=activos|inactivos`
- [x] La ✕ del buscador restablece búsqueda, departamento y estado
- [x] Lista y grilla diferidas con slivers (solo se construye lo visible + un margen)

### Fase 4 — Detalle
- [x] `ContactDetailCubit` + `ContactDetailState`
- [x] `contact_detail_view` con toda la información (ficha de colaborador en panel de vidrio)
- [x] `/contacts/40` (o un id inválido) muestra "Contacto no encontrado"
- [x] `contact_detail_page` con botón volver y estado "no encontrado"
- [x] Animación de giro
- [x] Contador de llamadas guardado en el storage (sigue contando al recargar la página)
- [x] Solo la carga de la lista cuenta como llamada; el detalle usa caché
- [x] Un solo redirect a `/error` aunque fallen lista y detalle a la vez (`context.goToError`)

### Fase 5 — Responsive
- [x] Grilla + detalle lado a lado (≥ 900 px) / lista + navegación (< 900 px)
- [x] Botón volver en pantalla angosta

### Fase 6 — Pulido (plus)
- [x] `favorite_button` en lista y detalle, sincronizados
- [x] Microanimaciones: pop escalonado de la lista, giro entre contactos, rebote en la estrella

### Fase 7 — Cierre
- [x] Búsqueda, departamento y estado sincronizados con los query params (`?q=&dept=&status=`)
      en las dos direcciones; los cambios de filtro **reemplazan** la URL (no llenan el historial)
- [x] Abrir y cerrar el detalle conserva los filtros
- [x] Deep link: recargar en `/contacts/7` o en `/contacts?q=pedro&dept=Diseño` abre ese estado
- [x] Botón atrás del navegador coherente: `/error` **no queda en el historial**
      (se entra y se sale reemplazando la entrada)
- [x] Recargar en `/error` reintenta la ruta que había fallado (igual que el botón Reintentar)
- [ ] README (más adelante)

### Fase 8 — Pruebas automatizadas y accesibilidad
- [x] Pruebas de búsqueda + filtro con el `contacts.json` real
      (`test/features/search_and_filter_test.dart`): un caso que encuentra y otro que no
- [x] Pruebas del cubit de lista, cubit de detalle, repositorio y navegación (widget tests)
- [x] Tarjetas y chips enfocables con Tab y activables con Enter/Espacio (`InkWell`); el foco se
      marca con el borde primario
- [x] Orden de Tab lógico: buscador → chips de departamento → chips de estado → tarjetas → detalle

Correr todas las pruebas: `flutter test` · solo búsqueda/filtro:
`flutter test test/features/search_and_filter_test.dart`
