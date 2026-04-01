
-- alter procedure dbo.prueba_23_24_2026
-- as
-- select concat(object_schema_name(@@procid),'.', object_name(@@procid)) nombreSP
-- go


-- if exists(select 1 from sys.sysobjects where id=object_id('tramite.fnExpediente_AnularMesaParte','if'))
-- drop function tramite.fnExpediente_AnularMesaParte
-- go
-- create function tramite.fnExpediente_AnularMesaParte(
--     @IdExpedienteDocumentoOrigen int
-- )returns table as return(
--     select case when count(1) > 0 then 0 else 1 end paraAnular
--     from Tramite.ExpedienteDocumentoOrigenDestino
--     where isnull(FechaDestinoRecepciona,'') != '' and IdExpedienteDocumentoOrigen = @IdExpedienteDocumentoOrigen
-- )
-- go



if exists(select 1 from sys.sysobjects where id=object_id('tramite.fnUtilitario_sanitizar','if'))
drop function tramite.fnUtilitario_sanitizar
go
create function tramite.fnUtilitario_sanitizar(
    @texto varchar(1000)
)returns table as return(
select cadena =
    ltrim(rtrim(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    replace(
    isnull(@texto,''),
    '"',''),
    '''',''),
    '(',''),
    ')',''),
    '&',''),
    '|',''),
    '!',''),
    '-',''),
    char(9), ' '),
    char(10), ' '),
    char(13), ' ')
    ))
)
go
