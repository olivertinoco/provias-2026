alter PROCEDURE [Tramite].[paObtenerConfirmacionExpedienteDocumentoBloqueadoYPersonaVisualiza_arq]
    @pIdExpedienteDocumento int,
    @pIdUsuarioAuditoria int,
    @pIdPeriodo int
as
begin
begin try
set nocount on
set tran isolation level read uncommitted

select
    @pIdExpedienteDocumento= 311858,
    @pIdUsuarioAuditoria= 389,
    @pIdPeriodo= 2023

    declare @vAnno int = year(getdate()), @vExpediente varchar(50)='', @vSql Nvarchar(max)
    if(@pIdPeriodo != @vAnno) select @vExpediente = concat('_historico_',@pIdPeriodo)

    select @vSql = N'
	select concat(isnull(case when EB.FechaHoraBloquea is null then 0 else case when EB.FechaHoraBloquea<=ED.FechaCreacionAuditoria then 1 else 0 end end, 0),''|'',isnull(EB1.PersonaVisualiza,0))
	from Tramite.ExpedienteDocumento'+ @vExpediente +N' ED
	OUTER APPLY(
		select EB.IdExpedienteBloqueado,EB.FechaHoraBloquea
		from Tramite.ExpedienteBloqueado EB where ED.IdExpediente=EB.IdExpediente and EB.EstadoAuditoria=1 and EB.EstadoBloqueo=1
	)EB
	OUTER APPLY(
		select 1 PersonaVisualiza
		from Tramite.ExpedienteBloqueadoPersonaVisualiza EBPV
		inner join Seguridad.Usuario U on EBPV.IdPersonaVisualiza=U.IdPersona and U.IdUsuario=@pIdUsuarioAuditoria where EB.IdExpedienteBloqueado=EBPV.IdExpedienteBloqueado and EBPV.EstadoAuditoria=1
	)EB1
	where ED.IdExpedienteDocumento=@pIdExpedienteDocumento'

	exec sp_executesql @vSql,
	N'@pIdExpedienteDocumento int, @pIdUsuarioAuditoria int',
	@pIdExpedienteDocumento = @pIdExpedienteDocumento,
	@pIdUsuarioAuditoria = @pIdUsuarioAuditoria

END TRY
BEGIN CATCH
		DECLARE @ERROR_NUMBER INT
		DECLARE @ERROR_SEVERITY INT
		DECLARE @ERROR_STATE INT
		DECLARE @ERROR_PROCEDURE VARCHAR(MAX)
		DECLARE @ERROR_LINE INT
		DECLARE @ERROR_MESSAGE VARCHAR(MAX)
		SELECT @ERROR_NUMBER=ERROR_NUMBER() , @ERROR_SEVERITY=ERROR_SEVERITY() , @ERROR_STATE=ERROR_STATE(),
		@ERROR_PROCEDURE='Tramite.paObtenerConfirmacionExpedienteDocumentoBloqueadoYPersonaVisualiza_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
		EXEC Seguridad.paGuardarErroresEnLog @ERROR_NUMBER , @ERROR_SEVERITY , @ERROR_STATE ,  @ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE
END CATCH
END
GO



EXECUTE Tramite.paObtenerConfirmacionExpedienteDocumentoBloqueadoYPersonaVisualiza_arq 311858,389, 2023
EXECUTE Tramite.paObtenerConfirmacionExpedienteDocumentoBloqueadoYPersonaVisualiza 311858,389
