-- create table dbo.prueba22(
--     dato nvarchar(300)
-- )
-- go

-- declare @dato nvarchar(300) = 'Metodología de Desarrollo Ágil de Sistemas de Información PROVIAS_v1 3[R]'

-- insert into dbo.prueba22
-- select @dato

-- select*from dbo.prueba22



;with tmp001_set as(
    select '","' t
)
select (select '["',
    rtrim(ltrim(idexpediente)), t,
    rtrim(ltrim(NumeroExpediente)), t,
    rtrim(ltrim(AsuntoExpediente)), t,
    rtrim(ltrim(NumeroExpedienteExterno)), t,
    rtrim(ltrim(FgTramiteVirtualPide)), t,
    rtrim(ltrim(NombreExpediente)), '"]'
from tramite.expediente where idexpediente = 256874
for xml path, type).value('.','varchar(500)')
from tmp001_set
