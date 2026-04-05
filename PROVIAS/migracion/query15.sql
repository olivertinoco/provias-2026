OBSERVACIONES PARA que se corra antes que el query8

-- exec sys.sp_spaceused 'Tramite.ExpedienteBloqueadoPersonaVisualiza'
-- select*into Tramite.ExpedienteBloqueadoPersonaVisualiza_historico
-- from Tramite.ExpedienteBloqueadoPersonaVisualiza
-- delete Tramite.ExpedienteBloqueadoPersonaVisualiza


-- select*into tramite.ExpedienteBloqueado_historico from tramite.ExpedienteBloqueado

-- delete tramite.ExpedienteBloqueado


select*from tramite.ExpedienteBloqueado_historico
select*from Tramite.ExpedienteBloqueadoHistorialResponsables_historico
select*from Tramite.ExpedienteBloqueadoPersonaVisualiza_historico
