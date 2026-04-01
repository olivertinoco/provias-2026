create table dbo.prueba22(
    dato nvarchar(300)
)
go

declare @dato nvarchar(300) = 'Metodología de Desarrollo Ágil de Sistemas de Información PROVIAS_v1 3[R]'

insert into dbo.prueba22
select @dato

select*from dbo.prueba22
