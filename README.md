# HogarStock

HogarStock es una aplicacion movil multiplataforma desarrollada en Flutter para
gestionar el inventario de productos almacenados en el hogar. Funciona
completamente offline y guarda la informacion localmente en el dispositivo con
Hive.

El proyecto no usa backend, autenticacion, Firebase, SQLite, APIs externas ni
sincronizacion en la nube. Esta pensado como una entrega universitaria con una
arquitectura sencilla y facil de explicar.

## Requisitos

- Ubuntu Desktop o una distribucion Linux compatible.
- Flutter 3.x instalado.
- Android SDK configurado.
- Java/JDK compatible con Flutter.

Para comprobar el entorno:

```bash
flutter doctor
```

## Instalacion

```bash
cd source
flutter pub get
```

## Ejecucion

Desde la carpeta `source`:

```bash
flutter run
```

La aplicacion tambien queda preparada para futuras compilaciones en Android,
iOS, Linux, macOS, Windows y Web, segun las herramientas disponibles en cada
sistema operativo.

## Compilacion APK

Desde la raiz del repositorio:

```bash
cd source
./scripts/build-apk.sh
```

El script ejecuta `flutter clean`, `flutter pub get`, `flutter build apk
--release`, lee la version desde `pubspec.yaml` y copia el APK final en:

```text
release/HogarStock-v1.0.0.apk
```

## Limpieza

```bash
cd source
./scripts/clean.sh
```

Este script limpia los artefactos de build y elimina APKs generados en
`release`.

## Estructura Del Proyecto

```text
source/
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
├── assets/
│   ├── images/
│   ├── icons/
│   └── categories/
├── scripts/
│   ├── build-apk.sh
│   └── clean.sh
├── lib/
│   ├── app/
│   ├── core/
│   ├── models/
│   ├── services/
│   ├── screens/
│   ├── widgets/
│   └── main.dart
├── test/
├── pubspec.yaml
└── analysis_options.yaml
```

## Funcionalidades

- Registrar, consultar, editar y eliminar productos.
- Buscar productos por nombre.
- Filtrar productos por categoria.
- Gestionar categorias.
- Consultar productos proximos a vencer en los proximos 15 dias.
- Consultar productos por reponer.
- Persistencia local con Hive.
- Estados vacios y mensajes para busquedas sin resultados.
- Confirmaciones antes de eliminar productos o categorias.
