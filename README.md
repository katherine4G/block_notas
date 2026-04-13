# 📓 Bloc de Notas

> Aplicación móvil de bloc de notas offline desarrollada con Flutter, con almacenamiento persistente en archivos de texto plano.

---

## 📌 Descripción

**Bloc de Notas** es una aplicación multiplataforma construida con Flutter que permite al usuario crear, editar, buscar y eliminar notas de forma completamente offline. Las notas se persisten en el sistema de archivos del dispositivo como archivos `.txt`, sin necesidad de base de datos ni conexión a internet.

---

## 🎯 Tema seleccionado

**Tema 6 — Almacenamiento local y archivos**

> Desarrollar una app que almacene datos en el dispositivo o gestione archivos básicos.

| Idea de implementación              | Cómo se aplica en este proyecto                                                         |
|-------------------------------------|-----------------------------------------------------------------------------------------|
| Guardar preferencias locales        | Cada nota se persiste automáticamente en el directorio de documentos del dispositivo    |
| Persistir datos simples             | Las notas se guardan como archivos `.txt` con formato delimitado (`---`)                |
| Exportar registros en archivo       | Función de exportación que genera `<título>_export.txt` en la raíz de Documentos       |
| Cargar datos previamente guardados  | Al iniciar la app, `StorageService.loadAllNotes()` lee todos los archivos `.txt` existentes |

---

## 🎯 Objetivo

Desarrollar una aplicación funcional de toma de notas que demuestre el manejo de:

- Persistencia local de datos mediante el sistema de archivos del dispositivo.
- Arquitectura limpia con separación de capas (modelo, servicio, UI).
- Navegación entre pantallas con retorno de resultados.
- Diseño adaptativo con soporte para tema claro y oscuro (Material 3).

---

## 👥 Integrantes

| Nombre               |
|----------------------|
| Katherine Guatemala  |
| Keysha Carrillo      |

---

## 🛠️ Tecnologías

| Tecnología / Paquete  | Versión     | Uso                                              |
|-----------------------|-------------|--------------------------------------------------|
| Flutter               | SDK stable  | Framework principal multiplataforma              |
| Dart                  | ^3.10.7     | Lenguaje de programación                         |
| Material 3            | —           | Sistema de diseño visual (tema claro/oscuro)     |
| `path_provider`       | ^2.1.5      | Obtener directorios del sistema de archivos      |
| `cupertino_icons`     | ^1.0.8      | Iconografía estilo iOS                           |
| `flutter_lints`       | ^6.0.0      | Análisis estático y buenas prácticas             |

---

## 🗂️ Estructura del proyecto

```
lib/
├── main.dart                  # Punto de entrada, configuración de tema
├── models/
│   └── note.dart              # Modelo Note con serialización/deserialización .txt
├── pages/
│   ├── home_page.dart         # Pantalla principal: lista, búsqueda y acciones
│   └── note_editor_page.dart  # Editor de nota nueva o existente
├── services/
│   └── storage_service.dart   # Lectura, escritura, borrado y exportación de archivos
└── widgets/
    ├── note_card.dart         # Tarjeta de nota con swipe para eliminar
    ├── stats_banner.dart      # Banner con estadísticas (total notas y palabras)
    └── empty_state.dart       # Pantalla vacía cuando no hay notas
```

---

## ⚙️ Arquitectura técnica

### Modelo (`Note`)
Clase PODO que representa una nota. Contiene `id`, `title`, `content`, `createdAt` y `updatedAt`. La serialización usa texto plano con el delimitador `---`:

```
Título de la nota
---
Contenido de la nota
---
2026-04-13T10:00:00.000
2026-04-13T12:30:00.000
```

### Servicio (`StorageService`)
Gestiona todas las operaciones de I/O sobre archivos `.txt` almacenados en:
```
<applicationDocumentsDirectory>/notas/note_<id>.txt
```

Operaciones disponibles:
- `loadAllNotes()` — carga y ordena todas las notas por `updatedAt` descendente.
- `saveNote(note)` — crea o sobreescribe el archivo de la nota.
- `deleteNote(note)` — elimina el archivo del disco.
- `exportNote(note)` — copia la nota como `<título>_export.txt` en la raíz de Documentos.
- `getStats()` — retorna total de notas y total de palabras.
- `generateId()` — genera un ID único basado en `DateTime.now()`.

### Pantallas
| Pantalla          | Descripción                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| `HomePage`        | Lista todas las notas, permite buscar en tiempo real, navega al editor      |
| `NoteEditorPage`  | Editor con campos de título y contenido, contador de palabras y caracteres, diálogo de descarte de cambios |

---

## 🚀 Ejecución

### Prerrequisitos

- Flutter SDK instalado ([guía oficial](https://docs.flutter.dev/get-started/install))
- Dispositivo físico o emulador conectado

### Pasos

```bash
# 1. Clonar o abrir el proyecto
cd block_notas

# 2. Obtener dependencias
flutter pub get

# 3. Ejecutar la aplicación
flutter run
```

### Compilar para producción

```bash
# Android APK
flutter build apk --release

# iOS (requiere macOS)
flutter build ios --release

# Windows
flutter build windows --release
```

---

## ✅ Funcionalidades

| # | Funcionalidad                     | Descripción                                                                 |
|---|-----------------------------------|-----------------------------------------------------------------------------|
| 1 | **Crear nota**                    | Botón flotante (+) abre el editor con campos vacíos                        |
| 2 | **Editar nota**                   | Toca una tarjeta para abrir el editor con el contenido existente           |
| 3 | **Guardar nota**                  | Persiste título y contenido en un archivo `.txt` local                     |
| 4 | **Eliminar nota**                 | Swipe hacia la izquierda en la tarjeta + confirmación en diálogo           |
| 5 | **Buscar notas**                  | Filtro en tiempo real por título o contenido                               |
| 6 | **Exportar nota**                 | Copia la nota como archivo independiente en la carpeta de Documentos       |
| 7 | **Contador de palabras/chars**    | El editor muestra en tiempo real el conteo de palabras y caracteres        |
| 8 | **Banner de estadísticas**        | Muestra el total de notas y total de palabras de todas las notas           |
| 9 | **Estado vacío**                  | Ilustración indicativa cuando no hay notas o no hay resultados de búsqueda |
| 10 | **Tema claro / oscuro**          | Se adapta automáticamente al tema del sistema operativo                    |
| 11 | **Confirmación de descarte**     | Diálogo de confirmación al salir del editor con cambios no guardados       |
| 12 | **Fecha relativa en tarjetas**   | Muestra "Ahora mismo", "Hace X min", "Ayer" o la fecha completa           |

---

## 📸 Capturas de pantalla

| Pantalla principal (claro) | Pantalla principal (oscuro) | Editor de nota |
|:--------------------------:|:---------------------------:|:--------------:|
| *(agregar captura)*        | *(agregar captura)*         | *(agregar captura)* |

---

## 📄 Licencia

Proyecto académico — uso educativo.

