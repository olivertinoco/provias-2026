CREATE function Tramite.funDevolverPeriodoDocumento
	(@pFechaActual DATETIME,
	@FechaCreacionAuditoria DATETIME
	)
	RETURNS varchaR(4)
	AS
	BEGIN
		DECLARE @PeridoDevuelto varchaR(4)=''
		IF YEAR(@FechaCreacionAuditoria)=YEAR(@pFechaActual)
		BEGIN
			IF MONTH(@FechaCreacionAuditoria)=MONTH(@pFechaActual)
			BEGIN
				--PRINT 1
				SET @PeridoDevuelto=''
			END
			ELSE
			BEGIN
				--PRINT 2
				IF MONTH(DATEADD(DAY,30,@FechaCreacionAuditoria))=MONTH(@pFechaActual)
				BEGIN
					--PRINT 3
					SET @PeridoDevuelto=''
				END
				ELSE
				BEGIN
					--PRINT 4
					SET @PeridoDevuelto=CONVERT(VARCHAR,YEAR(@FechaCreacionAuditoria) )
				END
			END
		END
		ELSE
		BEGIN
			IF YEAR(DATEADD(DAY,30,@FechaCreacionAuditoria))=YEAR(@pFechaActual)
			BEGIN
				--PRINT 5
				IF MONTH(DATEADD(DAY,30,@FechaCreacionAuditoria))=MONTH(@pFechaActual)
				BEGIN
					SET @PeridoDevuelto=CONVERT(VARCHAR,YEAR(@FechaCreacionAuditoria) )
				END
				ELSE
				BEGIN
				--PRINT 6
					SET @PeridoDevuelto=''
				END
			END
			ELSE
			BEGIN
				--PRINT 7
				SET @PeridoDevuelto=CONVERT(VARCHAR,YEAR(@FechaCreacionAuditoria) )
			END
		END
		RETURN @PeridoDevuelto
	END
