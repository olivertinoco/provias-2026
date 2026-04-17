
WHILE 1 = 1
BEGIN
    DELETE TOP (10000)
    FROM Tramite.ExpedienteDocumentoOrigenAdjunto d WITH (ROWLOCK)
    WHERE d.FechaCreacionAuditoria >= '20240101' AND d.FechaCreacionAuditoria <  '20250101'

    IF @@ROWCOUNT = 0 BREAK

    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    DELETE TOP (10000)
    FROM Tramite.ExpedienteDocumentoAdjunto d WITH (ROWLOCK)
    WHERE d.FechaCreacionAuditoria >= '20240101' AND d.FechaCreacionAuditoria <  '20250101'

    IF @@ROWCOUNT = 0 BREAK

    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END
