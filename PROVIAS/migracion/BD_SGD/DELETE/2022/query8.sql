
WHILE 1 = 1
BEGIN
    DELETE TOP (10000) d
    FROM Tramite.ExpedienteDocumentoOrigenAdjunto d WITH (ROWLOCK)
    WHERE d.FechaCreacionAuditoria >= '20220101' AND d.FechaCreacionAuditoria <  '20230101'

    IF @@ROWCOUNT = 0 BREAK

    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    DELETE TOP (10000) t
    from tramite.ExpedienteDocumentoAdjuntoFirmante t
    inner join Tramite.ExpedienteDocumentoAdjunto tt
        on tt.IdExpedienteDocumentoAdjunto = t.IdExpedienteDocumentoAdjunto
    WHERE tt.FechaCreacionAuditoria >= '20220101' AND tt.FechaCreacionAuditoria <  '20230101'

    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END




WHILE 1 = 1
BEGIN
    DELETE TOP (10000) d
    FROM Tramite.ExpedienteDocumentoAdjunto d WITH (ROWLOCK)
    WHERE d.FechaCreacionAuditoria >= '20220101' AND d.FechaCreacionAuditoria <  '20230101'

    IF @@ROWCOUNT = 0 BREAK

    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END
