public async Task<ListaExpediente> ListarExpedienteMesaParteDespachados(int Gestor, int IdArea, int IdUsuarioAuditoria, string CampoOrdenado, string TipoOrdenacion, int NumeroPagina, int DimensionPagina, string BusquedaGeneral)
{
    DataSet ds = new DataSet();
    DataTable dt = new DataTable();
    try
    {
        if (Gestor == DatosGlobales.GestorSqlServer)
        {
            //ds = await ConexionSqlServer.GDatos.TraerDataSetAsync(DatosGlobales.ListaConexiones.cnTramiteSql, "Tramite.paListarExpedienteMesaParteDespachadosV1", IdArea, IdUsuarioAuditoria, CampoOrdenado, TipoOrdenacion, NumeroPagina, DimensionPagina, BusquedaGeneral);
            ds = await ConexionSqlServer.GDatos.TraerDataSetAsync(DatosGlobales.ListaConexiones.cnTramiteSql, "Tramite.paListarExpedienteMesaParteDespachadosV1", IdArea, IdUsuarioAuditoria, CampoOrdenado, TipoOrdenacion, NumeroPagina, DimensionPagina, BusquedaGeneral);

            if (Convert.ToInt32(ds.ExtendedProperties["NumeroError"].ToString()) > 0)
            {
                lista.mensaje.CodigoMensaje = 1;
                lista.mensaje.DescripcionMensajeSistema = ds.ExtendedProperties["NumeroError"].ToString();
                lista.mensaje.DescripcionMensaje = "SUCEDIO UN ERROR EN LA CAPA DE DATOS [ListarExpediente], VERIFIQUE CONSOLA";
                return lista;
            }
            if (ds.Tables.Count > 0)
            {
                dt = ds.Tables[0].Copy();
                DataTable dtParametros = null;
                dtParametros = ds.Tables[1].Copy();
                lista.paginacion.TotalRegistros = Convert.ToInt32(dtParametros.Rows[0][0]);
            }
        }
        if (dt.Rows.Count > 0)
        {
            Expediente expediente = null;
            foreach (DataRow row in dt.Rows)
            {
                expediente = new Expediente();
                expediente.IdExpediente = (int)row["IdExpediente"];
                expediente.ExpedienteConfidencial = (bool)row["ExpedienteConfidencial"];
                expediente.FgTramiteVirtual = (bool)row["FgTramiteVirtual"];

                expediente.NombreExpediente = (string)row["NombreExpediente"];
                expediente.NTFechaExpediente = (string)row["NTFechaExpediente"];
                expediente.HoraExpediente = (string)row["HoraExpediente"];
                expediente.catalogotipoprioridad.Descripcion = (string)row["CatalogoTipoPrioridad"];
                expediente.catalogotipoprioridad.IdCatalogo = (int)row["IdCatalogoTipoPrioridad"];
                expediente.catalogotipotramite.Descripcion = (string)row["CatalogoTipoTramite"];
                expediente.AsuntoExpediente = (string)row["AsuntoExpediente"];
                expediente.NumeroFoliosExpediente = (int)row["NumeroFoliosExpediente"];
                expediente.ObservacionesExpediente = (string)row["ObservacionesExpediente"];
                expediente.IdExpedienteDocumento = (int)row["IdExpedienteDocumento"];
                expediente.IdExpedienteDocumentoOrigen = (int)row["IdExpedienteDocumentoOrigen"];
                expediente.NumeroDocumento = (string)row["NumeroDocumento"];
                expediente.ParaAnular = (int)row["ParaAnular"];
                expediente.FechaEnvioDocumento = row["FechaEnvioDocumento"] is System.DBNull ? "" : ((DateTime)row["FechaEnvioDocumento"]).ToString();

                lista.lista.Add(expediente);
            }
        }
        return lista;
    }
    catch (Exception ex)
    {
        lista.mensaje.CodigoMensaje = 1;
        lista.mensaje.DescripcionMensaje = ex.Message;
        return lista;
    }
    finally
    {
        ds.Dispose();
        ds.Clear();
        dt.Dispose();
        dt.Clear();
    }
}
