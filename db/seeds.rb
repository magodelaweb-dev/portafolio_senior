# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Order below is display order (most impactful/senior first for recruiters),
# not chronological — see git history / PR discussion for the rationale.
case_studies = [
  {
    title: "Motor de recurrencia y orquestación asíncrona de tareas",
    subtitle: "Buk, 2025 — De encuestas manuales y puntuales a automatización 100% recurrente con un motor de reglas reutilizable en toda la plataforma",
    context: <<~MD,
      En la plataforma SaaS de gestión de RR. HH. de **Buk** (con presencia en múltiples
      países de Latinoamérica y miles de usuarios concurrentes), el módulo de clima
      laboral requería automatizar la recolección continua de *feedback*. Hasta ese
      momento, las encuestas solo podían ejecutarse de forma puntual o manual, lo que
      limitaba la capacidad de las empresas para medir el pulso de sus equipos de forma
      periódica a lo largo del tiempo.
    MD
    problem: <<~MD,
      Como *champion*/líder del proyecto, debía diseñar un **motor de recurrencia**
      desacoplado y reutilizable (capaz de manejar reglas complejas de repetición al
      estilo de Google Calendar) e implementar un sistema de orquestación de
      *background jobs* capaz de activar, reprogramar y procesar encuestas recurrentes
      sin generar inconsistencias de datos ni sobrecargar la infraestructura.
    MD
    solution: <<~MD,
      1. **Abstracción del dominio (motor de recurrencia)**: diseñé un componente
         desacoplado y agnóstico del módulo de encuestas para calcular reglas de
         repetición (`rrule`, frecuencias, intervalos y excepciones), aislando la
         complejidad matemática del calendario y dejando la lógica disponible para
         otros módulos de la plataforma.
      2. **Modelado de datos para respuestas múltiples**: rediseñé el modelo de datos
         para separar la definición/plantilla de la encuesta de sus instancias de
         ejecución, permitiendo que los colaboradores respondan N veces la misma
         encuesta en distintos periodos manteniendo el historial limpio.
      3. **Orquestación asíncrona y ciclo de vida de los jobs**: diseñé el despacho de
         *future tasks* en colas de trabajo en segundo plano para activar las encuestas
         en las fechas y horas exactas programadas, e implementé la gestión de su ciclo
         de vida para que, si un administrador edita o cancela una regla de recurrencia
         en vivo, el sistema cancele, recalcule y reordene dinámicamente las tareas
         futuras.
      4. **Garantía de idempotencia**: implementé controles de concurrencia para
         asegurar que cada instancia de encuesta o notificación masiva se genere
         exactamente una vez por periodo, incluso ante reintentos de la cola de jobs.

      **Compromisos de ingeniería (trade-offs)**

      - *Motor de recurrencia desacoplado vs. solución ad hoc en el módulo*: invertir en
        abstraer la lógica de repetición en un componente agnóstico, en lugar de
        programar fechas fijas dentro de la tabla de encuestas, asumió mayor complejidad
        de diseño inicial a cambio de cero duplicación de código futura y alta
        mantenibilidad.
      - *Programación dinámica de jobs vs. evaluación por lotes (cron diario)*:
        programar e iterar *jobs* asíncronos específicos para cada evento recurrente
        requirió lógica cuidadosa para invalidar y reorquestar tareas cuando el usuario
        edita la configuración, pero evitó *crons* pesados que escanearan cada noche
        toda la base de datos buscando encuestas pendientes.
    MD
    outcome: <<~MD
      | Métrica                  | Estado inicial                          | Tras la implementación                                    |
      |-----------------------------|--------------------------------------------|----------------------------------------------------------------|
      | Capacidad de programación    | 100% manual / ejecuciones puntuales        | 100% automatizado con reglas de recurrencia complejas          |
      | Reutilización de código      | Lógica acoplada a un módulo específico     | Motor de recurrencia centralizado y reutilizable en toda la plataforma |
      | Procesamiento de tareas      | Inexistente para eventos periódicos        | Orquestación asíncrona idempotente con soporte para edición en vivo |

      Se eliminó la carga operativa manual para los equipos de gestión de personas en
      cientos de empresas clientes, habilitando la **medición continua del clima
      laboral** y aumentando el *engagement* con el módulo.
    MD
  },
  {
    title: "Arquitectura IoT, integración FinTech y cumplimiento PCI-DSS",
    subtitle: "Prote Corp · Mi Prote & Mi Body, 2022 — De hardware aislado a dos productos IoT/SaaS en producción con certificación PCI-DSS",
    context: <<~MD,
      **Prote Corp** necesitaba lanzar dos líneas de producto vinculadas a hardware IoT
      en el mercado español: **Mi Prote** (máquinas expendedoras inteligentes de batidos
      de proteína controladas por app Android) y **Mi Body** (balanzas antropométricas
      que envían parámetros físicos en tiempo real para generar diagnósticos y planes
      nutricionales por suscripción).

      - Hardware físico heterogéneo **sin conexión a una arquitectura cloud**.
      - Necesidad de procesar cobros recurrentes e integrar pasarelas bancarias
        tradicionales (Redsys / Banco Santander) bajo los estrictos estándares de
        seguridad y auditoría de **PCI-DSS**.
    MD
    problem: <<~MD,
      Como líder *fullstack*, debía diseñar la arquitectura centralizada (API REST y
      backend), liderar los equipos de Android, IoT, web y diseño, coordinar la
      comunicación segura hardware-servidor, integrar pasarelas de pago y facturación
      (Redsys, Stripe, Nayax, Holded) y **garantizar el cumplimiento normativo** para
      obtener la licencia PCI-DSS.
    MD
    solution: <<~MD,
      1. **API REST y autenticación**: diseñé y desplegué sobre AWS EC2 (Linux) un
         backend monolítico modular en PHP Laravel con **Laravel Passport (OAuth2)**,
         exponiendo endpoints seguros e higienizados para los clientes web, las apps
         Android y el hardware IoT.
      2. **Integración FinTech y compliance PCI-DSS**: integré **Redsys** (Banco
         Santander) para cobros recurrentes de suscripciones y **Stripe** para pagos
         digitales, con tokenización de tarjetas para que los datos sensibles nunca
         tocaran ni se almacenaran en los servidores propios, reduciendo el alcance de
         auditoría y logrando la certificación PCI-DSS.
      3. **Integración de hardware e IoT**: sincronicé con los equipos de Android e IoT
         los protocolos REST para la lectura de sensores (balanzas Mi Body), el
         despacho de insumos (expendedoras Mi Prote) y la integración con terminales de
         pago físico **Nayax**.
      4. **Automatización operativa**: conecté la plataforma con **Holded** para
         facturación electrónica automática y **SendGrid** para notificaciones
         transaccionales y de marketing.

      **Compromisos de ingeniería (trade-offs)**

      - *Tokenización externa (Redsys/Stripe) vs. checkout nativo*: delegar la captura
        de datos de tarjeta a los formularios/iFrames tokenizados de Redsys y Stripe, en
        lugar de un formulario propio, cedió control sobre el estilo visual del
        checkout a cambio de reducir el alcance auditado de PCI-DSS (de **SAQ D** a un
        **SAQ A** mucho más manejable) y mitigar la responsabilidad legal por fuga de
        datos financieros.
      - *Backend centralizado con Passport vs. microservicios*: concentrar la lógica de
        Mi Prote y Mi Body en un único backend Laravel desacoplado por API con OAuth2
        aceptó un acoplamiento moderado entre ambos productos en el mismo repositorio y
        base de datos, a cambio de agilizar el *time-to-market* y reducir la
        complejidad operativa para un equipo técnico mediano.
    MD
    outcome: <<~MD
      | Métrica                | Estado inicial                | Tras la implementación                          |
      |--------------------------|--------------------------------|--------------------------------------------------|
      | Líneas de producto        | Prototipos / hardware aislado  | 2 productos IoT/SaaS en producción (Mi Prote y Mi Body) |
      | Seguridad de pagos        | Sin pasarela regulada          | Certificación PCI-DSS aprobada, integrado con Banco Santander |
      | Procesamiento de pagos    | 0% automatizado                | Cobros y suscripciones 100% automatizados (Redsys + Stripe + Nayax) |
      | Ecosistema de datos       | Hardware sin conexión cloud    | Sincronización en tiempo real entre IoT, app Android, web y panel admin |

      Se logró la **acreditación legal y técnica** para operar comercialmente en
      España, permitiendo monetizar tanto la venta directa de insumos en máquinas
      físicas como el modelo SaaS de suscripciones nutricionales.
    MD
  },
  {
    title: "Recuperación ante desastres y reconstrucción de infraestructura en AWS",
    subtitle: "Goapp Perú SAC · Disgo, 2018 — De pérdida total de infraestructura a 95% de datos operativos recuperados mediante parsing de logs y backups multi-cloud",
    context: <<~MD,
      En **Goapp Perú SAC**, empresa dueña del producto **Disgo**, y tras la vacante del
      puesto de CTO, un escalamiento mal ejecutado por un consultor externo eliminó
      accidentalmente **toda la infraestructura de la empresa en AWS**: instancias EC2
      (Windows Server, MongoDB), RDS (SQL Server) y buckets S3.

      - Sistema **totalmente inaccesible** para clientes y operación.
      - **Sin snapshots utilizables** para restauración directa desde la consola de AWS.
      - Riesgo real de pérdida irreparable de datos operativos de clientes.
    MD
    problem: <<~MD,
      Debía diseñar e implementar un plan de recuperación de emergencia para
      **reconstruir la infraestructura desde cero** y **recuperar la integridad de la
      información operativa** de los clientes, sin interrumpir la continuidad del
      negocio ni generar pérdida irreparable de datos.
    MD
    solution: <<~MD,
      1. **Parsing de logs multi-fuente**: diseñé scripts en JavaScript para procesar en
         *streaming* (por bloques de memoria) los logs de Apache y de la aplicación,
         identificando patrones con **expresiones regulares** para reconstruir las
         mutaciones de datos y consultas ejecutadas hacia SQL Server y MongoDB.
      2. **Estandarización e ingesta**: transformé los logs procesados en archivos CSV
         estructurados y ejecuté scripts automatizados de migración para reingresar
         masivamente la información reconstruida en las bases de datos.
      3. **Reaprovisionamiento de arquitectura**: reconstruí la topología de red y
         servidores en AWS (RDS SQL Server, EC2 con MongoDB y S3) bajo configuraciones
         seguras.
      4. **Backup cross-cloud**: diseñé un pipeline *serverless* con AWS Lambda que
         generaba *dumps* periódicos hacia S3 y los replicaba de forma asíncrona en
         Google Drive corporativo, eliminando el riesgo de punto único de fallo (SPOF)
         a nivel de proveedor cloud.

      **Compromisos de ingeniería (trade-offs)**

      - *Procesamiento en stream vs. uso de memoria RAM*: procesar los logs por bloques
        de texto mediante *streams* en JS, en lugar de cargar archivos completos en
        memoria, a cambio de mayor tiempo de procesamiento y más complejidad en los
        *scripts* Regex, evitó cierres por *Out Of Memory* (OOM) en archivos de log de
        varios gigabytes.
      - *Redundancia multi-cloud vs. costo operativo*: replicar backups fuera de AWS
        hacia Google Drive mediante Lambda introdujo una dependencia externa adicional
        (API de Google Drive) y lógica de autenticación OAuth, a cambio de garantizar
        la supervivencia de los datos ante eventos catastróficos o pérdida de acceso al
        *tenant* de AWS.
    MD
    outcome: <<~MD
      | Métrica                  | Antes del incidente          | Tras la recuperación                |
      |---------------------------|-------------------------------|--------------------------------------|
      | Estado del sistema         | Pérdida total (0% disponibilidad) | 100% operativo                  |
      | Datos críticos recuperados | 0% (sin backups directos)     | 95% de los datos esenciales         |
      | Estrategia de respaldos    | Inexistente (vulnerable a borrado total) | Automática y multi-cloud (AWS + Google Drive) |

      Se reanudó la operación completa **sin impacto directo percibido por los usuarios
      finales**. La resolución del incidente y la estrategia defensiva implementada me
      otorgaron la confianza de la directiva para asumir la posición vacante de **CTO**.
    MD
  },
  {
    title: "Modernización legacy, versionado de datos y despliegue cloud en tiempo récord",
    subtitle: "Agrocredit Corporation SAC · AgroInvesting, 2020 — De un archivo ZIP desorganizado a una plataforma de inversión agrícola en producción en 48 horas y monetizando en 5 meses",
    context: <<~MD,
      El proyecto de **AgroInvesting** — plataforma de inversión y financiamiento para
      una agricultura climáticamente inteligente, de **Agrocredit Corporation SAC** —
      existía únicamente como un archivo comprimido ZIP con código Laravel 5.6
      incompleto y *dumps* de MySQL desestructurados.

      - **Sin repositorios Git**, documentación ni control de cambios.
      - **Sin infraestructura en la nube**.
      - Varios formularios críticos no funcionaban.
      - Ausencia de entornos de QA y producción, lo que impedía la continuidad del
        desarrollo y la salida al mercado.
    MD
    problem: <<~MD,
      Debía estructurar el control de versiones, realizar **ingeniería inversa** sobre la
      base de datos para versionarla mediante código, provisionar la infraestructura
      cloud en AWS, corregir y completar el *core* del sistema (módulos de *crowdfunding*
      y firma electrónica) y **lanzar la primera versión a producción en el menor tiempo
      posible**.
    MD
    solution: <<~MD,
      1. **Control de versiones y ambientes**: inicialicé el control de versiones en
         Bitbucket (Git), aislando las ramas de desarrollo y producción para garantizar
         la trazabilidad de los cambios.
      2. **Versionado de base de datos (reverse engineering)**: transformé los archivos
         `.sql` en un esquema de **migraciones de Laravel** estructurado en orden lógico
         estricto (tablas maestras → tablas intermedias → *seeds* de datos iniciales),
         garantizando despliegues automatizados y repetibles.
      3. **Infraestructura cloud en AWS**: provisioné una arquitectura liviana con AWS
         EC2 (Linux) para el servidor de aplicaciones y MySQL, AWS S3 para el
         almacenamiento seguro de documentos subidos por los usuarios, y AWS Route53
         para la administración de DNS.
      4. **Desarrollo del core FinTech**: reparé los flujos de datos defectuosos y
         completé la lógica de negocio para *crowdfunding*, conceptos financieros y el
         flujo de firma electrónica de documentos.
      5. **Documentación técnica**: creé manuales de implementación y despliegue para
         garantizar la mantenibilidad y escalabilidad del proyecto.

      **Compromisos de ingeniería (trade-offs)**

      - *Instancia única (EC2 + MySQL) vs. RDS separado*: alojar la aplicación Laravel y
        la base de datos MySQL dentro de la misma instancia EC2 durante la fase inicial
        sacrificó la alta disponibilidad y el aislamiento de recursos de un RDS
        dedicado, a cambio de reducir costos operativos drásticamente e implementar la
        primera versión en producción en solo 48 horas.
      - *Recreación manual de migraciones vs. herramientas automatizadas*: escribir
        manualmente cada archivo de migración en Laravel inspeccionando las tablas del
        *dump* SQL requirió un trabajo inicial intensivo y tedioso, pero garantizó el
        control absoluto sobre los tipos de datos, restricciones de llaves foráneas y el
        orden exacto de ejecución para evitar inconsistencias en el *seeding*.
    MD
    outcome: <<~MD
      | Métrica                | Antes (estado legacy)         | Tras la intervención                        |
      |--------------------------|--------------------------------|-----------------------------------------------|
      | Tiempo de despliegue      | Sin infraestructura            | 2 días a la primera versión en producción     |
      | Control de código y BD    | 0% (archivos ZIP y dumps SQL)  | 100% versionado (Git + migraciones Laravel)   |
      | Tiempo a monetización     | Inoperativo                    | 5 meses (producto completo y generando ingresos) |

      Se transformó un prototipo abandonado e inestable en un **producto SaaS
      funcional, seguro y rentable** en el mercado de inversiones agrícolas.
    MD
  }
]

# The seed file is the source of truth for case-study content: existing
# records (matched by title) are updated in place, so content edits here
# propagate to already-seeded databases on the next db:seed run.
case_studies.each_with_index do |attrs, index|
  Project.find_or_initialize_by(title: attrs[:title])
         .update!(attrs.merge(position: index))
end

puts "Seeded #{Project.count} project case studies."

# Admin user for the protected write actions (projects CRUD, /ops/enqueue).
# Credentials are read from Rails.application.credentials.admin with an ENV
# fallback, so no secret is committed to the repository.
admin_email = Rails.application.credentials.dig(:admin, :email_address) || ENV["ADMIN_EMAIL"]
admin_password = Rails.application.credentials.dig(:admin, :password) || ENV["ADMIN_PASSWORD"]

if admin_email.present? && admin_password.present?
  User.find_or_create_by!(email_address: admin_email) do |user|
    user.password = admin_password
  end
  puts "Ensured admin user #{admin_email} exists."
else
  puts "Skipped admin user seed: set credentials admin.email_address/admin.password or ADMIN_EMAIL/ADMIN_PASSWORD."
end
