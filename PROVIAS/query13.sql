declare @IdAreaPadre int = 74




;WITH Areas AS
	(
		SELECT IdAreaPadre, IdArea, NombreArea, 0 AS Nivel
		FROM General.Area
		WHERE IdAreaPadre = @IdAreaPadre
		UNION ALL
		SELECT e.IdAreaPadre, e.IdArea, e.NombreArea, Nivel + 1
		FROM General.Area AS e
		INNER JOIN Areas AS d
		ON e.IdAreaPadre = d.IdArea
		WHERE d.IdArea <> @IdAreaPadre
	)
select*from Areas
order by IdArea


select*from dbo.areas_prueba02
WHERE IdAreaPadre = @IdAreaPadre





-- ;WITH Areas AS
-- (
--     -- Nivel raíz: todas las áreas sin padre
--     SELECT
--         IdAreaPadre,
--         IdArea,
--         NombreArea,
--         0 AS Nivel
--     FROM General.Area
--     WHERE IdAreaPadre = 0

--     UNION ALL

--     -- Nivel hijo
--     SELECT
--         e.IdAreaPadre,
--         e.IdArea,
--         e.NombreArea,
--         Nivel + 1
--     FROM General.Area AS e
--     INNER JOIN Areas AS d
--         ON e.IdAreaPadre = d.IdArea
-- )
-- SELECT * into dbo.areas_prueba02
-- FROM Areas
-- ORDER BY Nivel, IdArea;
