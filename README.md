# Directorio de Contactos

App web en Flutter (Chrome) para consultar el directorio de contactos de una empresa: búsqueda en
tiempo real, filtros por departamento y estado, detalle del contacto, favoritos y layout
responsive maestro-detalle. Los datos vienen de `assets/contacts.json` (no hay base de datos ni
backend).

---

## Cómo correr el proyecto

Requisitos: Flutter estable (probado con Flutter 3.44 / Dart 3.12) y Google Chrome.

```bash
flutter pub get
flutter run -d chrome
```

Pruebas automatizadas:

```bash
flutter test
```

Solo las pruebas de búsqueda y filtro con el JSON real:

```bash
flutter test test/features/search_and_filter_test.dart
```

> El contador de llamadas y los favoritos se guardan en el `localStorage` del navegador. Para
> empezar de cero (llamada 1), borra el almacenamiento del sitio desde las herramientas de
> desarrollo de Chrome.

---

## Qué hace la app

| Requisito | Cómo quedó |
|---|---|
| Lista cargada de forma asíncrona | `ContactRepository` espera **800 ms** (`Future.delayed`) antes de devolver los datos |
| Fallo forzado (1 de cada 4) | Contador interno: falla la carga **2** y luego una de cada 4 (**2, 6, 10…**) |
| Estados explícitos | Cargando (skeletons), datos, vacío y error con botón **Reintentar** |
| Búsqueda en tiempo real | Por nombre, sin distinguir mayúsculas ni tildes (`matias` encuentra a *Matías*) |
| Filtro por departamento | Comercial · Diseño · Ingeniería · Personas, combinable con la búsqueda |
| Filtro por estado (extra) | Todos · Activos · Inactivos, combinable con lo anterior |
| Estado vacío | Mensaje claro según los filtros, p. ej. *"Ningún contacto coincide con «pedro» en Diseño."* + "Limpiar filtros" |
| Detalle | Ficha con rol, departamento, email, teléfono y estado activo/inactivo |
| Responsive | **≥ 900 px**: lista y detalle lado a lado (el detalle cambia sin recargar la lista). **< 900 px**: lista a pantalla completa y detalle en su propia vista con botón volver |
| Favoritos | Estrella en la lista y en el detalle, sincronizadas |
| GoRouter con rutas reales | `/contacts`, `/contacts/:id`, `/error`; deep link funcional y botón atrás del navegador coherente |
| Filtros en la URL | `?q=&dept=&status=` en las dos direcciones (filtros → URL y URL → filtros) |

Rutas:

| Ruta | Vista |
|---|---|
| `/` | redirige a `/contacts` |
| `/contacts?q=pedro&dept=Diseño&status=activos` | lista filtrada |
| `/contacts/:id` | detalle (al lado de la lista en pantalla ancha) |
| `/error?message=...&from=...` | vista de error con Reintentar |

---

## Decisiones y por qué

### Gestión de estado: Cubit (flutter_bloc)

Usé **Cubit** porque es el que más he manejado y me da control explícito de cada estado. Cada vista
tiene **su propio cubit** con estados como `sealed class`, así el `switch` de la vista obliga a
cubrir todos los casos:

- `ContactsCubit` → `Initial`, `Loading`, `Success`, `Empty`, `Error`
- `ContactDetailCubit` → `Initial`, `Loading`, `Success`, `NotFound`, `Error`
- `ErrorCubit` → `Initial`, `Retrying`, `RetryReady`

No usé `ChangeNotifier` porque para este caso no lo necesitaba: con Cubit los estados quedan
tipados y separados de la vista, y la vista solo reacciona con `BlocBuilder` (pintar) y
`BlocListener` (efectos como navegar a `/error`).

### Estructura de carpetas: capas separadas (inspirada en Clean Architecture)

Me baso en la lógica de Clean Architecture: **entre más separadas estén las capas de presentación,
estado y datos, más fácil es implementar y cambiar cosas**.

```
lib/
├── main.dart                     → solo runApp + MaterialApp.router
├── core/
│   ├── constants/                → textos, colores, rutas, assets y medidas (nada escrito a mano en los widgets)
│   └── router/                   → GoRouter único con todas las rutas + atajos de navegación
├── data/
│   ├── models/contact.dart       → Contact.fromJson
│   └── repositories/contact_repository.dart
├── features/                     → una carpeta por vista, cada una con su cubit y su presentación
│   ├── contacts/        (cubit/ + presentation/)
│   ├── contact_detail/  (cubit/ + presentation/)
│   └── error/           (cubit/ + presentation/)
└── shared/widgets/               → widgets reutilizables (tarjeta, avatar, chips, buscador, skeletons…)
```

Flujo: **Vista → Cubit → Repositorio → JSON**. La vista nunca habla con el repositorio.

- **Constantes centralizadas** (`app_strings`, `app_colors`, `app_routes`, `app_assets`,
  `app_dimens`): si cambia un texto, un color o una ruta, se cambia en un solo lugar. Para navegar
  se usa la constante (`AppRoutes.contacts`), igual que las rutas en Angular.
- **Vistas cortas**: cada página solo arma el layout y conecta su cubit (todas por debajo de 500
  líneas). La interfaz larga vive en `shared/widgets/` y se reutiliza.

### GoRouter desde el inicio

GoRouter maneja directamente el **historial del navegador**, por eso es el que más se usa en Flutter
Web. Lo puse desde el principio porque si más adelante tenía que migrar del router básico a GoRouter,
eso se convierte en deuda técnica. En un proyecto tan pequeño no sería grave, pero era hacer más
proceso cuando se podía hacer bien a la primera.

