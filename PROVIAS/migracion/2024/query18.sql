WHILE 1 = 1
BEGIN
    DELETE TOP (10000) v
    FROM Tramite.ExpedienteDocumentoVisualizacion v
    WHERE v.FechaCreacionAuditoria >= '20240101'
            AND v.FechaCreacionAuditoria <  '20250101';

    IF @@ROWCOUNT = 0 BREAK;

    CHECKPOINT;
    WAITFOR DELAY '00:00:00.1';
END
