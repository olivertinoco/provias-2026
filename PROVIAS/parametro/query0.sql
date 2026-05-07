tramite.paObtenerEstadosExpedientesJefatura
tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad
tramite.paListarExpedientePendienteJefaturaTodosFosCad

tramite.paObtenerEstadosExpedientesEspecialista
tramite.paListarExpedientePendienteEspecialistaV7
tramite.paListarExpedientePendienteEspecialistaCreados
tramite.paListarExpedientePendienteEspecialistaReenviados
tramite.paListarExpedientePendienteEspecialistaArchivados

-- DESCRIPTIVOS DE LOS DE ARRIBA:
-- =============================
-- JEFATURA
9:  tramite.paObtenerEstadosExpedientesJefatura                 -- CARGA EL SITIO WEB DE: EXPEDIENTE / JEFATURA
5:  tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad -- CARGA EL SITIO WEB DE: EXPEDIENTE / JEFATURA
12: tramite.paListarExpedientePendienteJefaturaTodosFosCad      -- BANDEJA TODOS / JEFATURA  (BUG BILLI)


-- ESPECIALISTA
ya 7:  tramite.paObtenerEstadosExpedientesEspecialista             -- CARGA EL SITIO WEB DE: EXPEDIENTE / ESPECIALISTA
ya 8:  tramite.paListarExpedientePendienteEspecialistaV7           -- BANDEJA PENDIENTES / ESPECIALISTA
ya 6:  tramite.paListarExpedientePendienteEspecialistaCreados      -- BANDEJA CREADOS / ESPECIALISTA
ya 10: tramite.paListarExpedientePendienteEspecialistaReenviados   -- BANDEJA DE REENVIADOS / ESPECIALISTA
11: tramite.paListarExpedientePendienteEspecialistaArchivados      -- BANDEJA DE ARCHIVADOS / ESPECIALISTA






-- los que tienen expedite.enlazado:
-- ==================================
5:  tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad *
8:  tramite.paListarExpedientePendienteEspecialistaV7
6:  tramite.paListarExpedientePendienteEspecialistaCreados
10: tramite.paListarExpedientePendienteEspecialistaReenviados
11: tramite.paListarExpedientePendienteEspecialistaArchivados
