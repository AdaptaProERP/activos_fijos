// Programa   : DPCALAUTODEP
// Fecha/Hora : 31/01/2015 12:01:09
// Propósito  : Calcula Depreciación de Activos sin Depreciacion
// Creado Por : Juan Navas
// Llamado por: POST/GRABAR documentos de Compras
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere)
   LOCAL cWhere,aData,cSql

   DEFAULT cWhere:="ATV_CODSUC"+GetWhere("=",oDp:cSucMain)

   cSql:=" SELECT ATV_CODIGO "+;
         " FROM DPACTIVOS"+;
         " LEFT JOIN DPDEPRECIAACT ON DEP_CODACT=ATV_CODIGO"+;
         " WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" ATV_ESTADO='A'   AND ATV_DEPRE ='D'  AND DEP_CODACT IS NULL"

    
   aData:=ASQL(cSql)

   AEVAL(aData,{|a,n|EJECUTAR("DPDEPRECCALC",oDp:cSucMain,a[1],.T.)})

RETURN NIL
// EOF

