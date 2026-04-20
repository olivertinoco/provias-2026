
WHILE 1 = 1
BEGIN
    DELETE TOP (10000) e
    FROM Tramite.ExpedienteDocumentoOrigenDestinoAccion e WITH (ROWLOCK)
    WHERE e.FechaCreacionAuditoria >= '20230101' AND e.FechaCreacionAuditoria <  '20240101'

    IF @@ROWCOUNT = 0 BREAK

    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    DELETE TOP (10000) e
    FROM Tramite.ExpedienteDocumentoOrigenDestino e WITH (ROWLOCK)
    WHERE e.FechaCreacionAuditoria >= '20230101' AND e.FechaCreacionAuditoria <  '20240101'

    IF @@ROWCOUNT = 0 BREAK

    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END
