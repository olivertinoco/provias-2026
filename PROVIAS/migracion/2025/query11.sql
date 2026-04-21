
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
    DELETE TOP (10000) e
    FROM Tramite.Expediente e
    WHERE e.FechaCreacionAuditoria >= '20250101' AND e.FechaCreacionAuditoria <  '20260101'

    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END
