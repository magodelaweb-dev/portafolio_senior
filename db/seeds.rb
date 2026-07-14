# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

case_studies = [
  {
    title: "Migración de monolito a arquitectura orientada a colas",
    subtitle: "Reducción del 92% en la latencia p95 de facturación",
    github_url: "https://github.com/magodelaweb-dev/portafolio_senior",
    context: <<~MD,
      El servicio de **facturación** de una fintech procesaba los cierres de mes de
      forma **síncrona** dentro del request HTTP. En picos de carga, un cierre podía
      tardar **más de 40 segundos**, provocando *timeouts* del balanceador y reintentos
      duplicados.

      - ~15.000 facturas por cierre
      - Base de datos PostgreSQL única y saturada
      - Sin visibilidad del progreso para el equipo de operaciones
    MD
    problem: <<~MD,
      Necesitaba **desacoplar** el cálculo de facturas del ciclo request/response sin
      introducir un broker externo (Kafka/RabbitMQ) que el equipo no podía operar, y
      manteniendo **garantías de idempotencia** para evitar cargos duplicados.
    MD
    solution: <<~MD,
      1. Modelé cada factura como un **job idempotente** con clave natural
         `(cliente_id, periodo)`.
      2. Introduje una cola respaldada por base de datos (patrón *Solid Queue*),
         evitando infraestructura adicional.
      3. Añadí *backpressure* limitando la concurrencia por *worker* y un
         `unique constraint` que descartaba reintentos duplicados a nivel de BD.

      ```ruby
      class CloseInvoiceJob < ApplicationJob
        queue_as :billing
        # Idempotencia garantizada por índice único (customer_id, period)
        def perform(customer_id:, period:)
          Invoice.close!(customer_id:, period:)
        end
      end
      ```
    MD
    outcome: <<~MD
      - **Latencia p95** del endpoint: de **~40 s → 3,1 s** (-92%).
      - **Cero** cargos duplicados en 6 meses de operación.
      - El equipo de operaciones ganó visibilidad del avance en tiempo real.
      - **Infraestructura sin cambios**: misma base de datos, sin broker externo.
    MD
  },
  {
    title: "Cache de segundo nivel para catálogo de alto tráfico",
    subtitle: "De 850 ms a 45 ms en la home bajo carga de Black Friday",
    github_url: "https://github.com/magodelaweb-dev/portafolio_senior",
    context: <<~MD,
      Un e-commerce renderizaba la portada con **más de 60 consultas** a la base de
      datos por *request*. Durante campañas, la portada concentraba el **70% del
      tráfico** y degradaba todo el sistema.
    MD
    problem: <<~MD,
      Debía reducir drásticamente la carga de lectura **sin sacrificar frescura** del
      catálogo (los precios cambian varias veces al día) y sin desplegar Redis, que
      añadía coste operativo y un punto de fallo adicional.
    MD
    solution: <<~MD,
      - Apliqué **caching por fragmentos** (*russian doll caching*) con claves basadas
        en `updated_at`.
      - Usé un almacén de caché respaldado por base de datos (patrón *Solid Cache*)
        con expiración por tocado de registros (`touch: true`).
      - Añadí *cache warming* tras cada despliegue para evitar el *cold start*.

      > La clave fue invalidar por dependencia de datos, no por tiempo: el contenido se
      > refresca **solo** cuando el registro cambia.
    MD
    outcome: <<~MD
      | Métrica            | Antes   | Después |
      |--------------------|---------|---------|
      | Tiempo de portada  | 850 ms  | 45 ms   |
      | Consultas / request| 60+     | 3       |
      | CPU de BD en pico  | 95%     | 38%     |

      Soportamos **3x** el tráfico del año anterior **sin escalar** la base de datos.
    MD
  }
]

case_studies.each do |attrs|
  Project.find_or_create_by!(title: attrs[:title]) do |project|
    project.assign_attributes(attrs)
  end
end

puts "Seeded #{Project.count} project case studies."
