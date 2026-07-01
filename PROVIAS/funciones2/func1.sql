CREATE function [Seguridad].[funObtenerRutaFotoPorIdPersona]
(@pIdPersona INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @Lista  varchar(50)='sinfotoH.jpg'
	SELECT @Lista=case when COALESCE(U.RutaArchivoFoto,'') ='' then
	CASE WHEN COALESCE(Pr.Sexo,0)=0 then 'sinfotoH.jpg' else 'sinfotoM.jpg' end else U.RutaArchivoFoto end
	FROM Seguridad.Usuario U
	INNER JOIN General.Persona PR ON PR.IdPersona=U.IdPersona
	WHERE U.EstadoAuditoria=1 and pr.IdPersona=@pIdPersona AND U.Bloqueado=0
	RETURN @Lista

END
