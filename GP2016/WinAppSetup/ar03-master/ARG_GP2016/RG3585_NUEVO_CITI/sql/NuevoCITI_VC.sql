
GO

/****** Object:  StoredProcedure [dbo].[NuevoCITI_VC]    Script Date: 21/08/2018 14:58:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON

GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[NuevoCITI_VC]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[NuevoCITI_VC]
go







/****** Object:  Stored Procedure dbo.NuevoCITI_VC    Script Date: 14/6/2015 12:34:37 PM ******/

CREATE PROCEDURE [dbo].[NuevoCITI_VC] @PERIODO CHAR(6), @REPORTE CHAR(15)
AS

CREATE TABLE #TEMPA
	(
		DOCNUMBR CHAR(21),
		RMDTYPAL SMALLINT,
		CUSTNMBR CHAR(15),
		DOCDATE datetime,
		COMPTYPE CHAR(3),
		PDV CHAR(5),
		NROCOMP CHAR(20),
		CODDOC CHAR(2),
		NROIDENT	CHAR(20),
		NOMBRE	CHAR(30),
		TOTAL	NUMERIC(19, 5),
		GRAV	NUMERIC(19, 5),
		NOGRAV	NUMERIC(19, 5),
		IVA NUMERIC(19, 5),
		EXENTO	NUMERIC(19, 5),
		PERCIVA NUMERIC(19, 5),
		PERCIIBB	NUMERIC(19, 5),
		MONEDA	CHAR(3),
		CAMBIO	NUMERIC(19, 7),
		ALICUOTAS	INT,
		CODOPER	CHAR(1),
		DUEDATE datetime
	)

CREATE TABLE #TEMP
	(
		DOCNUMBR CHAR(21),
		RMDTYPAL SMALLINT,
		CUSTNMBR CHAR(15),
		DOCDATE datetime,
		COMPTYPE CHAR(3),
		PDV CHAR(5),
		NROCOMP CHAR(20),
		CODDOC CHAR(2),
		NROIDENT	CHAR(20),
		NOMBRE	CHAR(30),
		TOTAL	NUMERIC(19, 5),
		GRAV	NUMERIC(19, 5),
		NOGRAV	NUMERIC(19, 5),
		IVA NUMERIC(19, 5),
		EXENTO	NUMERIC(19, 5),
		PERCIVA NUMERIC(19, 5),
		PERCIIBB	NUMERIC(19, 5),
		MONEDA	CHAR(3),
		CAMBIO	NUMERIC(19, 7),
		ALICUOTAS	INT,
		CODOPER	CHAR(1),
		DUEDATE datetime
	)

CREATE TABLE #TEMP2
	(
		DOCNUMBR CHAR(21),
		RMDTYPAL SMALLINT,
		CUSTNMBR CHAR(15),
		COMPTYPE CHAR(3),
		PDV CHAR(5),
		NROCOMP CHAR(20),
		CODDOC CHAR(2),
		NROIDENT	CHAR(20),
		GRAVADO	NUMERIC(19, 5),
		ALICUOTA	NUMERIC(19, 5),
		IMPUESTO NUMERIC(19, 5)
	)

