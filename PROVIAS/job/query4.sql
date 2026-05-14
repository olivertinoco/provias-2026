declare
@idArea1 int = 15,
@idArea2 int = 18,
@idArea3 int = 27,
@idArea4 int = 32


declare @datos varchar(max)


;with tmp001_area as(
    select*from(values(@idArea1),(@idArea2),(@idArea3),(@idArea4))t(id)
)
select @datos = concat(stuff((select ''',''', NombreArea from tmp001_area
outer apply(select*from general.area where IdArea = id)t
for xml path, type).value('.','varchar(max)'),1,3,'select*from(values('''),'''))t(a1,a2,a3,a4)')


exec(@datos)
