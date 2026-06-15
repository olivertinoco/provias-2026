go
create procedure Tramite.paSGDlimpiarTablasActuales_arq
as
begin
begin try
set nocount on


return

delete t from Tramite.NumeracionSeparada t
waitfor delay '00:00:10';

delete t from Tramite.ExpedienteDocumentoOrigenDestinoTemporal t
waitfor delay '00:00:10';

delete t from Tramite.ExpedienteDocumentoOrigenDestinoAccion t
waitfor delay '00:00:10';

delete t from Tramite.ExpedienteDocumentoOrigenDestino t
waitfor delay '00:00:10';

delete t from Tramite.ExpedienteDocumentoOrigenAdjunto t
waitfor delay '00:00:10';

delete t from Tramite.ExpedienteDocumentoOrigen t
waitfor delay '00:00:10';

delete t from Tramite.ExpedienteDocumentoAdjuntoTemporal t
waitfor delay '00:00:10';

delete t from Tramite.ExpedienteDocumentoAdjuntoFirmante t
waitfor delay '00:00:10';

delete t from Tramite.ExpedienteDocumentoAdjunto t
waitfor delay '00:00:10';

delete t from Tramite.ExpedienteDocumentoFirmante t
waitfor delay '00:00:10';

delete t from Tramite.ExpedienteDocumento t
waitfor delay '00:00:10';

delete t from Tramite.ExpedienteSeguimiento t
waitfor delay '00:00:10';

delete t from Tramite.ExpedienteEnlazado t
waitfor delay '00:00:10';

delete t from Tramite.ExpedienteDevuelto t
waitfor delay '00:00:10';

delete t from Tramite.Expediente t
waitfor delay '00:00:10';

end try
begin catch
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER(), @ERROR_SEVERITY=ERROR_SEVERITY(), @ERROR_STATE=ERROR_STATE(),
	@ERROR_PROCEDURE='Tramite.paSGDlimpiarTablasActuales_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER,@ERROR_SEVERITY,@ERROR_STATE,@ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE,2222
end catch
end
go
