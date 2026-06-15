go
create procedure Tramite.paSGDpoblarTablasAnuales_arq
as
begin
begin try
set nocount on

Declare @vSql Nvarchar(max)=null, @vperiodo varchar(4) = year(getdate())-1

select @vperiodo = 2028

return

select @vSql = N'\
insert into Tramite.Expediente_Historico_'+ @vperiodo +N' \
select*from Tramite.Expediente'

exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
insert into Tramite.ExpedienteDocumento_Historico_'+ @vperiodo +N' \
select*from Tramite.ExpedienteDocumento'

exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
insert into Tramite.ExpedienteDocumentoOrigen_Historico_'+ @vperiodo +N' \
select*from Tramite.ExpedienteDocumentoOrigen'

exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
insert into Tramite.ExpedienteDocumentoOrigenDestino_Historico_'+ @vperiodo +N' \
select*from Tramite.ExpedienteDocumentoOrigenDestino'

exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
insert into Tramite.ExpedienteDevuelto_Historico_'+ @vperiodo +N' \
select*from Tramite.ExpedienteDevuelto'

exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
insert into Tramite.ExpedienteEnlazado_Historico_'+ @vperiodo +N' \
select*from Tramite.ExpedienteEnlazado'

exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
insert into Tramite.ExpedienteSeguimiento_Historico_'+ @vperiodo +N' \
select*from Tramite.ExpedienteSeguimiento'

exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
insert into Tramite.NumeracionSeparada_Historico_'+ @vperiodo +N' \
select*from Tramite.NumeracionSeparada'

exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
insert into Tramite.ExpedienteDocumentoFirmante_Historico_'+ @vperiodo +N' \
select*from Tramite.ExpedienteDocumentoFirmante'

exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
insert into Tramite.ExpedienteDocumentoAdjunto_Historico_'+ @vperiodo +N' \
select*from Tramite.ExpedienteDocumentoAdjunto'

exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
insert into Tramite.ExpedienteDocumentoAdjuntoFirmante_Historico_'+ @vperiodo +N' \
select*from Tramite.ExpedienteDocumentoAdjuntoFirmante'

exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
insert into Tramite.ExpedienteDocumentoAdjuntoTemporal_Historico_'+ @vperiodo +N' \
select*from Tramite.ExpedienteDocumentoAdjuntoTemporal'

exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
insert into Tramite.ExpedienteDocumentoOrigenAdjunto_Historico_'+ @vperiodo +N' \
select*from Tramite.ExpedienteDocumentoOrigenAdjunto'

exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
insert into Tramite.ExpedienteDocumentoOrigenDestinoAccion_Historico_'+ @vperiodo +N' \
select*from Tramite.ExpedienteDocumentoOrigenDestinoAccion'

exec sp_executesql @vSql

select @vSql = null
select @vSql = N'\
insert into Tramite.ExpedienteDocumentoOrigenDestinoTemporal_Historico_'+ @vperiodo +N' \
select*from Tramite.ExpedienteDocumentoOrigenDestinoTemporal'

exec sp_executesql @vSql


end try
begin catch
    DECLARE @ERROR_NUMBER INT, @ERROR_SEVERITY INT,@ERROR_STATE INT,@ERROR_LINE INT,@ERROR_PROCEDURE VARCHAR(MAX)	,@ERROR_MESSAGE VARCHAR(MAX)
	SELECT @ERROR_NUMBER=ERROR_NUMBER(), @ERROR_SEVERITY=ERROR_SEVERITY(), @ERROR_STATE=ERROR_STATE(),
	@ERROR_PROCEDURE='Tramite.paSGDpoblarTablasAnuales_arq',@ERROR_LINE=ERROR_LINE(),@ERROR_MESSAGE=ERROR_MESSAGE()
	EXEC Seguridad.paGuardarErroresEnTablaLog @ERROR_NUMBER,@ERROR_SEVERITY,@ERROR_STATE,@ERROR_PROCEDURE,@ERROR_LINE,@ERROR_MESSAGE,2222
end catch
end
go
