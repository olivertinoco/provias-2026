Infraestructura
. Cantidad de servidores físicos y/o virtuales.
. Ambientes involucrados: Producción, QA , Desarrollo, Contingencia/DRP
. Número de CPUs y cores por servidor.
. Memoria RAM y almacenamiento.

Esto es crítico porque SQL Server Enterprise normalmente se licencia por Core.
Sistemas que usarán SQL Enterprise
. Listado de aplicaciones institucionales.
. Criticidad de cada sistema.
. Usuarios concurrentes aproximados.
. Volumen de transacciones.

Funcionalidades
Precisar exactamente que funcionalidades Enterprise necesitan:
Por ejemplo:
. Always On Availability Groups
. Online indexing
. Table partitioning
. Transparent Data Encryption (TDE)
. Data compression
. Failover clustering
. Replicación avanzada
. Resource Governor
. BI/Analytics
. Integración con Power BI / Data Warehouse

Arquitectura propuesta
. Diagrama lógico o arquitectura actual/propuesta.
. Topología: principal, réplica, contingencia, balanceo.
. Flujo de replicación.
. Objetivos RPO/RTO.
. Necesidad de alta disponibilidad 24x7



PRIMER ENTREGABLE DE SEGUNDA ORDEN 2026 (OPTIMIZAR CON IA)
==========================================================

SP: Tramite.paListarExpedientePendienteEspecialistaArchivados
SP: Tramite.paListarExpedientePendienteEspecialistaReenviados
SP: Tramite.paListarExpedientePendienteEspecialistaV7
SP: Tramite.paListarExpedientePendienteJefaturaTodosFosCad
SP: Tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad
SP: Tramite.paListarExpedientePendienteEspecialistaCreados
SP: Tramite.paListarExpedienteMesaParteDespachadosV1
SP: Tramite.paListarExpedienteMesaParteDespachadosVirtualesV1
