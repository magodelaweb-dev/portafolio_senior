# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Order below is display order (most impactful/senior first for recruiters),
# not chronological — see git history / PR discussion for the rationale.
case_studies = [
  {
    title: "Refactorización de un dominio core y gobernanza de arquitectura en SaaS",
    subtitle: "Buk, 2025 — De un componente transversal acoplado a supuestos implícitos a soporte nativo de ex-colaboradores, sin afectar a los módulos dependientes",
    context: <<~MD,
      En la plataforma SaaS de gestión de RR. HH. de **Buk**, el modelo de datos de
      **Colaborador** era un bloque transversal reutilizado a lo largo del producto. El
      *building block* de participantes construido sobre él daba servicio a los módulos
      de **encuestas, talento y selección**, y asumía implícitamente que todo usuario
      registrado era un colaborador **activo**.

      Al requerir, desde el módulo de **cultura**, el lanzamiento de encuestas para
      ex-colaboradores (procesos de *offboarding* y encuestas de salida), el sistema no
      permitía cargar ni consultar usuarios desvinculados sin alterar el comportamiento
      de los módulos que ya dependían de ese componente.
    MD
    problem: <<~MD,
      Como *champion*/líder de la misión, debía conducirla de extremo a extremo —
      *discovery* técnico, planificación del *delivery* y desarrollo— para soportar la
      entidad de **ex-colaboradores desvinculados**, garantizando cero tiempo de
      inactividad, **retrocompatibilidad** con todos los módulos dependientes y la
      aprobación técnica del equipo central de Plataforma.
    MD
    solution: <<~MD,
      1. **Discovery técnico y análisis de impacto**: abrí la misión con un documento de
         diseño que evaluaba alternativas de solución, el modelo de datos, los riesgos y
         el plan de despliegue. Sobre esa base audité el código para identificar todos
         los acoplamientos y las consultas directas a la entidad Colaborador a lo largo
         de los distintos submódulos, antes de tocar una sola línea de la interfaz
         compartida.
      2. **Refactorización defensiva y retrocompatibilidad**: rediseñé los *building
         blocks* internos del componente —interfaces de Rails que combinan ERB, *cells*,
         JavaScript y widgets Vue— abstrayendo la consulta del estado
         (activo/desvinculado) mediante *scopes* y filtros configurables, de modo que las
         llamadas existentes conservaran su comportamiento previo sin cambios. El grueso
         del trabajo fue de backend; los ajustes de interfaz fueron puntuales.
      3. **Gobernanza y estrategia de pull requests**: traduje el diseño a tarjetas
         acotadas, con criterios de aceptación y plan de pruebas propios, y fragmenté la
         refactorización en cambios atómicos y revisables. Coordiné las revisiones de
         arquitectura con el equipo de Plataforma para cumplir los estándares de
         rendimiento y seguridad de la base de código principal, y con los equipos de UX,
         UI y *design system* cada vez que un cambio modificaba componentes de interfaz
         existentes.
      4. **Plan de pruebas y QA exhaustivo**: asumí la calidad de la misión de punta a
         punta, definiendo una matriz de pruebas de regresión y automatizando pruebas
         unitarias y de integración para certificar que los flujos de talento y selección
         y los permisos de usuarios activos no sufrieran alteración alguna.

      **Compromisos de ingeniería (trade-offs)**

      - *Refactorización incremental vs. reescritura del componente desde cero*:
        mantener la estructura base de la entidad Colaborador y extenderla mediante
        filtros y *scopes*, en lugar de crear una tabla o un servicio separado para
        ex-colaboradores, asumió una carga de pruebas de retrocompatibilidad mucho
        mayor, a cambio de preservar la integridad referencial histórica y evitar la
        duplicación de los datos de usuario.
      - *QA exhaustivo vs. velocidad de despliegue*: invertir en revisión atómica de
        *pull requests* con el equipo de Plataforma, en aprobaciones de UX/UI/*design
        system* para los ajustes de interfaz y en pruebas de regresión cruzadas extendió
        el *time-to-market* de la funcionalidad, a cambio de reducir al mínimo el riesgo
        de caídas o inconsistencias en los módulos que ya consumían el componente.
    MD
    outcome: <<~MD
      | Métrica                  | Estado inicial                          | Tras la refactorización                                   |
      |-----------------------------|--------------------------------------------|----------------------------------------------------------------|
      | Soporte de entidades         | Exclusivo para colaboradores activos       | Soporte nativo para ex-colaboradores en encuestas de salida    |
      | Retrocompatibilidad          | Riesgo alto por impacto transversal        | Módulos dependientes (talento, selección) sin cambios en su comportamiento |
      | Gobernanza técnica           | Código acoplado a supuestos implícitos     | Cambios revisados y aprobados por el equipo de Plataforma      |

      Se habilitó el módulo de encuestas a ex-colaboradores (*offboarding*), abriendo
      una nueva línea de **métricas de retención de talento** para las empresas
      clientes, y su uso creció tras la habilitación.
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

# Being the source of truth also means removals propagate: a case study that
# is renamed or dropped here would otherwise survive in already-seeded
# databases as an orphan record, still publicly listed.
removed = Project.where.not(title: case_studies.map { |attrs| attrs[:title] }).destroy_all
puts "Removed #{removed.size} case studies no longer defined in the seed file." if removed.any?

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
