USE [PRD01]
GO

/****** Object:  View [dbo].[TII_BI_WIN_ALERTA_INVENTARIOVALORIZADO_MO]    Script Date: 30/8/2018 11:31:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
Fecha:		22/02/2010
Autor:		Eduardo Salv�
Detalle:	Devuelve informacion acerca del valor del inventario en moneda original.
			Se toma informacion del campo 'Categoria definible por el usuario 1' y se utiliza
			la funcion TII_Obtener_Tasa.
			El costo se calcula para todas las lineas por la utilizacion del modulo de LC.
*/
ALTER VIEW [dbo].[TII_BI_WIN_ALERTA_INVENTARIOVALORIZADO_MO]
AS
SELECT ID_ARTICULO
	, DESCRIPCION
	, DESPACHO
	, FECHA_RECEPCION
	, CANTIDAD_STOCK
	, TC
	, MONEDA_COMPRA
	, ROUND((COSTO_UNITARIO_PESOS / TC), 2) AS COSTO_UNITARIO_ORIGINAL
	, ROUND(((CANTIDAD_STOCK * COSTO_UNITARIO_PESOS) / TC), 2) AS COSTO_TOTAL_ORIGINAL
	, DEPOSITO
	, CANTIDAD_RECIBIDA
	, CANTIDAD_COMPROMETIDA
	, CANTIDAD_VENDIDA
	, COSTO_UNITARIO_PESOS
	, ROUND((CANTIDAD_STOCK * COSTO_UNITARIO_PESOS), 2)	AS COSTO_TOTAL_PESOS
	, ID_PROVEEDOR
	, NRO_RECEPCION
	, RECEPCION
	, CATEGORIA
	, SUBCATEGORIA
FROM (SELECT A.ITEMNMBR		AS ID_ARTICULO, 
		A.ITEMDESC				AS DESCRIPCION,
		A.USCATVLS_1			AS MONEDA_COMPRA, 
		B.LOCNCODE				AS DEPOSITO, 
		B.DATERECD				AS FECHA_RECEPCION, 
		B.LOTNUMBR				AS DESPACHO, 
		B.QTYRECVD				AS CANTIDAD_RECIBIDA, 
		B.QTYSOLD				AS CANTIDAD_VENDIDA, 
		B.QTYRECVD - B.QTYSOLD	AS CANTIDAD_STOCK,
		B.ATYALLOC				AS CANTIDAD_COMPROMETIDA, 
		B.UNITCOST				AS COSTO_UNITARIO_PESOS, 
		B.RCTSEQNM				AS NRO_RECEPCION, 
		B.VNDRNMBR				AS ID_PROVEEDOR, 
		CASE 
			WHEN D.XCHGRATE IS NOT NULL AND D.XCHGRATE <> 0 THEN ISNULL(D.XCHGRATE, 1)
			WHEN D.XCHGRATE IS NULL AND A.USCATVLS_1 = 'ARS' THEN 1
			ELSE dbo.TII_Obtener_Tasa (B.DATERECD, A.USCATVLS_1)	
		END						AS TC, 
		C.RCPTNMBR				AS RECEPCION,
		A.USCATVLS_6			AS CATEGORIA,
		A.USCATVLS_5			AS SUBCATEGORIA
	FROM IV00101 A																		-- Maestro de art�culos
		INNER JOIN IV00300 B ON A.ITEMNMBR = B.ITEMNMBR									-- Maestro de numeros de lote de articulos
		INNER JOIN IV10200 C ON B.ITEMNMBR = C.ITEMNMBR AND B.RCTSEQNM = C.RCTSEQNM		-- Transacciones de inventario
		LEFT OUTER JOIN	POP30300 D ON C.RCPTNMBR = D.POPRCTNM							-- Transacciones de compra
	WHERE B.QTYRECVD - B.QTYSOLD <> 0			-- Lotes con cantidades remanentes
	AND ISNULL(D.VOIDSTTS, 0) = 0) X

GO


