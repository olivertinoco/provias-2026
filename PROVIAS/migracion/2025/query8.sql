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
    WHERE e.FechaCreacionAuditoria >= '20250101' AND e.FechaCreacionAuditoria <  '20260101'

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
    WHERE e.FechaCreacionAuditoria >= '20250101' AND e.FechaCreacionAuditoria <  '20260101'

    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END



WHILE 1 = 1
BEGIN
    DELETE TOP (10000) o
    FROM Tramite.ExpedienteDocumentoOrigen o
    INNER JOIN Tramite.ExpedienteDocumento doc
        ON o.IdExpedienteDocumento = doc.IdExpedienteDocumento
    INNER JOIN Tramite.Expediente e
        ON doc.IdExpediente = e.IdExpediente
    WHERE e.FechaCreacionAuditoria >= '20250101' AND e.FechaCreacionAuditoria <  '20260101'

    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END



WHILE 1 = 1
BEGIN
    DELETE TOP (10000) doc
    FROM Tramite.ExpedienteDocumento doc
    INNER JOIN Tramite.Expediente e
        ON doc.IdExpediente = e.IdExpediente
    WHERE e.FechaCreacionAuditoria >= '20250101' AND e.FechaCreacionAuditoria <  '20260101'

    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    DELETE TOP (10000) d
    FROM Tramite.ExpedienteDevuelto d
    INNER JOIN Tramite.Expediente e
        ON d.IdExpediente = e.IdExpediente
    WHERE e.FechaCreacionAuditoria >= '20250101' AND e.FechaCreacionAuditoria <  '20260101'

    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END

WHILE 1 = 1
BEGIN
    DELETE TOP (10000) d
    FROM Tramite.ExpedienteEnlazado d
    INNER JOIN Tramite.Expediente e
        ON d.IdExpediente = e.IdExpediente
    WHERE e.FechaCreacionAuditoria >= '20250101' AND e.FechaCreacionAuditoria <  '20260101'

    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END

WHILE 1 = 1
BEGIN
    DELETE TOP (10000)
    FROM Tramite.Expediente e
    WHERE e.FechaCreacionAuditoria >= '20250101' AND e.FechaCreacionAuditoria <  '20260101'

    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END
