# Portafolio de Ingeniería de Software & Laboratorio de Observabilidad 🚀

Este repositorio contiene mi portafolio profesional y un panel de observabilidad en tiempo real. Está diseñado bajo un **enfoque híbrido** para demostrar diseño de sistemas, monitoreo de procesos en producción, automatización y buenas prácticas de ingeniería de software.

---

## 🏛️ Perspectiva de Arquitectura

En lugar de optar por una infraestructura compleja y costosa de mantener, este proyecto está diseñado como un **Monolito Pragmático y Eficiente**, optimizado para ejecutarse con recursos mínimos sin comprometer el rendimiento.

### 1. SQLite3 en Producción (WAL Mode)
Para eliminar los costos de un motor de base de datos relacional externo, la persistencia de datos utiliza SQLite3.
* **WAL (Write-Ahead Logging):** Permite lecturas y escrituras concurrentes sin bloquear la base de datos.

### 2. Solid Queue, Solid Cache & Solid Cable
Evitamos la dependencia y el consumo de memoria de servicios como Redis aprovechando las herramientas nativas de Rails 8. Las tres corren sobre SQLite, cada una en su propia base de datos física (`storage/{queue,cache,cable}.sqlite3`, ver `config/database.yml`):
* **Solid Queue:** Gestión de tareas en segundo plano (jobs) persistidas directamente en SQLite.
* **Solid Cache:** Almacenamiento de caché en la base de datos.
* **Solid Cable:** Adaptador de Action Cable (WebSockets / tiempo real) sobre SQLite. Está configurado y operativo, pero el proyecto aún no define canales propios en `app/channels`, por lo que hoy no tiene un uso visible más allá de estar disponible como infraestructura.

---

## ⚡ Características Principales

*   **Estudios de Caso (Metodología STAR):** Desglose detallado de mis proyectos más complejos organizados por *Situación, Tarea, Acción y Resultado*, enfocados en impacto técnico y métricas de negocio.
*   **Panel de Observabilidad (`/ops` o `/monitoreo`):** Una sección interactiva que muestra el consumo de memoria del proceso de Ruby, tiempos de respuesta promedio del servidor y el estado de las tareas en segundo plano.

---

## 📊 Panel de Observabilidad (`/ops`)

Vista en vivo del propio proceso que sirve la app (no de datos de negocio). Se refresca sola vía polling (`app/javascript/controllers/poll_controller.js`) contra `OpsController#metrics`. La construye `Ops::MetricsCollector` (`app/services/ops/metrics_collector.rb`).

### Aplicación
Identidad y signos vitales del proceso: versión de Rails/Ruby, entorno, **PID** y uptime.

* **PID:** es el proceso de **Puma** (`config/puma.rb`), el único servidor de aplicación del proyecto — no hay otro servicio corriendo. Con la configuración por defecto (`WEB_CONCURRENCY` sin definir) Puma levanta **1 solo worker**, así que este PID es estable entre refrescos. Si se sube `WEB_CONCURRENCY` en un deploy, habrá varios procesos Puma y el PID mostrado será el del worker que atendió esa petición puntual.
  * Verificar en terminal: `pgrep -fal puma` (o `ps aux | grep puma`).
* **Uptime:** tiempo desde el último arranque del proceso. Un uptime bajo e inesperado es señal de que algo reinició la app (crash, deploy, OOM).

### Métricas de Peticiones HTTP
Telemetría en memoria (`Telemetry`, `app/models/telemetry.rb`): un buffer de anillo de las últimas 200 peticiones, alimentado por un subscriber a `process_action.action_controller` (`config/initializers/telemetry.rb`). Es por-proceso y se pierde al reiniciar — intencional, es una foto del presente, no un histórico.

* **Media / p95 / Máx:** tiempos de respuesta en ms. El **p95** es el más representativo: indica que el 95% de las peticiones fueron más rápidas que ese valor, sin que lo distorsionen las peticiones rápidas como sí le pasa al promedio.
* **BD (Promedio):** cuánto de ese tiempo total se fue en consultas a base de datos — ayuda a distinguir cuello de botella en DB vs. en lógica de la app.
* Tabla inferior: detalle petición a petición (endpoint, status, duración, tiempo de BD).

### Bases de datos SQLite
Tamaño en disco de cada base física (`primary`, `cache`, `queue`, `cable`). Sirve como alerta temprana de crecimiento descontrolado.

### Solid Queue
Estado de la cola de jobs en segundo plano: listos, programados, en curso, fallidos, finalizados y procesos worker activos, más el detalle de los últimos jobs encolados. Si la sección muestra "no disponible", es porque el proceso worker no está corriendo en ese entorno (ver `bin/jobs`, `Procfile.dev`).

### Solid Cache
Cantidad de entradas actualmente en caché. Es un indicador de actividad, no de rendimiento — no dice si la caché está siendo efectiva, solo cuánto se está usando. En un entorno con poco tráfico de caché este número puede ser bajo (0-2) y la sección pasar desapercibida frente al bloque de Solid Queue, que suele tener más contenido visual (tabla de jobs recientes).

---

## 💻 Configuración del Entorno Local

### Requisitos previos
* **Ruby 3.4.10** (versión fijada en `.ruby-version`). Instálala con un gestor de versiones como [rbenv](https://github.com/rbenv/rbenv), [asdf](https://asdf-vm.com/) o [mise](https://mise.jdx.dev/).
* **SQLite3** (`>= 2.1` vía el gem `sqlite3`). En la mayoría de sistemas ya viene instalado; si no, ver [sqlite.org/download.html](https://sqlite.org/download.html).
* **Git**. Ver [git-scm.com/downloads](https://git-scm.com/downloads).

Este README no cubre la instalación de estas herramientas base en un sistema sin aprovisionar — para eso, la documentación oficial de cada una (enlazada arriba) está más actualizada que cualquier copia que podamos mantener aquí.

### Instalación rápida
Con Ruby, SQLite3 y Git ya instalados, clona el repositorio y ejecuta:

```bash
git clone <url-del-repositorio>
cd portafolio_senior
bin/setup
```

`bin/setup` es idempotente y hace todo el trabajo: instala las gemas (`bundle install`), prepara las 4 bases SQLite —`primary`, `cache`, `queue`, `cable`— (`bin/rails db:prepare`), limpia logs/tmp, y finalmente levanta el servidor (`bin/dev`, que corre Puma + Tailwind watch + Solid Queue vía `Procfile.dev`).

Al terminar, la app queda disponible en `http://localhost:3000`.

Variantes:
* `bin/setup --skip-server` — hace todo lo anterior sin arrancar el servidor al final (útil en CI o si prefieres arrancarlo tú mismo con `bin/dev`).
* `bin/setup --reset` — además, resetea la base de datos (`bin/rails db:reset`) en vez de solo prepararla.

No hace falta ningún paso de compilación de JS/CSS aparte: no hay `package.json` (el JS se sirve vía importmap, sin bundler) y Tailwind se compila automáticamente en `bin/dev`.
