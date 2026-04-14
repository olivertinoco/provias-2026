-- CREATE function Tramite.funObtenerExpedientesEnlazados
-- (
declare
@pIdExpediente INT)
-- RETURNS VARCHAR(MAX)
-- AS
-- BEGIN

	DECLARE @Lista  varchar(max)=''
	SELECT @Lista='<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
		e.NombreExpediente
		+'</div> '+ @Lista
	FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
		INNER JOIN Tramite.Expediente e  WITH (NOLOCK)
		    ON EE.IdExpedienteSecundario=E.IdExpediente AND E.EstadoAuditoria=1 AND E.ExpedienteAnulado=0 AND EE.EstadoAuditoria=1
	where EE.IdExpediente=@pIdExpediente

	if @Lista=''
	BEGIN
		SELECT @Lista='<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
			e.NombreExpediente
			+'</div> '+ @Lista
		FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
			INNER JOIN Tramite.Expediente e WITH (NOLOCK)
			    ON EE.IdExpediente=E.IdExpediente AND E.EstadoAuditoria=1 AND E.ExpedienteAnulado=0 AND EE.EstadoAuditoria=1
		WHERE EE.IdExpedienteSecundario=@pIdExpediente
	END
	--
	RETURN @Lista
-- END




-- CREATE function Tramite.funEsPrincipalEnlace
-- (
declare
@pIdExpediente INT)
-- RETURNS bit
-- AS
-- BEGIN

	DECLARE @Principal bit =0
	IF Exists(SELECT 1
	FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
	where EE.IdExpediente=@pIdExpediente And EE.EstadoAuditoria=1 )
	BEGIN
		set @Principal=1
	END
	RETURN @Principal

-- END
