CREATE function Tramite.funObtenerExpedientesEnlazados
(@pIdExpediente INT)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @Lista  varchar(max)=''
	SELECT @Lista='<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
		e.NombreExpediente
		+'</div> '+ @Lista
	FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
		INNER JOIN Tramite.Expediente e  WITH (NOLOCK) ON EE.IdExpedienteSecundario=E.IdExpediente AND E.EstadoAuditoria=1 AND E.ExpedienteAnulado=0 AND EE.EstadoAuditoria=1
	where EE.IdExpediente=@pIdExpediente

	if @Lista=''
	BEGIN
		SELECT @Lista='<div style="margin: 2px;padding: 2px;" class="ui blue label">'+
			e.NombreExpediente
			+'</div> '+ @Lista
		FROM Tramite.ExpedienteEnlazado EE  WITH (NOLOCK)
			INNER JOIN Tramite.Expediente e WITH (NOLOCK) ON EE.IdExpediente=E.IdExpediente AND E.EstadoAuditoria=1 AND E.ExpedienteAnulado=0 AND EE.EstadoAuditoria=1
		WHERE EE.IdExpedienteSecundario=@pIdExpediente
	END
	--
	RETURN @Lista
END


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



CREATE function [Seguridad].[funObtenerRutaFotoPorIdPersona]
(@pIdPersona INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @Lista  varchar(50)='sinfotoH.jpg'
	SELECT @Lista=case when COALESCE(U.RutaArchivoFoto,'') ='' then
	CASE WHEN COALESCE(Pr.Sexo,0)=0 then 'sinfotoH.jpg' else 'sinfotoM.jpg' end else U.RutaArchivoFoto end
	FROM Seguridad.Usuario U
	INNER JOIN General.Persona PR ON PR.IdPersona=U.IdPersona
	WHERE U.EstadoAuditoria=1 and pr.IdPersona=@pIdPersona AND U.Bloqueado=0
	RETURN @Lista

END
