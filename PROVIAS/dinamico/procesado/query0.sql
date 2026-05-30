Tramite.Expediente_Historico_2022
Tramite.ExpedienteDevuelto_Historico_2022

Tramite.ExpedienteDocumento_Historico_2022
Tramite.ExpedienteDocumentoAdjunto_Historico_2022
Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_2022
Tramite.ExpedienteDocumentoAdjuntoTemporal_Historico_2022
Tramite.ExpedienteDocumentoFirmante_Historico_2022
Tramite.ExpedienteDocumentoVisualizacion_Historico_2022

Tramite.ExpedienteDocumentoOrigen_Historico_2022
Tramite.ExpedienteDocumentoOrigenAdjunto_Historico_2022

Tramite.ExpedienteDocumentoOrigenDestino_Historico_2022
Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_2022
Tramite.ExpedienteDocumentoOrigenDestinoTemporal_Historico_2022

Tramite.ExpedienteEnlazado_Historico_2022
Tramite.ExpedienteSeguimiento_Historico_2022
Tramite.NumeracionSeparada_Historico_2022


U    Tramite.Expediente
U    Tramite.ExpedienteDocumento
U    Tramite.ExpedienteDocumentoOrigen
U    Tramite.ExpedienteDocumentoOrigenDestino
U    Tramite.ExpedienteEnlazado
U    Tramite.ExpedienteSeguimiento
U    Tramite.ExpedienteDocumentoFirmante



--I-091266-2025
--HOJA DE RUTA ACTUAL -> TRAE 8 FILAS
EXECUTE [Tramite].[paListarDocumentoOrigenDestinoHojaRutaV1] 727733,79,0,0,349

--HOJA DE RUTA CON ARQ -> TRAE SOLO 1 FILA
EXECUTE [Tramite].[paListarDocumentoOrigenDestinoHojaRuta_arq] 727733,79,0,0,349,2025





--I-091266-2025
--HOJA DE RUTA COMPLETA ACTUAL -> TRAE 8 FILAS
EXECUTE [Tramite].[paListarDocumentoHojaRutaV1] 727733,79,349

--HOJA DE RUTA COMPLETA CON ARQ -> TRAE SOLO 1 FILA
EXECUTE [Tramite].[paListarDocumentoHojaRuta_arq] 727733,79,349,2025
