// Programa   : DPCTAPROPWHERE
// Fecha/Hora : 01/11/2014 03:44:15
// Prop�sito  : Genera Clausula Where segun Propiedad de la Cuenta
// Creado Por :
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo)
   LOCAL nAt:=0,cWhere:=""

   DEFAULT cCodigo:="ATV"

   EJECUTAR("DPCTAPROPIEDAD")

   nAt:=ASCAN(oDp:aUtiliz,{|a,n| a[3]==cCodigo})

   IF nAt>0
     cWhere:="CTA_PROPIE"+GetWhere("=",oDp:aUtiliz[nAt,1])
   ENDIF

RETURN cWhere
// EOF

