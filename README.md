# ThemesOnRails

Temas por controlador para Rails 7.1+: vistas y layouts en `app/themes/<theme>/views`, locales en
`app/themes/<theme>/locales` y entrypoints de Sprockets `<theme>/all.css` y `<theme>/all.js`.

Requiere Ruby >= 3.2 y Rails >= 7.1, < 9.

## Instalación

```ruby
gem "themes_on_rails", github: "pollinoco/themes_for_rails", branch: "main"
```

## Controladores

```ruby
theme "haven"                                  # fijo
theme :resolve_theme                           # método del controlador (puede ser privado)
theme ->(controller) { controller.store.slug } # Proc
theme :load_store, prepend: true               # antes que los demás before_action

class OrdersController < ApplicationController
  theme :resolve_theme, except: :invoice       # varias declaraciones con only/except
  theme "print", only: :invoice
end
```

- El theme se resuelve **una vez por request**, en un `before_action`: se antepone
  `<themes_path>/<theme>/views` a los view paths y el layout `<theme>` se toma de ahí. Si el theme es un método,
  no hace falta declararlo además como `before_action`.
- Si el theme no tiene una plantilla, Rails cae a `app/views`.
- Con varias declaraciones gana la última que aplica a la acción, también frente a las heredadas. Las acciones
  que no cubre ninguna se renderizan sin layout, igual que `layout ..., only:/except:`.
- Si un `before_action` anterior renderiza, el layout resuelve el theme en ese momento.

## Configuración

```ruby
# config/initializers/themes_on_rails.rb
ThemesOnRails.configure do |c|
  c.themes_path = Rails.root.join("app/themes")
  c.precompile_mode = :entrypoints
  c.extra_entrypoints = %w[lafloresta/booking.js]
end
```

`precompile_mode` decide qué entrypoints de themes se añaden a `config.assets.precompile` (solo con Sprockets):

| Valor | Entrypoints |
|---|---|
| `:entrypoints` (default) | `<theme>/all.js` y `<theme>/all.css` de todos los themes que los tengan |
| `%w[extranet dashboard]` | solo los de esos themes |
| `:none` | ninguno |

`extra_entrypoints` se añade siempre. Las imágenes usadas solo desde ERB se publican desde el host
(`//= link_tree` en `app/assets/config/manifest.js`). La gema añade `app/themes/*/assets/{stylesheets,javascripts,images}`
al load path de Sprockets. Con Propshaft solo se sirven archivos ya compilados.

Los `*.yml` de `app/themes/*/locales/**` se cargan en el árbol global de I18n: usa un espacio de nombres por theme
para evitar colisiones entre themes.

## Generador

```bash
bin/rails g themes_on_rails:theme shop
```

Crea `app/themes/shop/` con layout (ERB o HAML), `all.css`, `all.js`, `images/` y `locales/`. Si `precompile_mode`
no incluye el theme, lo avisa.

## Desarrollo

```bash
bundle install
bundle exec rake test                     # RAILS_VERSION=7.1 bundle exec rake test para otra versión
bundle exec rubocop
```

## Autores

Original de [Chamnap Chhorn](https://github.com/chamnap). Fork mantenido por [pollinoco](https://github.com/pollinoco).
Licencia [MIT](MIT-LICENSE).
