-- INGRESO DINAMICO DE PARAMETROS PARA SQLSTRESSCMD
-- ================================================
-- ================================================
Declare
@tabla varchar(200), @aux varchar(max),
@procedures varchar(1000) =
-- 'tramite.paListarExpedienteMesaParteDespachadosVirtualesV1'
'tramite.paObtenerEstadosExpedientesEspecialista'
-- 'tramite.paListarExpedientePendienteEspecialistaPorRecibir'
-- 'tramite.paListarExpedientePendienteJefaturaPorRecibirFosCad'
-- 'tramite.paListarExpedienteMesaParteDespachadosV1'

SELECT
    p.parameter_id,
    replace(p.name, '@', '') AS parametro,
    t.name AS tipo_dato,
    p.max_length,
    p.precision,
    p.scale,
    p.is_output,
    patindex('%char%', t.name) ischar
into #tmp001_reg_param22
FROM sys.parameters p, sys.types t
WHERE p.user_type_id = t.user_type_id and p.object_id = OBJECT_ID(@procedures)
ORDER BY p.parameter_id

select @tabla = (select replace(value, 'tramite', 'dbo.') from dbo.udf_split(@procedures, '.')
for xml path, type).value('.','varchar(500)')


-- NOTA: CREAR LA TABLA PARA PRUEBAS SQLSTRESSCMD
-- ===============================================
select @aux = concat('if exists(select 1 from sys.sysobjects where id=object_id(''', @tabla, ''',''U'')) drop table ', @tabla)
exec(@aux)
select @aux = concat(stuff((select ',col', t.parameter_id, ' ', t.tipo_dato, case ischar when 0 then '' else concat('(', max_length, ')') end
from #tmp001_reg_param22 t
order by t.parameter_id
for xml path, type).value('.','varchar(500)'),1,1, concat('create table ', @tabla, '(')), ')')
exec(@aux)

-- AQUI VA EL INSERT INTO DE LOS VALORES PARA LA U A EXPLOTAR
-- ===========================================================
select 'insert into '+ @tabla +' select '


insert into dbo.paObtenerEstadosExpedientesEspecialista select 226, 2261, 226
insert into dbo.paObtenerEstadosExpedientesEspecialista select 1059, 2259, 1059


-- insert into dbo.paListarExpedienteMesaParteDespachadosV1 select 20, 389,null, null, 1,10,null
-- insert into dbo.paListarExpedienteMesaParteDespachadosVirtualesV1 select 56784, null, null, 1, 10, 'ENTREGA'
-- insert into dbo.paListarExpedientePendienteEspecialistaCreados select 0, '13/04/2026','13/04/2026',0,'13/04/2026','13/04/2026',728,727, 116, 4,0,0,2026,0,0,0,'','','','',0,'','','',728,null,null,1,10,null,0

-- insert into dbo.paListarExpedientePendienteEspecialistaPorRecibir select 0,'13/04/2026','13/04/2026',0,'13/04/2026','13/04/2026',590,588,4,4,0,0,2026,0,0,0,'','','','',0,'','','',590,NULL,NULL,1,100,NULL,0
-- insert into dbo.paListarExpedientePendienteJefaturaPorRecibirFosCad select 0,'15/04/2026','15/04/2026',0,'15/04/2026','15/04/2026',30,4,0,0,0,0,0,0,0,'','','','',0,'','','',52939,null,null,1,10,null,0
-- insert into dbo.paListarExpedientePendienteJefaturaPorRecibirFosCad select 0,'15/04/2026','15/04/2026',0,'15/04/2026','15/04/2026',30,4,4,0,0,0,0,0,0,'','','','',0,'','','',52939,null,null,1,10,null,0




exec('select*from '+ @tabla)

-- NOTA: EL MAINQUERY PARA SQLSTRESSCMD
-- ====================================
select stuff((select ',@p', t.parameter_id
from #tmp001_reg_param22 t
order by t.parameter_id
for xml path, type).value('.','varchar(500)'),1,1, concat('exec ', @procedures, ' '))


-- NOTA: EL SELECT PARA SQLSTRESSCMD
-- =================================
select concat(stuff((select ',col', parameter_id
from #tmp001_reg_param22 t
order by t.parameter_id
for xml path, type).value('.','varchar(500)'),1,1,'select '), ' from ', @tabla)


-- NOTA AQUI EL ParamMappings PARA SQLSTRESSCMD
-- ============================================
select stuff((select ',|{ "Key": "@p', parameter_id, '", "Value": "col', parameter_id, '" }'
from #tmp001_reg_param22 t
order by t.parameter_id
for xml path, type).value('.','varchar(max)'),1,2,'') dato
into #tmp001_params
select value from #tmp001_params cross apply dbo.udf_split(dato, default)
