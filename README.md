# ThemesOnRails

Una gema para añadir soporte para múltiples temas en aplicaciones Rails.

## Características

- Soporte para múltiples temas en su aplicación Rails
- Compatible con Rails 3, 4, 7 y 8
- Soporte para múltiples sistemas de assets (Sprockets y Propshaft)
- Layouts, assets y locales específicos por tema

## Instalación

Añade esta línea a tu Gemfile:

```ruby
gem 'themes_on_rails'
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

Esto creará un nuevo tema con la siguiente estructura:

```
app/
  themes/
    nombre_del_tema/
      assets/
        images/
        javascripts/
        stylesheets/
      views/
        layouts/
      locales/
```

### Uso en controladores

Para usar un tema en un controlador específico:

```ruby
class HomeController < ApplicationController
  theme "nombre_del_tema"

  # Por defecto para todas las acciones
  # theme "nombre_del_tema"

  # Para acciones específicas
  # theme "nombre_del_tema", only: [:index]
  # theme "nombre_del_tema", except: [:index]

  # Temas dinámicos
  # theme :theme_resolver

  # def theme_resolver
  #   current_user.theme
  # end
end
```

## Compatibilidad con Rails 8

Esta gema ha sido actualizada para funcionar correctamente con Rails 8, incluyendo soporte para:

- Propshaft (la nueva alternativa a Sprockets)
- Arquitectura de modularización de assets
- Nuevos sistemas de routing y estructuras de controladores

### Consideraciones para Propshaft

Si utilizas Propshaft en Rails 7+, la gema automáticamente:
- Añade las rutas de assets de los temas a las rutas de búsqueda de Propshaft
- Configura los paths de assets para que sean accesibles correctamente
- Asegura que los principales assets de los temas se precompilen

## Versiones compatibles

- Ruby: >= 3.0.0
- Rails: >= 3.2, < 9.0
- Funciona con Sprockets y Propshaft

## Original Authors

* [Chamnap Chhorn](https://github.com/chamnap)

## Licencia

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
