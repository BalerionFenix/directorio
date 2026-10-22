# Directorio de Contactos — Estructura de vistas (para Stitch)

App **web** de directorio de contactos de una empresa. Estilo limpio, moderno, Material Design 3,
fondo claro, tarjetas con bordes suaves, mucho aire. Idioma de la interfaz: **español**.

Breakpoint: **≥ 900 px = pantalla ancha** (escritorio) · **< 900 px = pantalla angosta** (móvil/tablet).

---

## Sistema visual

### Paleta
| Uso | Color |
|---|---|
| Primario | `#4F46E5` (índigo) · claro `#E0E7FF` |
| Secundario | `#0EA5E9` |
| Fondo | `#F6F7FB` |
| Superficie (tarjetas) | `#FFFFFF` · variante `#F1F3F9` |
| Borde | `#E4E7EF` |
| Texto principal / secundario | `#1F2937` / `#6B7280` |
| Activo | `#16A34A` sobre `#DCFCE7` |
| Inactivo | `#9CA3AF` sobre `#F3F4F6` |
| Error | `#DC2626` sobre `#FEE2E2` |
| Favorito (estrella) | `#F59E0B` |
| Skeleton | `#E5E7EB` → `#F3F4F6` |

### Color por departamento (burbuja de contacto y chips)
| Departamento | Color |
|---|---|
| Comercial | `#EA580C` |
| Diseño | `#DB2777` |
| Ingeniería | `#2563EB` |
| Personas | `#059669` |

### Medidas
- Espaciados: 4 · 8 · 16 · 24 · 32 · 48
- Bordes: 8 · 12 · 20 · píldora
- Burbuja de contacto: 44 (lista) · 56 (tarjeta) · 96 (detalle)

### Estilo vidrio (glass) — aprobado tras Stitch
- **Fondo de la app:** `#F6F7FB` con 3–4 manchas de color grandes y muy difuminadas (índigo
  `#4F46E5`, rosa `#DB2777`, azul `#2563EB`, verde `#059669`, todas al 10–18 % de opacidad).
  Sin ese color detrás, el vidrio no se nota.
- **Paneles de vidrio** (métricas, buscador y filtros, tarjetas, ficha de detalle, vista de error):
  - Fondo blanco al 55–65 % de opacidad + desenfoque del fondo (blur ~18).
  - Borde blanco al 70 % de 1 px y sombra muy suave.
  - Bordes redondeados de 20 px (paneles) y 16 px (tarjetas).
- **Tipografía:** la fuente por defecto de Flutter (sin Google Fonts). Títulos en negrita con
  letras algo más juntas; etiquetas pequeñas en MAYÚSCULAS con letras separadas.

### Componentes reutilizables
- **Burbuja de contacto:** círculo con las iniciales en blanco ("Camila Reyes" → "CR"),
  fondo del color de su departamento. Un punto pequeño en la esquina inferior derecha:
  verde si está activo, gris si está inactivo.
- **Estrella de favorito:** contorno gris si no es favorito; rellena ámbar `#F59E0B` si lo es.
- **Chip de departamento:** píldora con fondo del color del departamento al 12 % y texto en su color.
- **Chip de estado:** "Activo" (verde) o "Inactivo" (gris), con un punto a la izquierda.

---

## Datos de ejemplo

| Nombre | Rol | Departamento | Email | Teléfono | Estado |
|---|---|---|---|---|---|
| Camila Reyes | Product Designer | Diseño | camila.reyes@empresa.cl | +56 9 1111 2222 | Activo |
| Matías Soto | Backend Engineer | Ingeniería | matias.soto@empresa.cl | +56 9 2222 3333 | Activo |
| Valentina Cid | QA Lead | Ingeniería | valentina.cid@empresa.cl | +56 9 3333 4444 | Inactivo |
| Ignacio Muñoz | Sales Rep | Comercial | ignacio.munoz@empresa.cl | +56 9 4444 5555 | Activo |
| Florencia Paz | HR Business Partner | Personas | florencia.paz@empresa.cl | +56 9 5555 6666 | Activo |

---

## Vista 1 — Lista de contactos · pantalla ancha (≥ 900 px)

Patrón **maestro-detalle**: barra de métricas arriba y dos paneles lado a lado.
Contenido centrado con ancho máximo de 1440 px.

