
WHILE 1 = 1
BEGIN
    DELETE TOP (10000) f
    FROM Tramite.ExpedienteDocumentoVisualizacion f
    WHERE f.FechaCreacionAuditoria >= '20250101' AND f.FechaCreacionAuditoria <  '20260101';

    IF @@ROWCOUNT = 0 BREAK;

    CHECKPOINT;
    WAITFOR DELAY '00:00:00.1';
END
