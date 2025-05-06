// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
//= require_tree .

// Archivo principal de JavaScript para el tema <%= theme_name %>
// Utilizando importmap-rails para la gestión de módulos

// Importaciones de ejemplo (descomenta las que necesites)
// import { Application } from "@hotwired/stimulus"
// import { Controller } from "@hotwired/stimulus"

// Importaciones de componentes del tema (usa tu propio componente)
// import "./components/theme-component"

// Configuración del tema
const themeConfig = {
  name: "<%= theme_name %>",
  version: "1.0.0",
  initialize: function() {
    console.log(`Tema ${this.name} inicializado correctamente`);
    // Añade aquí la inicialización de componentes o funcionalidades
  }
};

// Inicializar el tema cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
  themeConfig.initialize();
});

// Exponer la configuración del tema globalmente si es necesario
window["<%= theme_name.camelize %>Theme"] = themeConfig;
