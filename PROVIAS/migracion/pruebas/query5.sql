DECLARE @lastId BIGINT = 0;

WHILE 1 = 1
BEGIN
    IF OBJECT_ID('tempdb..#tmp') IS NOT NULL DROP TABLE #tmp;

    SELECT TOP 10000 *
    INTO #tmp
    FROM Tramite.ExpedienteDocumentoOrigenDestinoTemporal t
    WHERE t.IdExpedienteDocumentoOrigenDestinoTemporal > @lastId
    ORDER BY t.IdExpedienteDocumentoOrigenDestinoTemporal

    INSERT INTO Tramite.ExpedienteDocumentoOrigenDestinoTemporal_Historico WITH (TABLOCK)
    SELECT * FROM #tmp;

    IF @@ROWCOUNT = 0 BREAK;

    SELECT @lastId = MAX(IdExpedienteDocumentoOrigenDestinoTemporal)
    FROM #tmp;

    CHECKPOINT;
    WAITFOR DELAY '00:00:00.1';
END


DECLARE @lastId2 BIGINT = 0;

WHILE 1 = 1
BEGIN
    IF OBJECT_ID('tempdb..#tmp2') IS NOT NULL DROP TABLE #tmp2;

    SELECT TOP 10000 *
    INTO #tmp2
    FROM Tramite.ExpedienteDocumentoOrigen t
    WHERE t.IdExpedienteDocumentoOrigen > @lastId2
    ORDER BY t.IdExpedienteDocumentoOrigen

    INSERT INTO Tramite.ExpedienteDocumentoOrigen_Historico WITH (TABLOCK)
    SELECT * FROM #tmp2;

    IF @@ROWCOUNT = 0 BREAK;

    SELECT @lastId2 = MAX(IdExpedienteDocumentoOrigen)
    FROM #tmp2;

    CHECKPOINT;
    WAITFOR DELAY '00:00:00.1';
END
