IF OBJECT_ID ('dbo.fCfdiDocumentoDePagoRelacionado') IS NOT NULL
   DROP FUNCTION dbo.[fCfdiDocumentoDePagoRelacionado]
GO

create function [dbo].[fCfdiDocumentoDePagoRelacionado] (@RMDTYPAL smallint, @DOCNUMBR varchar(21))
returns table 
as
--Propósito. Devuelve documentos relacionados 
--Requisitos. -
--20/11/2017 jcf Creación cfdi
--
return
	(
        SELECT 
		RMDTYPAL, DOCNUMBR, APTODCNM, MonedaP, TipoCambioP, 
        IdDocumento,
		MonedaDR,
		TipoCambioDR,
		'PPD' MetodoDePagoDR,
		NumParcialidad,
		--nfa.numFacturas,
		line.ororgtrx,
		ImpSaldoAntMonFac ImpSaldoAnt,
		ImpPagadoMonFac	ImpPagado,
		ImpSaldoInsolutoMonFac ImpSaldoInsoluto,

		line.ImpPagado ImpPagadoFuncional

		from dbo.vwCfdiRMFacturas line
        WHERE  line.DOCNUMBR = @DOCNUMBR
		and line.RMDTYPAL = @RMDTYPAL
	)
go



IF (@@Error = 0) PRINT 'Creación exitosa de: [fCfdiDocumentoDePagoRelacionado]()'
ELSE PRINT 'Error en la creación de: [fCfdiDocumentoDePagoRelacionado]()'
GO
--select [dbo].[fCfdiDocumentoDePagoRelacionado] (9, 'PYMNT00000029')