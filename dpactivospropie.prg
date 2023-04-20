// Programa   : DPACTIVOSPROPIE
// Fecha/Hora : 03/12/2014 17:27:55
// Propósito  : Determinar si las Cuentas tienen Propiedades
// Creado Por : Juan Navas
// Llamado por: DPACTIVOS
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lView)
  LOCAL aTipo:={"ATV","DEP","GAS","REV"}
  LOCAL aProp:={},I,nAt,aCtas:={},cTitle:=""


  DEFAULT lView:=.F.

  EJECUTAR("DPCTAPROPIEDAD")

  FOR I=1 TO LEN(aTipo)

    nAt:=ASCAN(oDp:aUtiliz,{|a,n| a[3]=aTipo[I]})

    IF nAt>0
       AADD(aProp,{oDp:aUtiliz[nAt,1],COUNT("DPCTA","CTA_PROPIE"+GetWhere("=",oDp:aUtiliz[nAt,1]))})
    ENDIF

  NEXT I

  nAt:=ASCAN(aProp,{|a,n| Empty(a[2])})

  IF nAt>0

     IF lView
       cTitle:="Propiedad de las Cuentas para los Activos"
     ELSE
       cTitle:="Es Necesario Indicar las Propiedades de las Cuentas para los Activos"
     ENDIF

     EJECUTAR("MSGBROWSE",aProp,cTitle,{340,100},200,NIL,{"Propiedad","Cuentas"},.T.)

     RETURN .F.
  ENDIF
  
RETURN .T.
// EOF

