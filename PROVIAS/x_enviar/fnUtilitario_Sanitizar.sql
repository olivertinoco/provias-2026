create function tramite.fnUtilitario_Sanitizar(
    @pvcTexto varchar(1000)
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
    isnull(@pvcTexto,''),
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
