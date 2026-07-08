CREATE function [Tramite].[funMostrarDesatinatarios]
(@pIdExpedienteDocumentoOrigen INT)
RETURNS VARCHAR(MAX)
AS
BEGIN

	DECLARE @Lista  varchar(max)=''

	SELECT
	@Lista=COALESCE(EDOD.DestinatarioDestino,COALESCE(P.NombreCompleto,'')+' '+COALESCE(EM.NombreEmpresa,'EXTERNO')+' '+COALESCE(A.NombreArea,'')+' ' +COALESCE(C.NombreCargo,''))+', '+@Lista
	FROM Tramite.ExpedienteDocumentoOrigenDestino EDOD WITH (NOLOCK)
	LEFT JOIN General.Cargo C ON C.IdCargo=EDOD.IdCargoDestino
	LEFT JOIN General.Area A ON A.IdArea=EDOD.IdAreaDestino
	LEFT JOIN General.Empresa EM ON EM.IdEmpresa=EDOD.IdEmpresaDestino
	LEFT JOIN General.Persona P ON P.IdPersona=EDOD.IdPersonaDestino
	WHERE EDOD.IdExpedienteDocumentoOrigen=@pIdExpedienteDocumentoOrigen AND EsInicial<>0 and EDOD.EstadoAuditoria=1

	IF LEN(@Lista)>0 SET @Lista= LEFT(@Lista,LEN(@Lista)-1)
	RETURN @Lista

END
