
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