```
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ TOTAL        │ │ ACTIVOS      │ │ INACTIVOS    │ │ FAVORITOS    │
│ 18      👥   │ │ 15      ✔    │ │ 3       ⊘    │ │ 4       ★    │
│ contactos    │ │ ● 83 %       │ │ ● 17 %       │ │ marcados     │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
┌──────────────────────────────────────────────────────────────────────────────┐
│  Contactos                                                       18 contactos│
├────────────────────────────────────────────┬─────────────────────────────────┤
│ [🔍 Buscar por nombre                   ✕] │                                 │
│ (Todos) (Comercial) (Diseño) (Ingeniería)  │      PANEL DE DETALLE           │
│ (Personas)                                 │      (ver Vista 3)              │
│                                            │                                 │
│ ┌──────────┐ ┌──────────┐ ┌──────────┐     │                                 │
│ │  (CR)  ☆ │ │  (MS)  ★ │ │  (VC)  ☆ │     │                                 │
│ │ Camila R.│ │ Matías S.│ │Valentina │     │                                 │
│ │ Product  │ │ Backend  │ │ QA Lead  │     │                                 │
│ │ [Diseño] │ │[Ingenie.]│ │[Ingenie.]│     │                                 │
│ └──────────┘ └──────────┘ └──────────┘     │                                 │
│ ┌──────────┐ ┌──────────┐ ...              │                                 │
└────────────────────────────────────────────┴─────────────────────────────────┘
       ~58 % del ancho                                ~42 % del ancho
```

**Barra de métricas (4 paneles de vidrio):** se calculan con los datos reales y se actualizan al
marcar favoritos.

| Métrica | Valor | Línea inferior | Ícono (fondo del ícono) |
|---|---|---|---|
| Total | nº de contactos | "contactos" | personas, índigo (`#EEF2FF`) |
| Activos | nº activos | punto verde + % del total | escudo con check, verde (`#DCFCE7`) |
| Inactivos | nº inactivos | punto gris + % del total | persona tachada, gris (`#F3F4F6`) |
| Favoritos | nº favoritos | estrella ámbar + "marcados" | estrella, ámbar (`#FEF3C7`) |

En pantalla angosta van en 2 columnas.

**Panel izquierdo (maestro):**
- Encabezado: título "Contactos" y a la derecha el total que se ve con el filtro actual ("18 contactos").
- Buscador: ícono de lupa, placeholder "Buscar por nombre". El botón ✕ aparece si hay texto o un
  departamento elegido, y **restablece todo**: borra la búsqueda y vuelve el filtro a "Todos".
- Encima de los chips, la etiqueta "FILTRAR POR DEPARTAMENTO" para que se entienda qué filtran.
- Debajo, "FILTRAR POR ESTADO": **Todos · ● Activos · ● Inactivos**. Se combina con la búsqueda
  y el departamento. La ✕ del buscador también lo restablece.
- Fila de chips de filtro: **Todos · Comercial · Diseño · Ingeniería · Personas**. Se elige uno a
  la vez; el seleccionado va relleno con el color primario.
- Buscador y chips van dentro de un panel de vidrio.
- **Grilla de tarjetas de vidrio, 2 columnas.** Cada tarjeta:
  - Burbuja de contacto (56 px) arriba a la izquierda, estrella de favorito arriba a la derecha.
  - Nombre (negrita), rol (texto secundario).
  - Abajo: chip de departamento a la izquierda y estado ("● Activo" verde / "● Inactivo" gris) a la derecha.
  - Hover: se eleva, sombra un poco mayor y el nombre toma el color primario.
  - **Seleccionada:** borde primario de 2 px, fondo `#EEF2FF` y sombra índigo suave.
  - Inactivos: tarjeta al 90 % de opacidad.

**Panel derecho (detalle):** ver Vista 3. Al elegir otra tarjeta solo cambia este panel.

El panel derecho queda fijo (sticky) al hacer scroll en la grilla.

**Sin contacto seleccionado (panel derecho):**
- Panel de vidrio; ícono de persona con lupa dentro de un círculo gris claro.
- Título "Selecciona un contacto".
- Texto "Elige un contacto de la lista para ver su información completa."

---

## Vista 2 — Lista de contactos · pantalla angosta (< 900 px)

Una sola columna a pantalla completa.

```
┌───────────────────────────────┐
│ Contactos          18 contactos│
│ [🔍 Buscar por nombre       ✕] │
│ (Todos)(Comercial)(Diseño) →   │  ← chips con scroll horizontal
├───────────────────────────────┤
│ (CR) Camila Reyes          ☆  │
│      Product Designer         │
├───────────────────────────────┤
│ (MS) Matías Soto           ★  │
│      Backend Engineer         │
├───────────────────────────────┤
│ (VC) Valentina Cid         ☆  │
│      QA Lead                  │
└───────────────────────────────┘
```

- Mismo encabezado, buscador y chips (los chips se deslizan en horizontal).
- **Lista** (no grilla): burbuja (44 px) + nombre + rol + estrella a la derecha. Separador fino entre filas.
- Al tocar una fila se abre la Vista 4 (detalle a pantalla completa).

---

## Vista 3 — Detalle del contacto · panel (pantalla ancha)

