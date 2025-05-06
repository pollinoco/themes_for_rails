// Componente de ejemplo para el tema <%= theme_name %>
// Este es un componente básico que puedes personalizar o usar como referencia

export default class ThemeComponent {
  constructor(options = {}) {
    this.options = {
      theme: "<%= theme_name %>",
      ...options
    };
    
    this.initialize();
  }
  
  initialize() {
    console.log(`Componente del tema ${this.options.theme} inicializado`);
  }
  
  /**
   * Método de ejemplo para cambiar el tema dinámicamente
   * @param {string} elementSelector - Selector CSS del elemento a modificar
   * @param {string} themeClass - Clase CSS a aplicar
   */
  applyThemeClass(elementSelector, themeClass) {
    const elements = document.querySelectorAll(elementSelector);
    
    if (elements.length > 0) {
      elements.forEach(element => {
        element.classList.add(`<%= theme_name %>-${themeClass}`);
      });
      return true;
    }
    
    return false;
  }
}

// También puedes exportar funciones individuales
export function applyThemeColors() {
  const rootElement = document.documentElement;
  
  // Ejemplo de aplicación de variables CSS para el tema
  rootElement.style.setProperty('--<%= theme_name %>-primary-color', '#1fb6ff');
  rootElement.style.setProperty('--<%= theme_name %>-secondary-color', '#ff49db');
  
  return true;
} 
