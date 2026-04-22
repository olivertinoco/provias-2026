
DECLARE @anio INT = 2023;
DECLARE @anioMax INT = YEAR(GETDATE()) - 1;

WHILE @anio <= @anioMax
BEGIN
    WHILE 1 = 1
    BEGIN
        DELETE TOP (10000)
        FROM Tramite.ExpedienteDocumentoVisualizacion
        WHERE FechaCreacionAuditoria >= DATEFROMPARTS(@anio,1,1)
          AND FechaCreacionAuditoria < DATEFROMPARTS(@anio+1,1,1);

        IF @@ROWCOUNT = 0 BREAK;

        WAITFOR DELAY '00:00:00.1';
    END

    SET @anio += 1;
END
