declare
    @pIdEmpresa int = 2,
	@pIdArea int = 79,
	@pIdCargo int = 407,
	@pIdPersona int = 226,
	@pIdCatalogoTipoDocumento int = 530,
	@pFlagParaDespacho bit = 1,
	@pNumeroDocumento varchar(200) = '',
	@pCorrelativo int = 0 ,
	@DescripcionMensaje varchaR(400) ,
	@CodigoMensaje int ,
	@vNumeroDocumento int=0,
	@vDescripcionDocumento varchar(100)='',
	@vSiglaArea varchar(100)='',
	@vSigla varchar(100)=''

	select
	@pIdEmpresa pIdEmpresa,
	@pIdArea pIdArea,
    @pIdCargo pIdCargo,
    @pIdPersona pIdPersona,
    @pIdCatalogoTipoDocumento pIdCatalogoTipoDocumento,
    @pFlagParaDespacho pFlagParaDespacho,
    @pNumeroDocumento pNumeroDocumento,
    @pCorrelativo pCorrelativo,
    @DescripcionMensaje DescripcionMensaje,
    @CodigoMensaje CodigoMensaje,
    @vNumeroDocumento vNumeroDocumento,
    @vDescripcionDocumento vDescripcionDocumento,
    @vSiglaArea vSiglaArea,
    @vSigla vSigla into #tmp001_param
	update t set vSigla=NombreCompleto from General.Persona, #tmp001_param t where pIdPersona = IdPersona

	select @DescripcionMensaje=
	concat('select 9999, (select left(a,1) from(values(''', replace(vSigla, ' ', '''),('''),
	'''))t(a)for xml path,type).value(''.'',''varchar(max)'')')
	from #tmp001_param
	insert into #tmp001_param(pIdEmpresa, vSigla) exec(@DescripcionMensaje)
	update t set t.vSigla = (select vSigla from #tmp001_param where pIdEmpresa = 9999) from #tmp001_param t where pIdEmpresa != 9999
	delete #tmp001_param where pIdEmpresa = 9999
	update t set t.vSiglaArea = sigla from general.area, #tmp001_param t where idarea = t.pIdArea

	update t set t.vDescripcionDocumento=Descripcion from Tramite.Catalogo, #tmp001_param t where IdCatalogo=t.pIdCatalogoTipoDocumento

	if exists(select 1 from #tmp001_param where vSiglaArea = '')begin
	    select @DescripcionMensaje = 'NO SE HA ENCONTRADO LAS SIGLAS PARA EL AREA, VUELVA A INTENTAR'
		select @CodigoMensaje=1
		return
	end

	select @vNumeroDocumento=COALESCE(max(tt.Correlativo),0)+1
	from tramite.expediente t
	cross apply tramite.expedienteDocumento tt
	cross apply tramite.expedienteDocumentoOrigen ttt
	cross apply #tmp001_param pp
	where t.idExpediente = tt.idExpediente and t.estadoAuditoria = 1 and t.ExpedienteAnulado != 1 and
	tt.idExpedienteDocumento = ttt.idExpedienteDocumento and tt.estadoAuditoria = 1 and ttt.estadoAuditoria = 1 and
	year(tt.NfechaDocumento) = year(getdate())
	and tt.IdCatalogoTipoDocumento= pp.pIdCatalogoTipoDocumento
	and tt.IdEmpresaEmisor=pp.pIdEmpresa
	and tt.IdAreaEmisor=pp.pIdArea
	and tt.IdPersonaEmisor=pp.pIdPersona
	and tt.IdCargoEmisor=@pIdCargo


	SET @pCorrelativo=@pNumeroDocumento

	IF @pFlagParaDespacho=1
	BEGIN
		SET @pNumeroDocumento='-'+CONVERT(VARCHAR(4),YEAR(GETDATE()))+'-'+@vSiglaArea+'-'+@vSigla
	END
	ELSE
	BEGIN
		SET @pNumeroDocumento=@vDescripcionDocumento+' N°-'+CONVERT(VARCHAR(4),YEAR(GETDATE()))+'-'+@vSiglaArea+'-'+@vSigla
		SET @pCorrelativo=0
	END

	print @pCorrelativo
	print @pNumeroDocumento
