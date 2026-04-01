-- set rowcount 100


-- exec tramite.paListarExpedienteMesaParteDespachadosV1 116,642,null,null,1,10,'000228'
-- exec tramite.paListarExpedienteMesaParteDespachadosV1_new 116,642,null,null,1,10,'000228'


-- exec tramite.paListarExpedienteMesaParteDespachadosV1 @p1, @p2, @p3, @p4, @p5, @p6, @p7
-- exec tramite.paListarExpedienteMesaParteDespachadosV1_new @p1, @p2, @p3, @p4, @p5, @p6, @p7


-- drop table dbo.paListarExpedienteMesaParteDespachadosV1
-- go
-- create table dbo.paListarExpedienteMesaParteDespachadosV1(
--     col1 int,
--     col2 int,
--     col3 varchar(50),
--     col4 varchar(4),
--     col5 int,
--     col6 int,
--     col7 varchar(100)
-- )
-- go
-- insert into dbo.paListarExpedienteMesaParteDespachadosV1
-- select 116,642,null,null,1,10,'000228'

-- select col1, col2, col3, col4, col5, col6, col7 from dbo.paListarExpedienteMesaParteDespachadosV1





-- =======================================================================================================
-- =======================================================================================================
--
exec Tramite.paListarExpedientePendienteEspecialistaPorRecibir 0,'24/03/2026','24/03/2026',0,'24/03/2026','24/03/2026',845,2051,4,4,0,0,2026,0,0,0,'','','','',0,'','','',845,null,null,1,10,null,0
exec Tramite.paListarExpedientePendienteEspecialistaPorRecibir_new 0,'24/03/2026','24/03/2026',0,'24/03/2026','24/03/2026',845,2051,4,4,0,0,2026,0,0,0,'','','','',0,'','','',845,null,null,1,10,null,0

-- go
-- drop table dbo.paListarExpedientePendienteEspecialistaPorRecibir
-- go
-- create table dbo.paListarExpedientePendienteEspecialistaPorRecibir(
--     col1 bit,
-- 	col2 varchar(10),
-- 	col3 varchar(10),
-- 	col4 bit,
-- 	col5 varchar(10),
-- 	col6 varchar(10),
-- 	col7 int,
-- 	col8 int,
-- 	col9  int,
-- 	col10 int,
-- 	col11 int,
--     col12 int,
--     col13 int,
--     col14 int,
--     col15 int,
--     col16 int,
--     col17 varchar(100),
--     col18 varchar(100),
-- 	col19 varchar(100),
-- 	col20 varchar(100),
-- 	col21 int,
-- 	col22 varchar(100),
-- 	col23 varchar(100),
-- 	col24 varchar(100),
-- 	col25 int,
-- 	col26 varchar(50),
-- 	col27 varchar(4),
-- 	col28 INT,
-- 	col29  INT,
-- 	col30 varchar(100),
-- 	col31 INT)
-- insert into dbo.paListarExpedientePendienteEspecialistaPorRecibir
-- select 0,'24/03/2026','24/03/2026',0,'24/03/2026','24/03/2026',845,2051,4,4,0,0,2026,0,0,0,'','','','',0,'','','',845,null,null,1,10,null,0

-- select col1, col2, col3, col4, col5, col6, col7, col8, col9, col10, col11, col12, col13, col14, col15, col16, col17, col18, col19, col20, col21, col22, col23, col24, col25, col26, col27, col28, col29, col30, col31 from dbo.paListarExpedientePendienteEspecialistaPorRecibir





-- =======================================================================================================
-- =======================================================================================================
--
-- exec [Tramite].[paListarExpedienteMesaParteDespachadosVirtualesV1] 56784, null, null, 1, 10, 'BONIFICA'
-- exec [Tramite].[paListarExpedienteMesaParteDespachadosVirtualesV1_new] 56784, null, null, 1, 10, 'BONIFICA'
