DECLARE @lastId BIGINT = 0;

WHILE 1 = 1
BEGIN
    IF OBJECT_ID('tempdb..#tmp') IS NOT NULL DROP TABLE #tmp;

    SELECT TOP 10000 *
    INTO #tmp
    FROM Tramite.ExpedienteDocumentoOrigenAdjunto t
    WHERE t.IdExpedienteDocumentoOrigenAdjunto > @lastId
        AND t.FechaCreacionAuditoria >= '20220101'
        AND t.FechaCreacionAuditoria <  '20230101'
    ORDER BY t.IdExpedienteDocumentoOrigenAdjunto

    INSERT INTO Tramite.ExpedienteDocumentoOrigenAdjunto_Historico_2022 WITH (TABLOCK)
    SELECT * FROM #tmp;

    IF @@ROWCOUNT = 0 BREAK;

    SELECT @lastId = MAX(IdExpedienteDocumentoOrigenAdjunto)
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
    FROM Tramite.Expediente t
    WHERE t.IdExpediente > @lastId2
        AND t.FechaCreacionAuditoria >= '20220101'
        AND t.FechaCreacionAuditoria <  '20230101'
    ORDER BY t.IdExpediente

    INSERT INTO Tramite.Expediente_Historico_2022 WITH (TABLOCK)
    SELECT * FROM #tmp2;

    IF @@ROWCOUNT = 0 BREAK;

    SELECT @lastId2 = MAX(IdExpediente)
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
    FROM Tramite.ExpedienteDocumentoAdjunto t
    WHERE t.IdExpedienteDocumentoAdjunto > @lastId3
        AND t.FechaCreacionAuditoria >= '20220101'
        AND t.FechaCreacionAuditoria <  '20230101'
    ORDER BY t.IdExpedienteDocumentoAdjunto

    INSERT INTO Tramite.ExpedienteDocumentoAdjunto_Historico_2022 WITH (TABLOCK)
    SELECT * FROM #tmp3;

    IF @@ROWCOUNT = 0 BREAK;

    SELECT @lastId3 = MAX(IdExpedienteDocumentoAdjunto)
    FROM #tmp3;

    CHECKPOINT;
    WAITFOR DELAY '00:00:00.1';
END
