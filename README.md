# ThemesOnRails

Gema para añadir soporte de múltiples temas en aplicaciones Rails (vistas, locales y assets Sprockets).

## Características

- Layouts, vistas y locales por tema
- Load path de Sprockets 4 para nombres lógicos `#{theme}/all.css` y `#{theme}/all.js`
- API de controlador: `theme "x"`, `theme :metodo`, `theme -> { }`, opciones `:only`, `:except`, `:prepend`
- Compatible con Rails 6.1–8 y Ruby >= 3.0

## Instalación

Añade esta línea a tu Gemfile:

```ruby
gem "themes_on_rails", git: "https://github.com/pollinoco/themes_for_rails.git"
```

Y luego ejecuta:

```bash
$ bundle install
```

## Uso

### Generación de un tema

```bash
$ rails g themes_on_rails:theme nombre_del_tema
```

Esto crea:

```
app/themes/nombre_del_tema/
  assets/
    images/nombre_del_tema/
    javascripts/nombre_del_tema/all.js
    stylesheets/nombre_del_tema/all.css   # o all.scss
  views/
    layouts/nombre_del_tema.html.erb
  locales/
```

En el layout del tema:

```erb
<%= stylesheet_link_tag "nombre_del_tema/all", media: "all" %>
<%= javascript_include_tag "nombre_del_tema/all" %>
```

### Uso en controladores

```ruby
class HomeController < ApplicationController
  theme "nombre_del_tema"

  # Para acciones específicas
  # theme "nombre_del_tema", only: [:index]
  # theme "nombre_del_tema", except: [:index]

  # Temas dinámicos
  # theme :theme_resolver
  # theme -> { current_store.theme_slug }

  # def theme_resolver
  #   current_user.theme
  # end
end
```

Si el tema no tiene una plantilla, Rails cae a `app/views`.

## Assets (Sprockets 4)

Esta gema **está pensada para Sprockets 4** (`sprockets-rails`, `dartsass-sprockets`).

| Capa | Quién | Qué |
|---|---|---|
| Load path | gem | `app/themes/*/assets/{stylesheets,javascripts,images}` |
| Qué publicar | gem (`:entrypoints`) + host `manifest.js` | `#{theme}/all.css`, `#{theme}/all.js`, extras |
| Dependencias CSS | Sprockets | fonts/images vía `asset-url` / `font-url` / `image-url` |
| Árboles extra (fotos de UI) | host `//= link_tree` | opcional |

El logical path es `itook/all.css` porque el archivo vive en `assets/stylesheets/itook/all.scss`. **No** se publica el `.scss` como asset digerido. Fuentes e imágenes referenciadas desde SCSS las publica Sprockets como dependencias del CSS.

Imágenes usadas solo desde ERB (`image_tag "lafloresta/logo.png"`): decláralas en el host con `//= link_tree` en `app/assets/config/manifest.js`. La gema no globea el árbol.

Si el host ya tiene `//= link itook/all.css`, duplicar en `precompile` es idempotente.

### Propshaft

Propshaft solo sirve archivos estáticos ya compilados. **Esta gema no compila Sass bajo Propshaft.** Si tu app usa `@import`, `dartsass-sprockets` o entrypoints `theme/all.scss`, quédate en Sprockets.

### importmap

Opcional. No es dependencia de la gema ni el camino por defecto del generador. Si el host tiene `importmap-rails`, la gema puede pinear el JS del tema; los layouts reales pueden seguir usando `javascript_include_tag`.

## Configuración

```ruby
# config/initializers/themes_on_rails.rb
ThemesOnRails.configure do |c|
  c.themes_path = Rails.root.join("app/themes")
  c.precompile_mode = :entrypoints # o :none para vivir solo del manifest.js
  c.extra_entrypoints = %w[lafloresta/booking.js itook/shop.js]
end
```

- `:entrypoints` (default): precompila `#{theme}/all.js` y `#{theme}/all.css` si existen, más `extra_entrypoints`.
- `:none`: la gema no toca `config.assets.precompile`. El host declara todo en `manifest.js`.

## Versiones compatibles

- Ruby: >= 3.0.0
- Rails: >= 6.1, < 9.0
- Sprockets 4: soportado
- Propshaft: solo estáticos ya compilados (sin Sass)
- importmap-rails: opcional, no requerido

## Original Authors

* [Chamnap Chhorn](https://github.com/chamnap)

## Licencia

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
