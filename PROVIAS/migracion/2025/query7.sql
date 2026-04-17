
ALTER TABLE tramite.ExpedienteBloqueado
DROP CONSTRAINT fkIdExpedienteBloqueado;

WHILE 1 = 1
BEGIN
    DELETE TOP (10000)
    FROM Tramite.ExpedienteDevuelto t WITH (ROWLOCK)
    WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'

    IF @@ROWCOUNT = 0 BREAK

    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    DELETE TOP (10000)
    FROM Tramite.NumeracionSeparada t WITH (ROWLOCK)
    WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'

    IF @@ROWCOUNT = 0 BREAK

    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    DELETE TOP (10000)
    FROM Tramite.ExpedienteSeguimiento t WITH (ROWLOCK)
    WHERE t.FechaCreacionAuditoria >= '20250101'
    AND t.FechaCreacionAuditoria <  '20260101'

    IF @@ROWCOUNT = 0 BREAK

    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END
