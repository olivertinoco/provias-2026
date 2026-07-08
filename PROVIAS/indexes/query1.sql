CREATE NONCLUSTERED INDEX IX_ExpedienteDocumento_IdExpediente_CoverEspecialista
ON Tramite.ExpedienteDocumento (IdExpediente, EstadoAuditoria)
INCLUDE (IdExpedienteDocumento,
            IdCatalogoTipoDocumento,
            NumeroDocumento,
            Correlativo,
            RutaArchivoDocumento,
            FgEnEsperaFirmaDigital,
            EsVinculado)
WITH (FILLFACTOR = 90, DATA_COMPRESSION = PAGE);
