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
    WHERE doc.FechaCreacionAuditoria >= '20250101' AND doc.FechaCreacionAuditoria <  '20260101'

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
    WHERE doc.FechaCreacionAuditoria >= '20250101' AND doc.FechaCreacionAuditoria <  '20260101'

    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END



WHILE 1 = 1
BEGIN
    DELETE TOP (10000) o
    FROM Tramite.ExpedienteDocumentoOrigen o
    INNER JOIN Tramite.ExpedienteDocumento d
        ON o.IdExpedienteDocumento = d.IdExpedienteDocumento
    WHERE d.FechaCreacionAuditoria >= '20250101' AND d.FechaCreacionAuditoria <  '20260101'

    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    DELETE TOP (10000)
    FROM Tramite.ExpedienteDocumento WITH (ROWLOCK)
    WHERE FechaCreacionAuditoria >= '20250101' AND FechaCreacionAuditoria <  '20260101'

    IF @@ROWCOUNT = 0 BREAK

    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END