INSERT INTO #TEMPA
SELECT A.DOCNUMBR, A.RMDTYPAL, A.CUSTNMBR, ISNULL(TRX.DOCDATE, CC.DOCDATE) DOCDATE, '0' + ISNULL(ISNULL(AW2.COD_COMP, AW3.COD_COMP), '00') COMTYPE, '0' + ISNULL(SUBSTRING(A.DOCNUMBR, ISNULL(AW2.Pos_PDV, AW4.Pos_PDV), 4), '0000') PDV,
'000000000000' + ISNULL(SUBSTRING(A.DOCNUMBR, ISNULL(AW2.Pos_NRO, AW4.Pos_NRO), 8), '0000') NROCOMP, 
RIGHT(ISNULL(TRX.TXRGNNUM, CM.TXRGNNUM), 2) CODCOC, RTRIM(LEFT(ISNULL(TRX.TXRGNNUM, CM.TXRGNNUM), 11)) NROIDENT,
LEFT(RTRIM(ISNULL(TRX.CUSTNAME, CM.CUSTNAME)) + REPLICATE(' ', 30), 30) NOMBRE, ISNULL(TRX.DOCAMNT, CC.ORTRXAMT) DOCAMNT,
CASE WHEN CI.ColumnaArchivo = 1 THEN A.TDTTXSLS ELSE 0 END GRAV,							
CASE WHEN CI.ColumnaArchivo = 4 THEN A.TDTTXSLS ELSE 0 END NOGRAV,						
CASE WHEN CI.ColumnaArchivo = 2 THEN A.TAXAMNT  ELSE 0 END IVA,							
CASE WHEN CI.ColumnaArchivo = 3 THEN A.TDTTXSLS ELSE 0 END EXENTO,						
CASE WHEN CI.ColumnaArchivo = 6 THEN A.TAXAMNT  ELSE 0 END PERCIVA,						
CASE WHEN CI.ColumnaArchivo = 8 THEN A.TAXAMNT  ELSE 0 END PIIBB,						
MC.CURR_CODE MONEDA, ISNULL(MC1.XCHGRATE, 1) TCAMBIO, 0 ALICUOTAS, CONVERT(VARCHAR, ISNULL(AW.OP_ORIGIN, 0)) CODOPER, CASE WHEN A.RMDTYPAL > 6 THEN CC.DOCDATE ELSE CC.DUEDATE END DUEDATE 
FROM RM10601 A
INNER JOIN RM20101 CC ON A.RMDTYPAL = CC.RMDTYPAL AND A.DOCNUMBR = CC.DOCNUMBR
LEFT OUTER JOIN SOP30200 TRX ON A.DOCNUMBR = TRX.SOPNUMBE AND CASE WHEN A.RMDTYPAL = 1 THEN 3 ELSE 4 END = TRX.SOPTYPE
INNER JOIN AWLI_RM00101 AW ON A.CUSTNMBR = AW.CUSTNMBR
LEFT OUTER JOIN AWLI40380 AW2 ON TRX.SOPTYPE = AW2.SOPTYPE AND TRX.DOCID = AW2.DOCID
CROSS JOIN AWLI40300 AW4
LEFT OUTER JOIN AWLI40370 AW3 ON A.RMDTYPAL = AW3.RMDTYPAL AND 2 = AW3.TipoReporte AND SUBSTRING(A.DOCNUMBR, ISNULL(AW2.Pos_Letra, AW4.Pos_Letra), 1) = CASE AW3.LETRA WHEN 1 THEN 'A' WHEN 2 THEN 'B' WHEN 4 THEN 'E' END
INNER JOIN RM00101 CM ON A.CUSTNMBR = CM.CUSTNMBR
INNER JOIN DYNAMICS..AWLI_MC40200 MC ON ISNULL(TRX.CURNCYID, CC.CURNCYID) = MC.CURNCYID
INNER JOIN
(SELECT A.RPTID, A.DSCRIPTN, A.NRORDCOL, A.IDTAXOP, B.TAXDTLID, C.TXDTLDSC FROM AWLI40004 A INNER JOIN AWLI40102 B ON A.IDTAXOP = B.IDTAXOP
INNER JOIN TX00201 C ON B.TAXDTLID = C.TAXDTLID
where rptid IN(@REPORTE)	 ) TX ON A.TAXDTLID = TX.TAXDTLID
INNER JOIN tblColumnasIVA CI ON TX.RPTID = CI.RPTID AND TX.NRORDCOL = CI.NRORDCOL
INNER JOIN TX00201 B ON TX.TAXDTLID = B.TAXDTLID
LEFT OUTER JOIN MC020102 MC1 ON A.DOCNUMBR = MC1.DOCNUMBR AND A.RMDTYPAL = MC1.RMDTYPAL AND A.CUSTNMBR = MC1.CUSTNMBR
WHERE ISNULL(TRX.VOIDSTTS, CC.VOIDSTTS) = 0 and left(CONVERT(char(8), ISNULL(TRX.DOCDATE, CC.DOCDATE), 112), 6) = @PERIODO AND CI.TipoReporte = 2

