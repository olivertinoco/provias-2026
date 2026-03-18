CREATE function Tramite.funObtenerExpedientesEnlazados
(@pIdExpediente INT)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @Lista  varchar(max)=''
	SELECT @Lista=
	    '<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
		e.NombreExpediente
		+'</div> '+ @Lista
	FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
		INNER JOIN Tramite.Expediente e  WITH (NOLOCK) ON EE.IdExpedienteSecundario=E.IdExpediente AND E.EstadoAuditoria=1
		AND E.ExpedienteAnulado=0 AND EE.EstadoAuditoria=1
	where EE.IdExpediente=@pIdExpediente

	if @Lista=''
	BEGIN
		SELECT @Lista='<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
			e.NombreExpediente
			+'</div> '+ @Lista
		FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
			INNER JOIN Tramite.Expediente e WITH (NOLOCK) ON EE.IdExpediente=E.IdExpediente AND E.EstadoAuditoria=1
			AND E.ExpedienteAnulado=0 AND EE.EstadoAuditoria=1
		WHERE EE.IdExpedienteSecundario=@pIdExpediente
	END
	--
	RETURN @Lista
END

--SELECT [Tramite].[funObtenerExpedientesEnlazados](32)
