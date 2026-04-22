WHILE 1 = 1
BEGIN
    DELETE TOP (10000) a
    FROM Tramite.ExpedienteDocumentoOrigenDestinoAccion a
    INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino d
        ON a.IdExpedienteDocumentoOrigenDestino = d.IdExpedienteDocumentoOrigenDestino
    INNER JOIN Tramite.ExpedienteDocumentoOrigen o
        ON d.IdExpedienteDocumentoOrigen = o.IdExpedienteDocumentoOrigen
    INNER JOIN Tramite.ExpedienteDocumento doc
        ON o.IdExpedienteDocumento = doc.IdExpedienteDocumento
    INNER JOIN Tramite.Expediente e
        ON doc.IdExpediente = e.IdExpediente
    WHERE e.FechaCreacionAuditoria >= '20230101' AND e.FechaCreacionAuditoria <  '20240101'

    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    DELETE TOP (10000) d
    FROM Tramite.ExpedienteDocumentoOrigenDestino d
    INNER JOIN Tramite.ExpedienteDocumentoOrigen o
        ON d.IdExpedienteDocumentoOrigen = o.IdExpedienteDocumentoOrigen
    INNER JOIN Tramite.ExpedienteDocumento doc
        ON o.IdExpedienteDocumento = doc.IdExpedienteDocumento
    INNER JOIN Tramite.Expediente e
        ON doc.IdExpediente = e.IdExpediente
    WHERE e.FechaCreacionAuditoria >= '20230101' AND e.FechaCreacionAuditoria <  '20240101'

    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END