- **Un solo router con todas las rutas** (`core/router/app_router.dart`), al estilo Angular.
- **URLs limpias** (`/contacts/7`, sin `#`) con `usePathUrlStrategy`.
- **`ShellRoute` para lista + detalle**: las dos rutas comparten la misma página de contactos, que
  no se destruye al abrir un detalle. Así, en pantalla ancha, el detalle cambia **sin recargar la
  lista** (sin otros 800 ms ni otra llamada al contador).
- **El error no queda en el historial**: se entra y se sale de `/error` reemplazando la entrada
  actual. El botón atrás del navegador lleva a la página anterior, no a un error viejo, y
  **recargar estando en `/error` reintenta** la ruta que había fallado (igual que el botón).
- **Filtros en la URL**: cada cambio de búsqueda o filtro **reemplaza** la URL (no llena el historial
  con cada tecla). Abrir y cerrar el detalle conserva los filtros, y pegar una URL con filtros abre
  la lista ya filtrada.

### Repositorio: espera, fallo y caché

- **Una llamada = una carga de la lista.** Cada carga espera 800 ms y puede fallar (2, 6, 10…).
- **El detalle no cuenta como llamada**: toma el contacto de la última carga exitosa (caché), o
  espera la carga de la lista que está en curso si se abre `/contacts/7` directo. Así el patrón es
  predecible por recarga: 1 ✔, 2 ✘, 3 ✔, 4 ✔, 5 ✔, 6 ✘…
- **El contador se guarda en el `localStorage`**: si solo viviera en memoria, al recargar la página
  volvería a 0 y la llamada 2 nunca llegaría a ocurrir.
- **Favoritos en el `localStorage`** (`shared_preferences`): se mantienen al ir de la lista al
  detalle y volver, y también al recargar.

### Diseño

- La estructura de las vistas la escribí en `VISTAS.md` y la pasé por **Stitch** para tener una
  referencia visual; eso me agilizó muchísimo el diseño. De esa maqueta tomé la barra de métricas,
  la grilla de tarjetas y la ficha de colaborador, y dejé por fuera lo que no existe en los datos
  (ubicación, actividad, horario) o que la prueba no pide (enviar correo, llamar).
- **Estilo vidrio (glass)**: paneles translúcidos con desenfoque sobre un fondo con manchas de color.
  Solo los paneles grandes desenfocan; las tarjetas no, porque muchos desenfoques a la vez son
  pesados en web.
- **Microanimaciones**: aparición "pop" escalonada al cargar o filtrar, giro 3D de la ficha al
  abrir un contacto, rebote de la estrella y números de las métricas que cuentan desde 0.

### Rendimiento

La grilla y la lista se construyen de forma **diferida** con slivers (`SliverGrid` / `SliverList`):
Flutter solo construye lo que está en pantalla más un margen y libera lo que se aleja. La animación
"pop" solo se reproduce al cargar o al cambiar un filtro, no al hacer scroll.

### Accesibilidad básica

- Tarjetas y chips usan `InkWell`: se pueden enfocar con **Tab**, se activan con **Enter/Espacio** y
  se anuncian como botones. El foco se marca con el borde morado.
- Orden de Tab lógico: buscador → departamentos → estado → tarjetas → detalle.
- Botones solo con ícono (estrella, volver, limpiar) tienen texto de ayuda (tooltip).
- El correo y el teléfono del detalle se pueden seleccionar para copiarlos.

---

## Pruebas automatizadas

42 pruebas (`flutter test`):

| Archivo | Qué prueba |
|---|---|
| `test/features/search_and_filter_test.dart` | **Búsqueda + filtro con el `contacts.json` real**, estilo `test.each` de Jest: una tabla de casos que **se encuentran** (ej. `"camila"` en Diseño → `[Camila Reyes]`) y casos que **no se encuentran** (ej. `"camila"` en Ingeniería → vacío con mensaje). Lo esperado sale de cada fila, no de nombres fijos |
| `test/features/contacts_cubit_test.dart` | Cubit de la lista: carga, búsqueda sin tildes, filtros combinados, vacío, error, favoritos |
| `test/features/contact_detail_cubit_test.dart` | Cubit del detalle: carga, no encontrado, error, favoritos sincronizados |
| `test/data/contact_repository_test.dart` | Repositorio: falla en la 2 y la 6, el detalle no gasta llamadas, lista y detalle comparten una llamada |
| `test/widget_test.dart` | Navegación: deep links, filtros en la URL, vista de error, recargar en `/error`, responsive |

---

## Qué dejé por fuera y qué haría distinto con más horas

- **Pruebas**: quisiera haberlas manejado mejor. No alcancé a confirmar todos los escenarios de
  forma manual en el navegador, y faltan pruebas de integración de punta a punta.
- **Flecha volver del detalle**: hoy reemplaza la entrada del detalle por la lista. Lo ideal sería
  retroceder en el historial real del navegador, pero eso requería otro paquete.
- **Más tiempo de contexto y revisión**: me tomaría más tiempo para entender el contexto completo
  antes de desarrollar y para revisar el código con más calma.

---

## Uso de asistente de IA

Usé **Claude Code** en el desarrollo y en la planificación. Mi forma de trabajar es que la IA
escribe el código y **yo lo reviso**. En la planificación los criterios los tomamos entre los dos,
pero parto de un criterio propio porque ya he desarrollado aplicaciones móviles y web: por ejemplo,
la arquitectura por capas, Cubit por vista, GoRouter desde el inicio, el contador por carga de la
lista y guardarlo en el storage fueron decisiones mías.

Para el diseño usé **Stitch** como referencia visual a partir de la estructura de vistas que definí.

Archivos de apoyo en el repositorio: `PLAN.md` (planificación por fases), `VISTAS.md` (estructura
de las vistas que pasé a Stitch) y `CLAUDE.md` (reglas del proyecto para el asistente).
