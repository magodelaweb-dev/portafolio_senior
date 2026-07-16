# Portafolio de Ingeniería de Software & Laboratorio de Observabilidad 🚀

Este repositorio contiene mi portafolio profesional y un panel de observabilidad en tiempo real. Está diseñado bajo un **enfoque híbrido** para demostrar diseño de sistemas, monitoreo de procesos en producción, automatización y buenas prácticas de ingeniería de software.

---

## 🏛️ Perspectiva de Arquitectura

En lugar de optar por una infraestructura compleja y costosa de mantener, este proyecto está diseñado como un **Monolito Pragmático y Eficiente**, optimizado para ejecutarse con recursos mínimos sin comprometer el rendimiento.

### 1. SQLite3 en Producción (WAL Mode)
Para eliminar los costos de un motor de base de datos relacional externo, la persistencia de datos utiliza SQLite3.
* **WAL (Write-Ahead Logging):** Permite lecturas y escrituras concurrentes sin bloquear la base de datos.

### 2. Solid Queue & Solid Cache
Evitamos la dependencia y el consumo de memoria de servicios como Redis aprovechando las herramientas nativas de Rails 8:
* **Solid Queue:** Gestión de tareas en segundo plano persistidas directamente en SQLite.
* **Solid Cache:** Almacenamiento de caché en la base de datos.

---

## ⚡ Características Principales

*   **Estudios de Caso (Metodología STAR):** Desglose detallado de mis proyectos más complejos organizados por *Situación, Tarea, Acción y Resultado*, enfocados en impacto técnico y métricas de negocio.
*   **Panel de Observabilidad (`/ops` o `/monitoreo`):** Una sección interactiva que muestra el consumo de memoria del proceso de Ruby, tiempos de respuesta promedio del servidor y el estado de las tareas en segundo plano.

---

## 💻 Configuración del Entorno Local

### Instalación rápida
1. Clonar el repositorio...