INSERT INTO #TEMPA
SELECT A.DOCNUMBR, A.RMDTYPAL, A.CUSTNMBR, ISNULL(TRX.DOCDATE, CC.DOCDATE) DOCDATE, '0' + ISNULL(ISNULL(AW2.COD_COMP, AW3.COD_COMP), '00') COMTYPE, '0' + ISNULL(SUBSTRING(A.DOCNUMBR, ISNULL(AW2.Pos_PDV, AW4.Pos_PDV), 4), '0000') PDV,
'000000000000' + ISNULL(SUBSTRING(A.DOCNUMBR, ISNULL(AW2.Pos_NRO, AW4.Pos_NRO), 8), '0000') NROCOMP, 
RIGHT(ISNULL(TRX.TXRGNNUM, CM.TXRGNNUM), 2) CODCOC, RTRIM(LEFT(ISNULL(TRX.TXRGNNUM, CM.TXRGNNUM), 11)) NROIDENT,
LEFT(RTRIM(ISNULL(TRX.CUSTNAME, CM.CUSTNAME)) + REPLICATE(' ', 30), 30) NOMBRE, ISNULL(TRX.DOCAMNT, CC.ORTRXAMT) DOCAMNT,
CASE WHEN CI.ColumnaArchivo = 1 THEN A.TDTTXSLS ELSE 0 END GRAV,							
CASE WHEN CI.ColumnaArchivo = 4 THEN A.TDTTXSLS ELSE 0 END NOGRAV,						
CASE WHEN CI.ColumnaArchivo = 2 THEN A.TAXAMNT  ELSE 0 END IVA,							
CASE WHEN CI.ColumnaArchivo = 3 THEN A.TDTTXSLS ELSE 0 END EXENTO,						
CASE WHEN CI.ColumnaArchivo = 6 THEN A.TAXAMNT  ELSE 0 END PERCIVA,						
CASE WHEN CI.ColumnaArchivo = 8 THEN A.TAXAMNT  ELSE 0 END PIIBB,						
MC.CURR_CODE MONEDA, ISNULL(MC1.XCHGRATE, 1) TCAMBIO, 0 ALICUOTAS, CONVERT(VARCHAR, ISNULL(AW.OP_ORIGIN, 0)) CODOPER, CASE WHEN A.RMDTYPAL > 6 THEN CC.DOCDATE ELSE CC.DUEDATE END DUEDATE 
FROM RM30601 A
INNER JOIN RM30101 CC ON A.RMDTYPAL = CC.RMDTYPAL AND A.DOCNUMBR = CC.DOCNUMBR
LEFT OUTER JOIN SOP30200 TRX ON A.DOCNUMBR = TRX.SOPNUMBE AND CASE WHEN A.RMDTYPAL = 1 THEN 3 ELSE 4 END = TRX.SOPTYPE
INNER JOIN AWLI_RM00101 AW ON A.CUSTNMBR = AW.CUSTNMBR
LEFT OUTER JOIN AWLI40380 AW2 ON TRX.SOPTYPE = AW2.SOPTYPE AND TRX.DOCID = AW2.DOCID
CROSS JOIN AWLI40300 AW4
LEFT OUTER JOIN AWLI40370 AW3 ON A.RMDTYPAL = AW3.RMDTYPAL AND 2 = AW3.TipoReporte AND SUBSTRING(A.DOCNUMBR, ISNULL(AW2.Pos_Letra, AW4.Pos_Letra), 1) = CASE AW3.LETRA WHEN 1 THEN 'A' WHEN 2 THEN 'B' WHEN 4 THEN 'E' END 
INNER JOIN RM00101 CM ON A.CUSTNMBR = CM.CUSTNMBR
INNER JOIN DYNAMICS..AWLI_MC40200 MC ON ISNULL(TRX.CURNCYID, CC.CURNCYID) = MC.CURNCYID
INNER JOIN
(SELECT A.RPTID, A.DSCRIPTN, A.NRORDCOL, A.IDTAXOP, B.TAXDTLID, C.TXDTLDSC FROM AWLI40004 A INNER JOIN AWLI40102 B ON A.IDTAXOP = B.IDTAXOP
INNER JOIN TX00201 C ON B.TAXDTLID = C.TAXDTLID
where rptid IN(@REPORTE)	 ) TX ON A.TAXDTLID = TX.TAXDTLID
INNER JOIN tblColumnasIVA CI ON TX.RPTID = CI.RPTID AND TX.NRORDCOL = CI.NRORDCOL
INNER JOIN TX00201 B ON TX.TAXDTLID = B.TAXDTLID
LEFT OUTER JOIN MC020102 MC1 ON A.DOCNUMBR = MC1.DOCNUMBR AND A.RMDTYPAL = MC1.RMDTYPAL AND A.CUSTNMBR = MC1.CUSTNMBR
WHERE ISNULL(TRX.VOIDSTTS, CC.VOIDSTTS) = 0 and left(CONVERT(char(8), ISNULL(TRX.DOCDATE, CC.DOCDATE), 112), 6) = @PERIODO AND CI.TipoReporte = 2

