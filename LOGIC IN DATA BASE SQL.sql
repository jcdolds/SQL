USE [HIVIMAR_EBIZ]
GO

/****** Object:  StoredProcedure [dbo].[STP_CARTERA_VENCIDA]    Script Date: 28/3/2022 10:46:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
















ALTER PROCEDURE [dbo].[STP_CARTERA_VENCIDA]
AS

DECLARE @CURRENT_DAY DATETIME ;
SET @CURRENT_DAY = DATEADD(DAY, -1, GETDATE());


DELETE EBIZ_CARTERA_VENCIDA_NEW WHERE MONTH(FECHA_CORTE) = MONTH(@CURRENT_DAY) AND YEAR(FECHA_CORTE) = YEAR(@CURRENT_DAY)

INSERT INTO EBIZ_CARTERA_VENCIDA_NEW

SELECT
	   CAST(A.REFERENCIA AS VARCHAR) AS REFERENCIA,
	   CAST(A.COD_CONTABLE AS VARCHAR) AS COD_CONTABLE,
	   CAST(A.COD_TIPO_DOCUMENTO AS VARCHAR) AS COD_TIPO_DOCUMENTO,
	    CAST( CASE WHEN A.FECHA_DOCUMENTO LIKE '0%' THEN GETDATE()
	        ELSE CONVERT(DATETIME,A.FECHA_DOCUMENTO) END AS DATETIME) AS FECHA_DOCUMENTO,
	   CAST(A.VIP AS VARCHAR) AS VIP,
	    CAST(A.DIAS AS VARCHAR) AS DIAS,
	   CAST( CASE WHEN A.FECHA_BASE LIKE '00%' THEN GETDATE()
	        ELSE CONVERT(DATETIME,A.FECHA_BASE) END AS DATETIME) AS FECHA_BASE,
	   CAST(A.TEXTO AS VARCHAR) AS TEXTO,
	   CONVERT(DATETIME,A.FECHA_CONTABLE) AS FECHA_CONTABLE,
	    DATEADD(DAY, CAST(A.DIAS AS NUMERIC),   CAST( CASE WHEN A.FECHA_BASE LIKE '00%' THEN GETDATE()
	        ELSE CONVERT(DATETIME,A.FECHA_BASE) END AS DATETIME)) AS FECHA_PAGO,
	   CAST(A.DEMORA AS VARCHAR) AS DEMORA,
	   A.MONTO_DEUDA ,
	  	     CAST(CASE	WHEN COD_CLIENTE LIKE '3100000000' THEN '3100000000'
					WHEN COD_CLIENTE LIKE '3100000001' THEN '3100000001'
					WHEN COD_CLIENTE LIKE '3100000002' THEN '3100000002'
					WHEN COD_CLIENTE LIKE '3100000003' THEN '3100000003'
					WHEN COD_CLIENTE LIKE '3100000004' THEN '3100000004'
					WHEN COD_CLIENTE LIKE '3100000005' THEN '3100000005'
					WHEN COD_CLIENTE LIKE '3100000006' THEN '3100000006'
					WHEN COD_CLIENTE LIKE '3100000007' THEN '3100000007'
					WHEN COD_CLIENTE LIKE '3100000008' THEN '3100000008'
					WHEN COD_CLIENTE LIKE '3100000009' THEN '3100000009'
			ELSE CAST((COD_CLIENTE * 1) AS BIGINT) END AS VARCHAR) AS COD_CLIENTE,
	   CAST(VENCIMIENTO AS VARCHAR) AS VENCIMIENTO, 
	   A.LIBRO_MAYOR,
	   NULL AS COD_AGENTE,
	  NULL AS COD_OFICIAL_CRED,
	  NULL AS COD_RECAUDADOR,
	   COD_CANAL AS COD_CANAL,
	   @CURRENT_DAY AS FECHA_CORTE,
	   COD_COMPENSACION

FROM (


SELECT *, 
	     CASE 
 	   WHEN TB1.DEMORA <=0 THEN 'CORRIENTE'
       WHEN TB1.DEMORA BETWEEN 1 AND 30 THEN 'VENCE 30 DIAS'
       WHEN TB1.DEMORA BETWEEN 31 AND 60 THEN 'VENCE 60 DIAS' 
       WHEN TB1.DEMORA BETWEEN 61 AND 90 THEN 'VENCE 90 DIAS' 
       WHEN TB1.DEMORA BETWEEN 91 AND 120 THEN 'VENCE 120 DIAS' 
       WHEN TB1.DEMORA BETWEEN 121 AND 150 THEN 'VENCE 150 DIAS' 
       WHEN TB1.DEMORA BETWEEN 151 AND 180 THEN 'VENCE 180 DIAS' 
       WHEN TB1.DEMORA BETWEEN 181 AND 360 THEN 'VENCE 360 DIAS' 
       WHEN TB1.DEMORA > 360 THEN 'VENCE MAYORES 360 DIAS' 
       ELSE '' END AS VENCIMIENTO

FROM (


SELECT  
 CAST(CASE	WHEN COD_CLIENTE LIKE '3100000000' THEN '3100000000'
					WHEN COD_CLIENTE LIKE '3100000001' THEN '3100000001'
					WHEN COD_CLIENTE LIKE '3100000002' THEN '3100000002'
					WHEN COD_CLIENTE LIKE '3100000003' THEN '3100000003'
					WHEN COD_CLIENTE LIKE '3100000004' THEN '3100000004'
					WHEN COD_CLIENTE LIKE '3100000005' THEN '3100000005'
					WHEN COD_CLIENTE LIKE '3100000006' THEN '3100000006'
					WHEN COD_CLIENTE LIKE '3100000007' THEN '3100000007'
					WHEN COD_CLIENTE LIKE '3100000008' THEN '3100000008'
					WHEN COD_CLIENTE LIKE '3100000009' THEN '3100000009'
			ELSE CAST((COD_CLIENTE * 1) AS BIGINT) END AS VARCHAR) AS COD_CLIENTE,
REFERENCIA	,
COD_CONTABLE	,
COD_TIPO_DOCUMENTO	,
LIBRO_MAYOR	,
	    CAST( CASE WHEN A.FECHA_DOCUMENTO LIKE '0%' THEN GETDATE()
	        ELSE CONVERT(DATETIME,A.FECHA_DOCUMENTO) END AS DATETIME) AS FECHA_DOCUMENTO,
FECHA_CONTABLE	,
	    CAST( CASE WHEN A.FECHA_BASE LIKE '0%' THEN GETDATE()
	        ELSE CONVERT(DATETIME,A.FECHA_BASE) END AS DATETIME) AS FECHA_BASE,
 DATEADD(DAY,DIAS,CAST( CASE WHEN A.FECHA_BASE LIKE '0%' THEN GETDATE()
	        ELSE CONVERT(DATETIME,A.FECHA_BASE) END AS DATETIME))   AS FECHA_PAGO	,

       CASE COD_TIPO_DOCUMENTO
       WHEN '04' THEN
       DATEDIFF(DAY, CAST( CASE WHEN A.FECHA_BASE LIKE '0%' THEN GETDATE()
	        ELSE CONVERT(DATETIME,A.FECHA_BASE) END AS DATETIME) , @CURRENT_DAY )
       ELSE
       DATEDIFF(DAY,( DATEADD(DAY,DIAS,CAST( CASE WHEN A.FECHA_BASE LIKE '0%' THEN GETDATE()
	        ELSE CONVERT(DATETIME,A.FECHA_BASE) END AS DATETIME))) , @CURRENT_DAY)               
       END  AS DEMORA,


TEXTO	,
VIP	,
DIAS	,
COD_CANAL	,
COD_COMPENSACION	,
MONTO_DEUDA	,
@CURRENT_DAY AS FECHA_CORTE
FROM HANA_CARTERA_VENCIDA_NEW_VERSION A
WHERE A.ORIGEN_BASE = 'BSID'
AND COD_TIPO_DOCUMENTO <> 'PF'
AND FECHA_CONTABLE <= @CURRENT_DAY


UNION ALL

SELECT  
 CAST(CASE	WHEN COD_CLIENTE LIKE '3100000000' THEN '3100000000'
					WHEN COD_CLIENTE LIKE '3100000001' THEN '3100000001'
					WHEN COD_CLIENTE LIKE '3100000002' THEN '3100000002'
					WHEN COD_CLIENTE LIKE '3100000003' THEN '3100000003'
					WHEN COD_CLIENTE LIKE '3100000004' THEN '3100000004'
					WHEN COD_CLIENTE LIKE '3100000005' THEN '3100000005'
					WHEN COD_CLIENTE LIKE '3100000006' THEN '3100000006'
					WHEN COD_CLIENTE LIKE '3100000007' THEN '3100000007'
					WHEN COD_CLIENTE LIKE '3100000008' THEN '3100000008'
					WHEN COD_CLIENTE LIKE '3100000009' THEN '3100000009'
			ELSE CAST((COD_CLIENTE * 1) AS BIGINT) END AS VARCHAR) AS COD_CLIENTE,
REFERENCIA	,
COD_CONTABLE	,
COD_TIPO_DOCUMENTO	,
LIBRO_MAYOR	,
	    CAST( CASE WHEN A.FECHA_DOCUMENTO LIKE '0%' THEN GETDATE()
	        ELSE CONVERT(DATETIME,A.FECHA_DOCUMENTO) END AS DATETIME) AS FECHA_DOCUMENTO,
FECHA_CONTABLE	,
	    CAST( CASE WHEN A.FECHA_BASE LIKE '0%' THEN GETDATE()
	        ELSE CONVERT(DATETIME,A.FECHA_BASE) END AS DATETIME) AS FECHA_BASE,
 DATEADD(DAY,DIAS,CAST( CASE WHEN A.FECHA_BASE LIKE '0%' THEN GETDATE()
	        ELSE CONVERT(DATETIME,A.FECHA_BASE) END AS DATETIME))   AS FECHA_PAGO	,

       CASE COD_TIPO_DOCUMENTO
       WHEN '04' THEN
       DATEDIFF(DAY, CAST( CASE WHEN A.FECHA_BASE LIKE '0%' THEN GETDATE()
	        ELSE CONVERT(DATETIME,A.FECHA_BASE) END AS DATETIME) , @CURRENT_DAY )
       ELSE
       DATEDIFF(DAY,( DATEADD(DAY,DIAS,CAST( CASE WHEN A.FECHA_BASE LIKE '0%' THEN GETDATE()
	        ELSE CONVERT(DATETIME,A.FECHA_BASE) END AS DATETIME))) , @CURRENT_DAY)               
       END  AS DEMORA,


TEXTO	,
VIP	,
DIAS	,
COD_CANAL	,
COD_COMPENSACION	,
MONTO_DEUDA	,
@CURRENT_DAY AS FECHA_CORTE
FROM HANA_CARTERA_VENCIDA_NEW_VERSION A
WHERE A.ORIGEN_BASE = 'BSAD'
AND COD_TIPO_DOCUMENTO <> 'PF'
AND COD_TIPO_DOCUMENTO <> 'AD'
AND FECHA_CONTABLE <= @CURRENT_DAY
AND MONTH(CAST( CASE WHEN A.FECHA_VALOR LIKE '0%' THEN GETDATE()
	        ELSE CONVERT(DATETIME,A.FECHA_VALOR) END AS DATETIME)) = MONTH(DATEADD(MONTH,1,@CURRENT_DAY))

AND YEAR(CAST( CASE WHEN A.FECHA_VALOR LIKE '0%' THEN GETDATE()
	        ELSE CONVERT(DATETIME,A.FECHA_VALOR) END AS DATETIME))  = YEAR(DATEADD(MONTH,1,@CURRENT_DAY))

			
			
			
			) TB1
			
			
			) A



UPDATE A
SET
A.COD_AGENTE = B.codigo_agente,
A.COD_OFICIAL_CRED = B.codigo_oficial,
A.COD_RECAUDADOR = B.codigo_recaudador
FROM EBIZ_CARTERA_VENCIDA_NEW A , 
(SELECT * FROM ebiz_cyc_presupuesto
WHERE mes = MONTH(@CURRENT_DAY) AND a�o = YEAR(@CURRENT_DAY)  ) B
WHERE A.COD_CLIENTE = B.codigo_cliente AND A.COD_CANAL = B.CANAL
AND MONTH(FECHA_CORTE) = MONTH(@CURRENT_DAY) AND YEAR(FECHA_CORTE) = YEAR(@CURRENT_DAY) 


UPDATE A
SET
A.COD_AGENTE = B.COD_AGENTE
FROM EBIZ_CARTERA_VENCIDA_NEW A ,
(SELECT DISTINCT COD_CLIENTE, COD_AGENTE, COD_CANAL FROM EBIZ_CARTERA) B
WHERE MONTH(FECHA_CORTE) = MONTH(@CURRENT_DAY) AND YEAR(FECHA_CORTE) = YEAR(@CURRENT_DAY) 
AND A.COD_CLIENTE = B.COD_CLIENTE AND A.COD_AGENTE IS NULL AND A.COD_CANAL = B.COD_CANAL



UPDATE A
SET
A.COD_AGENTE = B.COD_AGENTE
FROM EBIZ_CARTERA_VENCIDA_NEW A ,
(SELECT DISTINCT COD_CLIENTE, COD_AGENTE FROM EBIZ_CARTERA WHERE CANAL not like '%Taller%' ) B
WHERE MONTH(FECHA_CORTE) = MONTH(@CURRENT_DAY) AND YEAR(FECHA_CORTE) = YEAR(@CURRENT_DAY) 
AND A.COD_CLIENTE = B.COD_CLIENTE AND A.COD_AGENTE IS NULL


UPDATE A
SET
A.COD_AGENTE = B.COD_AGENTE
FROM EBIZ_CARTERA_VENCIDA_NEW A ,
(SELECT DISTINCT COD_CLIENTE, COD_AGENTE FROM EBIZ_CARTERA WHERE CANAL not like '%Taller%' ) B
WHERE MONTH(FECHA_CORTE) = MONTH(@CURRENT_DAY) AND YEAR(FECHA_CORTE) = YEAR(@CURRENT_DAY) 
AND A.COD_CLIENTE = B.COD_CLIENTE AND A.COD_AGENTE = ''


UPDATE A
SET
A.COD_AGENTE = B.COD_AGENTE
FROM EBIZ_CARTERA_VENCIDA_NEW A ,
(SELECT DISTINCT COD_CLIENTE, COD_AGENTE FROM EBIZ_CARTERA WHERE CANAL  like '%Taller%' ) B
WHERE MONTH(FECHA_CORTE) = MONTH(@CURRENT_DAY) AND YEAR(FECHA_CORTE) = YEAR(@CURRENT_DAY) 
AND A.COD_CLIENTE = B.COD_CLIENTE
AND A.COD_AGENTE IS NULL 



UPDATE A
SET
A.COD_OFICIAL_CRED = B.COD_AGENTE
FROM EBIZ_CARTERA_VENCIDA_NEW A ,
(SELECT DISTINCT COD_CLIENTE, COD_AGENTE, COD_CANAL FROM EBIZ_CARTERA_OFICIAL) B
WHERE MONTH(FECHA_CORTE) = MONTH(@CURRENT_DAY) AND YEAR(FECHA_CORTE) = YEAR(@CURRENT_DAY) 
AND A.COD_CLIENTE = B.COD_CLIENTE AND A.COD_OFICIAL_CRED IS NULL  AND A.COD_CANAL = B.COD_CANAL


UPDATE A
SET
A.COD_OFICIAL_CRED = B.COD_AGENTE
FROM EBIZ_CARTERA_VENCIDA_NEW A ,
(SELECT DISTINCT COD_CLIENTE, COD_AGENTE FROM EBIZ_CARTERA_OFICIAL  WHERE CANAL  NOT like '%Taller%') B
WHERE MONTH(FECHA_CORTE) = MONTH(@CURRENT_DAY) AND YEAR(FECHA_CORTE) = YEAR(@CURRENT_DAY) 
AND A.COD_CLIENTE = B.COD_CLIENTE AND A.COD_OFICIAL_CRED IS NULL

UPDATE A
SET
A.COD_OFICIAL_CRED = B.COD_AGENTE
FROM EBIZ_CARTERA_VENCIDA_NEW A ,
(SELECT DISTINCT COD_CLIENTE, COD_AGENTE FROM EBIZ_CARTERA_OFICIAL  WHERE CANAL  like '%Taller%') B
WHERE MONTH(FECHA_CORTE) = MONTH(@CURRENT_DAY) AND YEAR(FECHA_CORTE) = YEAR(@CURRENT_DAY) 
AND A.COD_CLIENTE = B.COD_CLIENTE AND A.COD_OFICIAL_CRED IS NULL

UPDATE A
SET
A.COD_RECAUDADOR = B.COD_AGENTE
FROM EBIZ_CARTERA_VENCIDA_NEW A ,
(SELECT DISTINCT COD_CLIENTE, COD_AGENTE, COD_CANAL FROM EBIZ_CARTERA_RECAUDADOR) B
WHERE MONTH(FECHA_CORTE) = MONTH(@CURRENT_DAY) AND YEAR(FECHA_CORTE) = YEAR(@CURRENT_DAY) 
AND A.COD_CLIENTE = B.COD_CLIENTE AND A.COD_RECAUDADOR IS NULL AND A.COD_CANAL = B.COD_CANAL


UPDATE A
SET
A.COD_RECAUDADOR = B.COD_AGENTE
FROM EBIZ_CARTERA_VENCIDA_NEW A ,
(SELECT DISTINCT COD_CLIENTE, COD_AGENTE FROM EBIZ_CARTERA_RECAUDADOR  WHERE CANAL  like '%Taller%') B
WHERE MONTH(FECHA_CORTE) = MONTH(@CURRENT_DAY) AND YEAR(FECHA_CORTE) = YEAR(@CURRENT_DAY) 
AND A.COD_CLIENTE = B.COD_CLIENTE AND A.COD_RECAUDADOR IS NULL


UPDATE A
SET
A.COD_RECAUDADOR = B.COD_AGENTE
FROM EBIZ_CARTERA_VENCIDA_NEW A ,
(SELECT DISTINCT COD_CLIENTE, COD_AGENTE FROM EBIZ_CARTERA_RECAUDADOR  WHERE CANAL  NOT like '%Taller%') B
WHERE MONTH(FECHA_CORTE) = MONTH(@CURRENT_DAY) AND YEAR(FECHA_CORTE) = YEAR(@CURRENT_DAY) 
AND A.COD_CLIENTE = B.COD_CLIENTE AND A.COD_RECAUDADOR IS NULL

UPDATE A
SET
A.COD_AGENTE = '111111',
A.COD_OFICIAL_CRED = '211111',
A.COD_RECAUDADOR = '311111'
FROM EBIZ_CARTERA_VENCIDA_NEW A
WHERE COD_AGENTE IS NULL AND MONTH(FECHA_CORTE) = MONTH(@CURRENT_DAY) AND YEAR(FECHA_CORTE) = YEAR(@CURRENT_DAY) 




















GO


