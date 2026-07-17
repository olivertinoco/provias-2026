
-- delete t from Tramite.NumeracionSeparada t
-- cross apply Tramite.NumeracionSeparada_Historico_2025 tt
-- where tt.IdNumeracionSeparada = t.IdNumeracionSeparada


-- delete t from Tramite.ExpedienteDocumentoOrigenDestinoTemporal t
-- cross apply Tramite.ExpedienteDocumentoOrigenDestinoTemporal_Historico_2025 tt
-- where t.IdExpedienteDocumentoOrigenDestinoTemporal = tt.IdExpedienteDocumentoOrigenDestinoTemporal


-- delete t from Tramite.ExpedienteDocumentoOrigenDestinoAccion t
-- cross apply Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2025 tt
-- where t.IdExpedienteDocumentoOrigenDestinoAccion = tt.IdExpedienteDocumentoOrigenDestinoAccion


-- set rowcount 1000000
-- delete t from Tramite.ExpedienteDocumentoOrigenDestino t
-- cross apply Tramite.ExpedienteDocumentoOrigenDestino_Historico_2025 tt
-- where t.IdExpedienteDocumentoOrigenDestino = tt.IdExpedienteDocumentoOrigenDestino
-- go 4


-- delete t from Tramite.ExpedienteDocumentoOrigenAdjunto t
-- cross apply Tramite.ExpedienteDocumentoOrigenAdjunto_Historico_2025 tt
-- where t.IdExpedienteDocumentoOrigenAdjunto = tt.IdExpedienteDocumentoOrigenAdjunto


-- delete t from Tramite.ExpedienteDocumentoOrigen t
-- cross apply Tramite.ExpedienteDocumentoOrigen_Historico_2025 tt
-- where t.IdExpedienteDocumentoOrigen = tt.IdExpedienteDocumentoOrigen


-- delete t from Tramite.ExpedienteDocumentoAdjuntoTemporal t
-- cross apply Tramite.ExpedienteDocumentoAdjuntoTemporal_Historico_2025 tt
-- where t.IdExpedienteDocumentoAdjuntoTemporal = tt.IdExpedienteDocumentoAdjuntoTemporal


-- delete t from Tramite.ExpedienteDocumentoAdjuntoFirmante t
-- cross apply Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_2025 tt
-- where t.IdExpedienteDocumentoAdjuntoFirmante = tt.IdExpedienteDocumentoAdjuntoFirmante


-- delete t from Tramite.ExpedienteDocumentoAdjunto t
-- cross apply Tramite.ExpedienteDocumentoAdjunto_Historico_2025 tt
-- where t.IdExpedienteDocumentoAdjunto = tt.IdExpedienteDocumentoAdjunto


-- delete t from Tramite.ExpedienteDocumentoFirmante t
-- cross apply Tramite.ExpedienteDocumentoFirmante_Historico_2025 tt
-- where t.IdExpedienteDocumentoFirmante = tt.IdExpedienteDocumentoFirmante


-- delete t from Tramite.ExpedienteDocumento t
-- cross apply Tramite.ExpedienteDocumento_Historico_2025 tt
-- where t.IdExpedienteDocumento = tt.IdExpedienteDocumento


-- delete t from Tramite.ExpedienteSeguimiento t
-- cross apply Tramite.ExpedienteSeguimiento_Historico_2025 tt
-- where t.IdExpedienteSeguimiento = tt.IdExpedienteSeguimiento


-- delete t from Tramite.ExpedienteEnlazado t
-- cross apply Tramite.ExpedienteEnlazado_Historico_2025 tt
-- where t.IdExpedienteEnlazado = tt.IdExpedienteEnlazado



-- delete t from Tramite.ExpedienteDevuelto t
-- cross apply Tramite.ExpedienteDevuelto_Historico_2025 tt
-- where t.IdExpedienteDevuelto = tt.IdExpedienteDevuelto


-- delete t from Tramite.Expediente t
-- cross apply Tramite.Expediente_Historico_2025 tt
-- where t.IdExpediente = tt.IdExpediente







-- alter table Tramite.ExpedienteDocumentoOrigenDestinoAccion add constraint fkIdExpedienteDocumentoOrigenDestinoAccion
-- foreign key (IdExpedienteDocumentoOrigenDestino) references Tramite.ExpedienteDocumentoOrigenDestino(IdExpedienteDocumentoOrigenDestino);

-- alter table Tramite.ExpedienteDocumentoOrigenDestino add constraint fkIdExpedienteDocumentoOrigenDestino
-- foreign key (IdExpedienteDocumentoOrigen) references Tramite.ExpedienteDocumentoOrigen(IdExpedienteDocumentoOrigen);

-- alter table Tramite.ExpedienteDocumentoAdjuntoFirmante add constraint fkIdExpedienteDocumentoAdjuntoFirmante
-- foreign key (IdExpedienteDocumentoAdjunto) references Tramite.ExpedienteDocumentoAdjunto(IdExpedienteDocumentoAdjunto);

-- alter table Tramite.ExpedienteDocumentoOrigen add constraint fkIdExpedienteDocumentoOrigen
-- foreign key (IdExpedienteDocumento) references Tramite.ExpedienteDocumento(IdExpedienteDocumento);


-- alter table Tramite.ExpedienteDocumento add constraint fkIdExpedienteDocumento
-- foreign key (IdExpediente) references Tramite.Expediente(IdExpediente);

-- alter table Tramite.ExpedienteBloqueado add constraint fkIdExpedienteBloqueado
-- foreign key (IdExpediente) references Tramite.Expediente(IdExpediente);

-- alter table Tramite.ExpedienteEnlazado add constraint fkIdExpedienteEnlazado
-- foreign key (IdExpediente) references Tramite.Expediente(IdExpediente);
