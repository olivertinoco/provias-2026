select t.IdExpediente
			from tramite.expediente t
			where t.EstadoAuditoria = 1
			    and t.ExpedienteAnulado = 0
				and t.IdPeriodo = @anno
				and t.IdCatalogoTipoMovimientoTramite = 13
				and t.IdCatalogoSituacionExpediente = 62
				and t.FgTramiteVirtual = 1
      		and	exists(
      			    select 1
         				from tramite.ExpedienteDocumentoOrigen t3
         				inner join tramite.ExpedienteDocumento t2
        				        on t2.IdExpedienteDocumento = t3.IdExpedienteDocumento and t2.EstadoAuditoria = 1
                         where t2.IdExpediente = t.IdExpediente
                             and t3.EstadoAuditoria = 1
                        	    and t2.FgDocumentoVirtualEnviado = 1
                             and t2.FgEsObservado = 0
                             and t2.FgEnvioCorregido = 0
                             and not exists(
                                 select 1
                                 from tramite.ExpedienteDocumentoOrigenDestino t4
                                 where t4.IdExpedienteDocumentoOrigen = t3.IdExpedienteDocumentoOrigen
                                     and t4.EstadoAuditoria = 1
                                 )
             				and	(
           						   CONTAINS(t2.AsuntoDocumento, @pBusquedaGeneralfText)
           						or CONTAINS(t2.NumeroDocumento, @pBusquedaGeneralfText)
           						or CONTAINS(t2.NombreCompletoEmisor, @pBusquedaGeneralfText)
          					  )
      			);
