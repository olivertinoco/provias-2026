
WHILE 1 = 1
BEGIN
    DELETE TOP (10000) d
    FROM Tramite.ExpedienteDocumentoOrigenDestinoTemporal d WITH (ROWLOCK)
    WHERE d.FechaCreacionAuditoria >= '20230101' AND d.FechaCreacionAuditoria <  '20240101'

    IF @@ROWCOUNT = 0 BREAK

    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END
