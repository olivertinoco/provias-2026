
if exists(select 1 from sys.sysobjects where id=object_id('tramite.udf_funParaAnularMesaParte','if'))
drop function tramite.udf_funParaAnularMesaParte
go
create function tramite.udf_funParaAnularMesaParte(
    @IdExpedienteDocumentoOrigen int
)returns table as return(
    select case when count(1) > 0 then 0 else 1 end paraAnular
    from Tramite.ExpedienteDocumentoOrigenDestino
    where isnull(FechaDestinoRecepciona,'') != '' and IdExpedienteDocumentoOrigen = @IdExpedienteDocumentoOrigen
)
go



if exists(select 1 from sys.sysobjects where id=object_id('tramite.udf_sanitizar','if'))
drop function tramite.udf_sanitizar
go
create function tramite.udf_sanitizar(
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


select*from General.fnObtenerPaginacion02(10,1,866)

go
alter FUNCTION General.fnObtenerPaginacion02
(
   @piPageSize    INT = 10,
   @piCurrentPage INT = 1,
   @piRecordCount INT = 0
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        iPageCount =
            CASE
                WHEN @piRecordCount = 0 THEN 1
                ELSE (@piRecordCount + @piPageSize - 1) / @piPageSize
            END,

        iStartRow =
            ((CASE
                WHEN @piCurrentPage < 1 THEN 1
                WHEN @piCurrentPage >
                     CASE WHEN @piRecordCount = 0 THEN 1
                          ELSE (@piRecordCount + @piPageSize - 1) / @piPageSize END
                THEN (@piRecordCount + @piPageSize - 1) / @piPageSize
                ELSE @piCurrentPage
             END - 1) * @piPageSize) + 1,

        iEndRow =
            (CASE
                WHEN @piCurrentPage < 1 THEN 1
                WHEN @piCurrentPage >
                     CASE WHEN @piRecordCount = 0 THEN 1
                          ELSE (@piRecordCount + @piPageSize - 1) / @piPageSize END
                THEN (@piRecordCount + @piPageSize - 1) / @piPageSize
                ELSE @piCurrentPage
             END * @piPageSize)
);
GO
