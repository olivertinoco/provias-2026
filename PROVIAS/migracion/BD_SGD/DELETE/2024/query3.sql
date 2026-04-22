
WHILE 1 = 1
BEGIN
    DELETE TOP (10000) o
    FROM Tramite.ExpedienteDocumentoOrigen o
    INNER JOIN Tramite.ExpedienteDocumento doc
        ON o.IdExpedienteDocumento = doc.IdExpedienteDocumento
    INNER JOIN Tramite.Expediente e
        ON doc.IdExpediente = e.IdExpediente
    WHERE e.FechaCreacionAuditoria >= '20240101' AND e.FechaCreacionAuditoria <  '20250101'

    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END
