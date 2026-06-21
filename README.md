# HogarStock

HogarStock es una aplicacion movil multiplataforma desarrollada en Flutter para
gestionar el inventario de productos almacenados en el hogar. Funciona
completamente offline y guarda la informacion localmente en el dispositivo con
Hive.

El proyecto no usa backend, autenticacion, Firebase, SQLite, APIs externas ni
sincronizacion en la nube. Esta pensado como una entrega universitaria con una
arquitectura sencilla y facil de explicar.

## Sitio Web

https://dfchaparro-poli.github.io/hogar-stock/

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

## Website

El sitio estatico de presentacion vive en `website/` y esta preparado para
GitHub Pages. Usa HTML, CSS y JavaScript puro.

- Agrega capturas de la app en `website/captures/`.
- Publica la ultima APK en `release/`.
- El workflow `.github/workflows/deploy-website.yml` genera automaticamente los
  manifiestos `website/data/captures.json` y
  `website/data/website-data.json` al desplegar.

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
- Adjuntar imagenes a productos desde la galeria del dispositivo.
- Exportar e importar el inventario completo en formato JSON desde el dispositivo.
- Persistencia local con Hive.
- Estados vacios y mensajes para busquedas sin resultados.
- Confirmaciones antes de eliminar productos o categorias.
