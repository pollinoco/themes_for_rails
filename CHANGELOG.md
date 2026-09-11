# Overview

## 1.3.0

**Breaking:** ya no se precompilan todos los estáticos del theme. Solo se publican los entrypoints lógicos `#{theme}/all.css` y `#{theme}/all.js` (más `extra_entrypoints`). Las imágenes usadas solo desde ERB hay que linkearlas en el host (`//= link_tree` en `app/assets/config/manifest.js`).

* `ThemesOnRails.configure` / `ThemesOnRails.all` resuelven temas desde `Rails.root`, no desde el cwd.
* Load path de Sprockets sin duplicar el subdirectorio `assets/<type>/<theme>` (evita colisión de `all.css` entre themes).
* Precompile entrypoints-only: no globea `assets/**/*`, no publica `.scss` sueltos ni `"all.css"` / `"all.js"` sin prefijo.
* `apply_theme` registra el layout en la clase (fuera del `before_action`) y hace un solo `prepend_view_path`.
* `importmap-rails` deja de ser dependencia runtime. El file watcher de importmap se elimina.
* Generador alineado con Sprockets (`stylesheet_link_tag` / `javascript_include_tag` + `theme/all`).
* README: Sprockets 4 soportado; Propshaft no compila Sass.

## 1.0.0

* Añadido soporte completo para Rails 8
* Integración con Propshaft (nuevo sistema de assets)
* Mejora de la búsqueda de paths para vistas de temas
* Compatibilidad con ActionView::LookupContext en Rails 8
* Optimización de la precompilación de assets para temas
* Mejoras en la documentación y ejemplos de uso

## 0.3.0

* Support liquid templates.
* Support locales in theme directory.
* Support Rails 4.2.x.
* Fix bug switching theme in development, #7.

## 0.2.2

* Fix precompile initializer in Rails 4.1.x.

## 0.2.1

* Take environment check away in precompile initializer.

## 0.2.0

* Support Rails 4.1.x.
* Add precompile initializer for themes located at `app/themes`.

## 0.1.0

* First Release
* Support Rails 3/4.
