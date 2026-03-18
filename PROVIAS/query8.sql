CREATE function Tramite.funEsPrincipalEnlace
(@pIdExpediente INT)
RETURNS bit
AS
BEGIN

	DECLARE @Principal bit =0
	IF Exists(SELECT 1
	FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
	where EE.IdExpediente=@pIdExpediente And EE.EstadoAuditoria=1 )
	BEGIN
		set @Principal=1
	END
	RETURN @Principal

END

--SELECT Tramite.funEsPrincipalEnlace(63)
