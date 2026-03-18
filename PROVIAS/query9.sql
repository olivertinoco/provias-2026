CREATE FUNCTION [Tramite].[fnObtenerOrigenInicialDocumento] (
    @pIdExpediente int
)RETURNS varchar(100)
AS
BEGIN
    DECLARE @vCatalogoTipoOrigen varchar(100)=''

    select top 1 @vCatalogoTipoOrigen=
    CONCAT(coalesce(c.Descripcion,''),' ',EX.NumeroExpedienteExterno)
    from Tramite.ExpedienteDocumento e  WITH (NOLOCK)
    INNER JOIN Tramite.Expediente EX  WITH (NOLOCK) ON EX.IdExpediente=E.IdExpediente
    INNER JOIN Tramite.Catalogo c on c.IdCatalogo=e.IdCatalogoTipoOrigen
    where e.EstadoAuditoria=1 and e.IdExpediente=@pIdExpediente
    order by e.IdExpedienteDocumento
    return @vCatalogoTipoOrigen
END
