# HogarStock

Aplicacion movil multiplataforma en Flutter para gestionar inventario de
productos del hogar. Funciona completamente offline y guarda la informacion de
productos y categorias de forma local con Hive.

No usa SQLite, backend, Firebase, autenticacion, APIs externas ni
sincronizacion en la nube.

## Funcionalidades

- Registrar, consultar, editar y eliminar productos.
- Buscar productos por nombre y filtrar por categoria.
- Registrar fecha de vencimiento y consultar productos proximos a vencer.
- Registrar cantidad minima y consultar productos por reponer.
- Gestionar categorias.
- Ver resumen del inventario.
- Adjuntar imagenes a productos desde la galeria.
- Exportar e importar el inventario completo en JSON desde el dispositivo.

## Desarrollo

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk
```

La version de entrega se define en `pubspec.yaml`.
