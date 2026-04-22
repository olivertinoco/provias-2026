DECLARE @lastId BIGINT = 0;

WHILE 1 = 1
BEGIN
    IF OBJECT_ID('tempdb..#tmp') IS NOT NULL DROP TABLE #tmp;

    SELECT TOP 10000 *
    INTO #tmp
    FROM Tramite.ExpedienteDocumentoAdjuntoTemporal t
    WHERE t.IdExpedienteDocumentoAdjuntoTemporal > @lastId
        AND t.FechaCreacionAuditoria >= '20250101'
        AND t.FechaCreacionAuditoria <  '20260101'
    ORDER BY t.IdExpedienteDocumentoAdjuntoTemporal

    INSERT INTO Tramite.ExpedienteDocumentoAdjuntoTemporal_Historico_2025 WITH (TABLOCK)
    SELECT * FROM #tmp;

    IF @@ROWCOUNT = 0 BREAK;

    SELECT @lastId = MAX(IdExpedienteDocumentoAdjuntoTemporal)
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
    FROM Tramite.ExpedienteDocumento t
    WHERE t.IdExpedienteDocumento > @lastId2
        AND t.FechaCreacionAuditoria >= '20250101'
        AND t.FechaCreacionAuditoria <  '20260101'
    ORDER BY t.IdExpedienteDocumento

    INSERT INTO Tramite.ExpedienteDocumento_Historico_2025 WITH (TABLOCK)
    SELECT * FROM #tmp2;

    IF @@ROWCOUNT = 0 BREAK;

    SELECT @lastId2 = MAX(IdExpedienteDocumento)
    FROM #tmp2;

    CHECKPOINT;
    WAITFOR DELAY '00:00:00.1';
END



DECLARE @lastId3 BIGINT = 0;

WHILE 1 = 1
BEGIN
    IF OBJECT_ID('tempdb..#tmp3') IS NOT NULL DROP TABLE #tmp3;

    SELECT TOP 10000 *
    INTO #tmp3
    FROM Tramite.ExpedienteDocumentoFirmante t
    WHERE t.IdExpedienteDocumentoFirmante > @lastId3
        AND t.FechaCreacionAuditoria >= '20250101'
        AND t.FechaCreacionAuditoria <  '20260101'
    ORDER BY t.IdExpedienteDocumentoFirmante

    INSERT INTO Tramite.ExpedienteDocumentoFirmante_Historico_2025 WITH (TABLOCK)
    SELECT * FROM #tmp3;

    IF @@ROWCOUNT = 0 BREAK;

    SELECT @lastId3 = MAX(IdExpedienteDocumentoFirmante)
    FROM #tmp3;

    CHECKPOINT;
    WAITFOR DELAY '00:00:00.1';
END
