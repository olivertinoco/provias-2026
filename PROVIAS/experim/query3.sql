

alter PROCEDURE [Tramite].[paObtenerDatosTramiteEstudios]
@pIdExpedienteSgd varchar(12)
AS
BEGIN
	;with tmp001_sep(t)as(
	    select*from(values('|'))t(sepCamp)
	)
	select concat(1,
	ltrim(NumeroContratoRemitente), t,
	FgTramiteVirtual, t,
	EstadoAuditoria, t,
	convert(char(19), FechaCreacionAuditoria, 120), t,
	IdUsuarioCreacionAuditoria, t,
	IdExpediente, t,
	ltrim(NombreExpediente))
	from Tramite.Expediente, tmp001_sep
	where IdExpediente = @pIdExpedienteSgd and EstadoAuditoria = 1
end
go

exec [Tramite].[paObtenerDatosTramiteEstudios] 1245
