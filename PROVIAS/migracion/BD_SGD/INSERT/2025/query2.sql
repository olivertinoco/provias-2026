WHILE 1 = 1
BEGIN
    INSERT INTO Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_2025 WITH (TABLOCK)
    SELECT TOP 10000 *
    FROM Tramite.ExpedienteDocumentoAdjuntoFirmante t
    WHERE t.FechaCreacionAuditoria >= '20250101'
        AND t.FechaCreacionAuditoria <  '20260101'
        AND NOT EXISTS (
            SELECT 1
            FROM Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_2025 h
            WHERE h.IdExpedienteDocumentoAdjuntoFirmante = t.IdExpedienteDocumentoAdjuntoFirmante
        )
    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    INSERT INTO Tramite.ExpedienteDevuelto_Historico_2025 WITH (TABLOCK)
    SELECT TOP 10000 *
    FROM Tramite.ExpedienteDevuelto t
    WHERE t.FechaCreacionAuditoria >= '20250101'
        AND t.FechaCreacionAuditoria <  '20260101'
        AND NOT EXISTS (
            SELECT 1
            FROM Tramite.ExpedienteDevuelto_Historico_2025 h
            WHERE h.IdExpedienteDevuelto = t.IdExpedienteDevuelto
        )
    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    INSERT INTO Tramite.ExpedienteEnlazado_Historico_2025 WITH (TABLOCK)
    SELECT TOP 10000 *
    FROM Tramite.ExpedienteEnlazado t
    WHERE t.FechaCreacionAuditoria >= '20250101'
        AND t.FechaCreacionAuditoria <  '20260101'
        AND NOT EXISTS (
            SELECT 1
            FROM Tramite.ExpedienteEnlazado_Historico_2025 h
            WHERE h.IdExpedienteEnlazado = t.IdExpedienteEnlazado
        )
    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    INSERT INTO Tramite.NumeracionSeparada_Historico_2025 WITH (TABLOCK)
    SELECT TOP 10000 *
    FROM Tramite.NumeracionSeparada t
    WHERE t.FechaCreacionAuditoria >= '20250101'
        AND t.FechaCreacionAuditoria <  '20260101'
        AND NOT EXISTS (
            SELECT 1
            FROM Tramite.NumeracionSeparada_Historico_2025 h
            WHERE h.IdNumeracionSeparada = t.IdNumeracionSeparada
        )
    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    INSERT INTO Tramite.ExpedienteSeguimiento_Historico_2025 WITH (TABLOCK)
    SELECT TOP 10000 *
    FROM Tramite.ExpedienteSeguimiento t
    WHERE t.FechaCreacionAuditoria >= '20250101'
        AND t.FechaCreacionAuditoria <  '20260101'
        AND NOT EXISTS (
            SELECT 1
            FROM Tramite.ExpedienteSeguimiento_Historico_2025 h
            WHERE h.IdExpedienteSeguimiento = t.IdExpedienteSeguimiento
        )
    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END