INSERT INTO #TEMP
SELECT 		DOCNUMBR,
		RMDTYPAL,
		CUSTNMBR,
		DOCDATE,
		COMPTYPE,
		PDV,
		NROCOMP,
		CODDOC,
		NROIDENT,
		NOMBRE,
		TOTAL,
		SUM(GRAV) GRAV,
		SUM(NOGRAV) NOGRAV,
		SUM(IVA) IVA,
		SUM(EXENTO) EXENTO,
		SUM(PERCIVA) PERCIVA,
		SUM(PERCIIBB) PERCIIBB,
		MONEDA,
		CAMBIO,
		ALICUOTAS,
		CODOPER,
		DUEDATE
FROM #TEMPA
GROUP BY 	DOCNUMBR,
		RMDTYPAL,
		CUSTNMBR,
		DOCDATE,
		COMPTYPE,
		PDV,
		NROCOMP,
		CODDOC,
		NROIDENT,
		NOMBRE,
		TOTAL,
		MONEDA,
		CAMBIO,
		ALICUOTAS,
		CODOPER,
		DUEDATE

UPDATE #TEMP
SET ALICUOTAS = TX.ALICUOTAS
FROM #TEMP A
INNER JOIN (
SELECT A.DOCNUMBR, A.RMDTYPAL, A.CUSTNMBR, COUNT(A.ALICUOTAS) ALICUOTAS FROM
(SELECT DISTINCT A.DOCNUMBR, A.RMDTYPAL, A.CUSTNMBR, B.TXDTLPCT ALICUOTAS FROM RM10601 A INNER JOIN
(SELECT A.RPTID, A.DSCRIPTN, A.NRORDCOL, A.IDTAXOP, B.TAXDTLID, C.TXDTLDSC, CI.ColumnaArchivo FROM AWLI40004 A INNER JOIN AWLI40102 B ON A.IDTAXOP = B.IDTAXOP
INNER JOIN tblColumnasIVA CI ON A.RPTID = CI.RPTID AND A.NRORDCOL = CI.NRORDCOL
INNER JOIN TX00201 C ON B.TAXDTLID = C.TAXDTLID
where A.rptid IN(@REPORTE) AND CI.TipoReporte = 2 AND CI.ColumnaArchivo = 2 ) TX ON A.TAXDTLID = TX.TAXDTLID
INNER JOIN TX00201 B ON TX.TAXDTLID = B.TAXDTLID
WHERE TX.ColumnaArchivo = 2 AND A.TAXAMNT <> 0) A 
GROUP BY A.DOCNUMBR, A.RMDTYPAL, A.CUSTNMBR ) TX
ON A.DOCNUMBR = TX.DOCNUMBR AND A.RMDTYPAL = TX.RMDTYPAL AND A.CUSTNMBR = TX.CUSTNMBR

UPDATE #TEMP
SET ALICUOTAS = TX.ALICUOTAS
FROM #TEMP A
INNER JOIN (
SELECT A.DOCNUMBR, A.RMDTYPAL, A.CUSTNMBR, COUNT(A.ALICUOTAS) ALICUOTAS FROM
(SELECT DISTINCT A.DOCNUMBR, A.RMDTYPAL, A.CUSTNMBR, B.TXDTLPCT ALICUOTAS FROM RM30601 A INNER JOIN
(SELECT A.RPTID, A.DSCRIPTN, A.NRORDCOL, A.IDTAXOP, B.TAXDTLID, C.TXDTLDSC, CI.ColumnaArchivo FROM AWLI40004 A INNER JOIN AWLI40102 B ON A.IDTAXOP = B.IDTAXOP
INNER JOIN tblColumnasIVA CI ON A.RPTID = CI.RPTID AND A.NRORDCOL = CI.NRORDCOL
INNER JOIN TX00201 C ON B.TAXDTLID = C.TAXDTLID
where A.rptid IN(@REPORTE) AND CI.TipoReporte = 2 AND CI.ColumnaArchivo = 2 ) TX ON A.TAXDTLID = TX.TAXDTLID
INNER JOIN TX00201 B ON TX.TAXDTLID = B.TAXDTLID
WHERE TX.ColumnaArchivo = 2 AND A.TAXAMNT <> 0) A 
GROUP BY A.DOCNUMBR, A.RMDTYPAL, A.CUSTNMBR ) TX
ON A.DOCNUMBR = TX.DOCNUMBR AND A.RMDTYPAL = TX.RMDTYPAL AND A.CUSTNMBR = TX.CUSTNMBR

