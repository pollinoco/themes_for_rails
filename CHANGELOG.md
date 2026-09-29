# Overview

## 2.0.0

**Breaking:**

* Ruby >= 3.2 y Rails >= 7.1. La gema depende de `actionpack`, `actionview` y `railties` en vez de `rails`.
* Sin soporte de Liquid: se eliminan la integración con `liquid-rails` y la plantilla `layout.html.liquid` del generador.
* Sin integración con importmap: se elimina el initializer que pineaba el JS de los themes.
* El generador ya no añade `//= link` a `manifest.js` (con `:entrypoints` era redundante); avisa si `precompile_mode` deja fuera el theme.
* `precompile_mode = :none` ya no ignora `extra_entrypoints`.

**Mejoras:**

* El theme se resuelve una sola vez por request: el `before_action` lo guarda y la lambda del layout lo reutiliza. Antes un `theme :metodo` ejecutaba el método dos veces.
* Varias declaraciones `theme` con `only`/`except` en el mismo controlador; gana la última que aplica a la acción, también frente a las heredadas (la heredada ya no se resuelve).
* `precompile_mode` acepta una lista de themes (`%w[extranet dashboard]`) y valida su valor.
* Las vistas se buscan en `config.themes_path` (antes `app/themes` fijo).
* `theme` ya no modifica el hash de opciones recibido.
* `rails/generators` se carga solo desde el generador. `# frozen_string_literal: true` en todo `lib/`.
* Suite nueva con minitest y un dummy mínimo de Rails; CI con Ruby 3.2–3.4 × Rails 7.1–8.1 y RuboCop (omakase).

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
