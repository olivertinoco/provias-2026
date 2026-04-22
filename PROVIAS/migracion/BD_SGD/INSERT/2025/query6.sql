DECLARE @lastId BIGINT = 0;

WHILE 1 = 1
BEGIN
    IF OBJECT_ID('tempdb..#tmp') IS NOT NULL DROP TABLE #tmp;

    SELECT TOP 10000 *
    INTO #tmp
    FROM Tramite.ExpedienteDocumentoOrigenDestino t
    WHERE t.IdExpedienteDocumentoOrigenDestino > @lastId
        AND t.FechaCreacionAuditoria >= '20250101'
        AND t.FechaCreacionAuditoria <  '20260101'
    ORDER BY t.IdExpedienteDocumentoOrigenDestino

    INSERT INTO Tramite.ExpedienteDocumentoOrigenDestino_Historico_2025 WITH (TABLOCK)
    SELECT * FROM #tmp;

    IF @@ROWCOUNT = 0 BREAK;

    SELECT @lastId = MAX(IdExpedienteDocumentoOrigenDestino)
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
    FROM Tramite.ExpedienteDocumentoOrigenDestinoAccion t
    WHERE t.IdExpedienteDocumentoOrigenDestinoAccion > @lastId2
        AND t.FechaCreacionAuditoria >= '20250101'
        AND t.FechaCreacionAuditoria <  '20260101'
    ORDER BY t.IdExpedienteDocumentoOrigenDestinoAccion

    INSERT INTO Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2025 WITH (TABLOCK)
    SELECT * FROM #tmp2;

    IF @@ROWCOUNT = 0 BREAK;

    SELECT @lastId2 = MAX(IdExpedienteDocumentoOrigenDestinoAccion)
    FROM #tmp2;

    CHECKPOINT;
    WAITFOR DELAY '00:00:00.1';
END
