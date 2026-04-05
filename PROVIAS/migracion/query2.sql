WHILE 1 = 1
BEGIN
    INSERT INTO Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico WITH (TABLOCK)
    SELECT TOP 10000 *
    FROM Tramite.ExpedienteDocumentoAdjuntoFirmante t
    WHERE NOT EXISTS (
        SELECT 1
        FROM Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico h
        WHERE h.IdExpedienteDocumentoAdjuntoFirmante = t.IdExpedienteDocumentoAdjuntoFirmante
    )
    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    INSERT INTO Tramite.ExpedienteDevuelto_Historico WITH (TABLOCK)
    SELECT TOP 10000 *
    FROM Tramite.ExpedienteDevuelto t
    WHERE NOT EXISTS (
        SELECT 1
        FROM Tramite.ExpedienteDevuelto_Historico h
        WHERE h.IdExpedienteDevuelto = t.IdExpedienteDevuelto
    )
    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    INSERT INTO Tramite.ExpedienteEnlazado_Historico WITH (TABLOCK)
    SELECT TOP 10000 *
    FROM Tramite.ExpedienteEnlazado t
    WHERE NOT EXISTS (
        SELECT 1
        FROM Tramite.ExpedienteEnlazado_Historico h
        WHERE h.IdExpedienteEnlazado = t.IdExpedienteEnlazado
    )
    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    INSERT INTO Tramite.NumeracionSeparada_Historico WITH (TABLOCK)
    SELECT TOP 10000 *
    FROM Tramite.NumeracionSeparada t
    WHERE NOT EXISTS (
        SELECT 1
        FROM Tramite.NumeracionSeparada_Historico h
        WHERE h.IdNumeracionSeparada = t.IdNumeracionSeparada
    )
    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END


WHILE 1 = 1
BEGIN
    INSERT INTO Tramite.ExpedienteSeguimiento_Historico WITH (TABLOCK)
    SELECT TOP 10000 *
    FROM Tramite.ExpedienteSeguimiento t
    WHERE NOT EXISTS (
        SELECT 1
        FROM Tramite.ExpedienteSeguimiento_Historico h
        WHERE h.IdExpedienteSeguimiento = t.IdExpedienteSeguimiento
    )
    IF @@ROWCOUNT = 0 BREAK
    CHECKPOINT
    WAITFOR DELAY '00:00:00.1'
END
