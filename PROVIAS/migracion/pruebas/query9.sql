WHILE 1 = 1
BEGIN
    DELETE TOP (10000)
    FROM Tramite.ExpedienteDocumentoAdjuntoTemporal WITH (ROWLOCK)
    WHERE FechaCreacionAuditoria < DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0)

    IF @@ROWCOUNT = 0 BREAK

    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    DELETE TOP (10000)
    FROM Tramite.ExpedienteDocumentoFirmante WITH (ROWLOCK)
    WHERE FechaCreacionAuditoria < DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()), 0)

    IF @@ROWCOUNT = 0 BREAK

    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END
