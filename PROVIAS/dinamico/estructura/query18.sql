ALTER PROCEDURE [Tramite].[paObtenerConfirmacionExpedienteDocumentoBloqueadoYPersonaVisualiza]
    @pIdExpedienteDocumento int,
    @pIdUsuarioAuditoria int,
    @pIdPeriodo int
as
begin
	select isnull(case when EB.FechaHoraBloquea is null then  '0' else
	case when EB.FechaHoraBloquea<=ED.FechaCreacionAuditoria then '1' else '0' end end,'0')+'|'+isnull(EB1.PersonaVisualiza,'0')
	from Tramite.ExpedienteDocumento ED
	OUTER APPLY(
		select EB.IdExpedienteBloqueado,EB.FechaHoraBloquea
		from Tramite.ExpedienteBloqueado EB
		where ED.IdExpediente=EB.IdExpediente and EB.EstadoAuditoria=1 and EB.EstadoBloqueo=1
	)EB
	OUTER APPLY(
		select '1' PersonaVisualiza
		from Tramite.ExpedienteBloqueadoPersonaVisualiza EBPV
		inner join Seguridad.Usuario U on EBPV.IdPersonaVisualiza=U.IdPersona and U.IdUsuario=@pIdUsuarioAuditoria
		where EB.IdExpedienteBloqueado=EBPV.IdExpedienteBloqueado and EBPV.EstadoAuditoria=1
	)EB1
	where ED.IdExpedienteDocumento=@pIdExpedienteDocumento AND ED.IdPeriodo = @pIdPeriodo
end