```
┌─────────────────────────────────┐
│ FICHA DE COLABORADOR         ★  │
│─────────────────────────────────│
│            ( CR )               │  ← burbuja 96 px, color del departamento
│         Camila Reyes            │
│       Product Designer          │
│   [Diseño]   [● Activo]         │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ [@] CORREO ELECTRÓNICO      │ │
│ │     camila.reyes@empresa.cl │ │
│ │ [☎] TELÉFONO                │ │
│ │     +56 9 1111 2222         │ │
│ │ [▦] DEPARTAMENTO            │ │
│ │     Diseño                  │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

- Todo dentro de un **panel de vidrio**.
- **Encabezado:** "FICHA DE COLABORADOR" (etiqueta pequeña en mayúsculas) y la estrella de favorito
  a la derecha (texto "Marcar como favorito" / "Quitar de favoritos" al pasar el mouse).
- **Hero centrado:** burbuja grande con punto de estado, nombre (título), rol, chip de
  departamento y chip de estado.
- **Bloque de información:** caja gris muy clara; cada fila con ícono en un cuadrito blanco,
  etiqueta pequeña en mayúsculas y valor debajo: Correo electrónico, Teléfono, Departamento.

**Lo que se descartó del diseño de Stitch:** los botones "Enviar correo" y "Llamar" (la prueba no
los pide) y, porque no existen en los datos, el botón Compartir,
Ubicación/Oficina, Actividad reciente y Jornada laboral. Tampoco van la pestaña "Vista previa" ni el
botón "Ver contacto de ejemplo", que eran solo para la maqueta.
- **Animación:** al abrir o cambiar de contacto, la tarjeta hace un **giro 3D (flip)** horizontal.

---

## Vista 4 — Detalle del contacto · pantalla completa (< 900 px)

- Barra superior con flecha **← Volver** a la izquierda y título "Detalle del contacto";
  estrella de favorito a la derecha.
- Debajo, el mismo contenido de la Vista 3 a todo el ancho.

---

## Vista 5 — Estados de la lista

### 5a. Cargando (skeleton)
- Mientras cargan los datos (~800 ms), se muestran **6 tarjetas fantasma** (ancha) o **8 filas
  fantasma** (angosta) con la misma forma de las reales: círculo gris en lugar de la burbuja,
  barras grises en lugar del nombre y el rol, y una píldora gris en lugar del chip.
- Efecto de brillo (shimmer) que recorre de izquierda a derecha.
- El buscador y los chips se ven, pero deshabilitados.

### 5b. Vacío (búsqueda + filtro sin resultados)
```
          🔍 (ícono grande gris)
     No se encontraron contactos
 Ningún contacto coincide con «Pedro» en Diseño.
          [ Limpiar filtros ]
```
- Centrado en el área de la lista. **Nunca una lista en blanco.**
- El texto cambia según el caso:
  - Solo búsqueda: "Ningún contacto coincide con «Pedro»."
  - Solo filtro: "No hay contactos en Diseño."
  - Ambos: "Ningún contacto coincide con «Pedro» en Diseño."

### 5c. Aparición tipo "pop"
- Al terminar de cargar, las tarjetas o filas aparecen **una por una con un pop**:
  Camila Reyes *pop* → Matías Soto *pop* → Valentina Cid *pop* → Ignacio Muñoz *pop*…
- Cada una entra desde el 60 % de su tamaño y transparente, crece con un pequeño rebote hasta el
  100 % (~350 ms) y la siguiente arranca ~60 ms después.
- El pop suena **al cargar y al cambiar un filtro**. Lo que aparece después con scroll se muestra
  directo (la lista se construye de forma diferida y no debe reanimarse al volver).
- Las métricas de arriba también hacen pop y sus números cuentan desde 0 hasta el valor.

---

## Vista 6 — Contacto no encontrado

Al abrir una URL de un contacto que no existe (ej. `/contacts/999`):
- Ícono de persona tachada en gris.
- Título "Contacto no encontrado".
- Texto "El contacto que buscas no existe o fue eliminado."
- Botón "Volver a la lista".

---

## Vista 7 — Error (pantalla completa)

```
┌───────────────────────────────┐
│                               │
│        ⚠ (ícono en círculo    │
│          rojo claro)          │
│                               │
│        Algo salió mal         │
│  No se pudieron cargar los    │
│  contactos. Revisa tu conexión│
│  e intenta de nuevo.          │
│                               │
│        [ ⟳ Reintentar ]       │
└───────────────────────────────┘
```

- Pantalla propia, centrada, sobre el mismo fondo con manchas de color, contenido en un panel de vidrio.
- Ícono de alerta dentro de un círculo `#FEE2E2` con el ícono en `#DC2626`.
- Título "Algo salió mal" y debajo **el mensaje exacto del error** que la mandó a esta vista.
- Botón principal "Reintentar" con ícono de recarga. Al presionarlo muestra un spinner dentro del
  botón y vuelve a la vista anterior.

---

## Microanimaciones (resumen)

| Dónde | Animación |
|---|---|
| Lista al cargar | Pop una por una (escala 60 % → 100 % con rebote) |
| Métricas | Pop + números que cuentan desde 0 |
| Tarjeta en hover | Se eleva y se marca el borde |
| Cambio de contacto en el detalle | Giro 3D (flip) |
| Estrella de favorito | Pequeño rebote y cambio de color al marcar |
| Chips de filtro | Transición suave de color al seleccionar |
| Cargando | Shimmer en los skeletons |
| Reintentar | Spinner dentro del botón |
