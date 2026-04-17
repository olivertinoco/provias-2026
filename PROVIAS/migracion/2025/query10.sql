
WHILE 1 = 1
BEGIN
    DELETE TOP (10000)
    FROM Tramite.ExpedienteDocumentoOrigenDestinoAccion e WITH (ROWLOCK)
    WHERE e.FechaCreacionAuditoria >= '20250101' AND e.FechaCreacionAuditoria <  '20260101'

    IF @@ROWCOUNT = 0 BREAK

    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    DELETE TOP (10000)
    FROM Tramite.ExpedienteDocumentoOrigenDestino e WITH (ROWLOCK)
    WHERE e.FechaCreacionAuditoria >= '20250101' AND e.FechaCreacionAuditoria <  '20260101'

    IF @@ROWCOUNT = 0 BREAK

    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END
