if exists(select 1 from sys.sysobjects where id=object_id('dbo.udf_split','if'))
drop function dbo.udf_split
go
create function dbo.udf_split(
@data varchar(max),
@sep varchar(1)='|'
)returns table as return(
    select tt.n.value('.','varchar(max)') value
    from(select cast(concat('<x>', replace(@data, @sep, '</x><x>'),'</x>') as xml) val)t
    cross apply t.val.nodes('/x')tt(n)
)
go



if exists(select 1 from sys.sysobjects where id=object_id('dbo.udf_splice','if'))
drop function dbo.udf_splice
go
create function dbo.udf_splice(
    @data varchar(max),
    @sepCamp char(1) = '|',
    @sepRegs char(1) = '~'
)returns table as return(
    with tmp001_data(dato)as(
        select substring(@data, 0, isnull(nullif(charindex(@sepRegs, @data),0),len(@data)+1))
    )
    ,tmp001_matriz(item, dato)as(
        select tt.item, concat(
        case tt.item when 1 then ',nullif(a' when 2 then ',a' end, t.id,
        case tt.item when 1 then concat(','''')a', t.id) end)
        from(select row_number()over(order by (select 1)) id
        from tmp001_data t cross apply dbo.udf_split(t.dato, @sepCamp))t
        cross apply (values(1),(2))tt(item)
        order by tt.item, t.id offset 0 rows
    )
    ,tmp002_matriz(dato)as(
        select replace(replace(@data, @sepCamp, ''','''), @sepRegs, '''),(''')
    )
    select replace(t.dato, '[--23}x{78__]', tt.dato) dato
    from(select (select
    case item when 1 then 'select*from(select ' when 2 then '''))t(' end,
    dato, case item when 1 then ' from(values(''[--23}x{78__]' when 2 then '))t' end
    from(select distinct tt.item, stuff((select t.dato from tmp001_matriz t
    where t.item = tt.item
    for xml path, type).value('.', 'varchar(max)'),1,1,'') dato
    from tmp001_matriz tt)t
    order by t.item
    for xml path, type).value('.', 'varchar(max)') dato)t
    cross apply tmp002_matriz tt
)
go



-- declare @data varchar(max) =
-- '12|maria bonita nota 198||23.23|prueba~56||raiz|23.23|prueba'

-- select @data = dato from dbo.udf_splice(@data, default, default)
-- exec(@data)
