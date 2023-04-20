// Programa   : DPACTIVOS_VIEWCREAR
// Fecha/Hora : 20/04/2023 04:51:50
// Propósito  : Crear vistas para los Activos
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL aCta   :={"ACT","DEP","ACU","REV"},I,cSql,cCodigo,cDescri,lRun
  LOCAL aDescri:={"Activos","Depreciación Gasto","Depreciación Acumulada","Revalorización"}

  FOR I=1 TO LEN(aCta)

    cSql:=[ SELECT CIC_CTAMOD AS ACT_CTAMOD,CIC_CODIGO AS ACT_CODACT,CIC_CUENTA AS ACT_CTA]+aCta[I]+;
          [ FROM DPACTIVOS_CTA ]+;         
          [ WHERE CIC_CODINT]+GetWhere("=","CTA"+aCta[I])

    cCodigo:="ACTCTA_"+aCta[I],;
    cDescri:="Cuenta Contable Activos "+aDescri[I],;
    lRun   :=.T.

    EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql,lRun)

   NEXT I

   cCodigo:="DPACTIVOS_CTA"
   cDescri:="Activos con Cuentas Contables "

    cSql:=[ SELECT  CIC_CTAMOD AS ATV_CTAMOD, ATV_CODIGO, ATV_DESCRI,COUNT(*) AS ATV_CANTID  ]+CRLF+;
          [ FROM DPACTIVOS ]+CRLF+;
          [ INNER JOIN DPACTIVOS_CTA ON CIC_CODIGO=ATV_CODIGO ]+CRLF+;
          [ GROUP BY CIC_CTAMOD,ATV_CODIGO ]+;
          [ ORDER BY CIC_CTAMOD,ATV_CODIGO ]


   EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql,lRun)
  
   LOADTABLAS(.T.)

    cSql:=[ SELECT  ]+CRLF+;
          [ ATV_CTAMOD,]+CRLF+;
          [ ATV_CODIGO,]+CRLF+;
          [ ATV_DESCRI,]+CRLF+;
          [ VIEW_ACTCTA_ACT.ACT_CTAACT AS ATV_CTAACT,]+CRLF+;
          [ VIEW_ACTCTA_ACU.ACT_CTAACU AS ATV_CTAACU,]+CRLF+;
          [ VIEW_ACTCTA_DEP.ACT_CTADEP AS ATV_CTADEP,]+CRLF+;
          [ VIEW_ACTCTA_REV.ACT_CTAREV AS ATV_CTAREV ]+CRLF+;
          [ FROM VIEW_DPACTIVOS_CTA ]+CRLF+;
          [ LEFT JOIN VIEW_ACTCTA_ACT ON ATV_CODIGO=VIEW_ACTCTA_ACT.ACT_CODACT]+CRLF+;
          [ LEFT JOIN VIEW_ACTCTA_ACU ON ATV_CODIGO=VIEW_ACTCTA_ACU.ACT_CODACT]+CRLF+;
          [ LEFT JOIN VIEW_ACTCTA_DEP ON ATV_CODIGO=VIEW_ACTCTA_DEP.ACT_CODACT]+CRLF+;
          [ LEFT JOIN VIEW_ACTCTA_REV ON ATV_CODIGO=VIEW_ACTCTA_REV.ACT_CODACT]+CRLF+;
          [ GROUP BY ATV_CTAMOD,ATV_CODIGO]+CRLF+;
          [ ORDER BY ATV_CTAMOD,ATV_CODIGO]

   cCodigo:="DPACTIVOSCTA"
   cDescri:="Activos con Cuentas Contables en Columnas "
 
   EJECUTAR("DPVIEWADD",cCodigo,cDescri,cSql,lRun)

   EJECUTAR("DPATV_CTAREFCREAR")


RETURN .T.
// EOF
