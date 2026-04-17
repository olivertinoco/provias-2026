WHILE 1 = 1
BEGIN
    DELETE TOP (10000) a
    FROM Tramite.ExpedienteDocumentoOrigenDestinoAccion a
    INNER JOIN Tramite.ExpedienteDocumentoOrigenDestino d
        ON a.IdExpedienteDocumentoOrigenDestino = d.IdExpedienteDocumentoOrigenDestino
    INNER JOIN Tramite.ExpedienteDocumentoOrigen o
        ON d.IdExpedienteDocumentoOrigen = o.IdExpedienteDocumentoOrigen
    WHERE o.FechaCreacionAuditoria >= '20250101' AND o.FechaCreacionAuditoria <  '20260101'

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
    WHERE o.FechaCreacionAuditoria >= '20250101' AND o.FechaCreacionAuditoria <  '20260101'

    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    DELETE TOP (10000)
    FROM Tramite.ExpedienteDocumentoOrigen o WITH (ROWLOCK)
    WHERE o.FechaCreacionAuditoria >= '20250101' AND o.FechaCreacionAuditoria <  '20260101'

    IF @@ROWCOUNT = 0 BREAK

    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END