SELECT 
CONVERT(CHAR(8), DOCDATE, 112)	+	-- FECHA (AAAAMMDD)
RTRIM(COMPTYPE)		+				-- TIPO COMPROBANTE
RTRIM(PDV)			+				--	PUNTO DE VENTA
RTRIM(NROCOMP)		+				-- NUMERO DE COMPROBANTE
RTRIM(NROCOMP)		+				-- NUMERO DE COMPROBANTE HASTA
RTRIM(CODDOC)		+				-- CODIGO DOCUMENTO DEL COMPRADOR
REPLICATE('0', 20-LEN(RTRIM(NROIDENT))) + RTRIM(NROIDENT)		+				-- NRO IDENTIFICACION DEL COMPRADOR
LEFT(RTRIM(NOMBRE) + REPLICATE(' ', 30), 30) +		--NOMBRE DEL COMPRADOR
RIGHT(REPLACE('000000000000000' + LEFT(CONVERT(VARCHAR, TOTAL), LEN(CONVERT(VARCHAR, TOTAL))-3), '.', ''), 15)  + -- TOTAL
RIGHT(REPLACE('000000000000000' + LEFT(CONVERT(VARCHAR, NOGRAV), LEN(CONVERT(VARCHAR, NOGRAV))-3), '.', ''), 15) + -- NOGRAV
'000000000000000'	+	-- PERCEPCION NO CATEGORIZADOS
RIGHT(REPLACE('000000000000000' + LEFT(CONVERT(VARCHAR, EXENTO), LEN(CONVERT(VARCHAR, EXENTO))-3), '.', ''), 15)  + -- EXENTO
RIGHT(REPLACE('000000000000000' + LEFT(CONVERT(VARCHAR, PERCIVA), LEN(CONVERT(VARCHAR, PERCIVA))-3), '.', ''), 15)	+	-- PERCEPCION IMP NACIONALES
RIGHT(REPLACE('000000000000000' + LEFT(CONVERT(VARCHAR, PERCIIBB), LEN(CONVERT(VARCHAR, PERCIIBB))-3), '.', ''), 15)  + -- PERCIIBB
'000000000000000'	+	-- PERCEPCION IMP MUNICIPALES
'000000000000000'	+	-- PERCEPCION IMP INTERNOS
RTRIM(MONEDA)		+	-- CODIGO DE MONEDA
RIGHT(REPLACE('0000000000' + LEFT(CONVERT(VARCHAR, CAMBIO), LEN(CONVERT(VARCHAR, CAMBIO))-1), '.', ''), 10)   + -- TIPO CAMBIO
CONVERT(VARCHAR, CASE WHEN ALICUOTAS = 0 THEN 1 ELSE ALICUOTAS END)	+		-- CANTIDAD ALICUOTAS IVA
CASE WHEN CODOPER = 1 THEN 
	CASE WHEN EXENTO <> 0 THEN 'E' ELSE CASE WHEN ALICUOTAS = 0 THEN 'N' ELSE '0' END END
ELSE 
	CASE CODOPER WHEN 2 THEN 'Z' WHEN 3 THEN 'X' ELSE '0' END	
END 		+		-- CODIGO OPERACION
'000000000000000'			+		-- OTROS TRIBUTOS
CASE WHEN COMPTYPE > '008' THEN '00000000' ELSE CONVERT(CHAR(8), DUEDATE, 112)	END	TEXTO
 FROM #TEMP WHERE dbo.fncESNUMERICO(PDV) = 1
ORDER BY DOCDATE, PDV, COMPTYPE, NROCOMP





GO

