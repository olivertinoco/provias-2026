CREATE VIEW [RecursoHumano].[visPersonaJefe]
AS
SELECT  DISTINCT
    a.NombreArea, pe.NombreCompleto, u.Email, a.IdCatalogoTipoArea, cta.Descripcion AS CatalogoTipoArea, pe.IdPersona, cp.IdArea,
    cp.IdCargo, E.IdEmpresa, CA.NombreCargo, cp.IdEmpleadoPerfil,
    E.NombreEmpresa, a.IdAreaPadre, CA.Abreviatura, CA.IdCatalogoTipoCargo,a.VerRecepcion
FROM RecursoHumano.Empleado AS c
INNER JOIN RecursoHumano.EmpleadoPerfil AS cp ON c.IdEmpleado = cp.IdEmpleado AND cp.EstadoAuditoria = 1 AND cp.Activo = 1
INNER JOIN General.Cargo AS CA ON CA.IdCargo = cp.IdCargo
INNER JOIN General.Persona AS pe ON pe.IdPersona = c.IdPersona
INNER JOIN Seguridad.Usuario AS u ON u.IdPersona = pe.IdPersona AND u.EstadoAuditoria = 1 AND u.Bloqueado = 0
INNER JOIN General.Area AS a ON a.IdArea = cp.IdArea
INNER JOIN General.Catalogo AS cta ON cta.IdCatalogo = a.IdCatalogoTipoArea
INNER JOIN General.EmpresaSede ES ON cp.IdEmpresaSede = ES.IdEmpresaSede
INNER JOIN General.Empresa E ON E.IdEmpresa=ES.IdEmpresa
WHERE (c.EstadoAuditoria = 1) AND (cp.EstadoAuditoria = 1) AND (cp.Activo = 1) AND (c.Activo = 1) AND (u.EsInstitucion = 1)
AND CA.IdCatalogoTipoCargo IN (32,33,34)
