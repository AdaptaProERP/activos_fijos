// Programa   : DPCTAPROPIEDAD 
// Fecha/Hora : 29/10/2014 09:36:00
// Propósito  : Utilización de las Cuentas Contables
// Creado Por : Juan Navas
// Llamado por: Menu Otros
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lGet,cCodCta)
  LOCAL aCuentas:={},lCtaBg:=.F.,aProp:={}

  DEFAULT lGet:=.F.

  oDp:aUtiliz:={}

  AADD(oDp:aUtiliz,{"Planta y Equipos"   ,"B","ATV",.T.})
  AADD(oDp:aUtiliz,{"Activos Corrientes" ,"B","ATC",.T.})
  AADD(oDp:aUtiliz,{"Inventarios"        ,"B","INV",.T.})
  AADD(oDp:aUtiliz,{"Asientos"           ,"B","LIB",.T.})
  AADD(oDp:aUtiliz,{"Patrimonio"         ,"B","PAT",.F.})
  AADD(oDp:aUtiliz,{"Monetarias"         ,"B","MON",.F.})
  AADD(oDp:aUtiliz,{"Moneda Extranjera"  ,"B","EXT",.T.})
  AADD(oDp:aUtiliz,{"Depreciación Activo","B","DEP",.F.})
  AADD(oDp:aUtiliz,{"Depreciación Gasto" ,"R","GAS",.F.})
  AADD(oDp:aUtiliz,{"Revaluación Activo" ,"B","REV",.F.})
  AADD(oDp:aUtiliz,{"Deterioro"          ,"B","DET",.F.})
  AADD(oDp:aUtiliz,{"Ninguno"            ,"R",""   ,.F.})
  AADD(oDp:aUtiliz,{"Ninguno"            ,"B",""   ,.F.})
  AADD(oDp:aUtiliz,{"Discrecionales"     ,"R","DIS",.F.})
  AADD(oDp:aUtiliz,{"Discrecionales"     ,"B","DIS",.F.})

//  AEVAL(oDp:aUtiliz,{|a,n| IIF(a[2]="B",AADD(aPropB,a[1]),NIL)})
//  AEVAL(oDp:aUtiliz,{|a,n| IIF(a[2]="R",AADD(aPropG,a[1]),NIL)})

  IF !Empty(cCodCta)

    oDp:aCtaBg:={oDp:cCtaBg1,oDp:cCtaBg2,oDp:cCtaBg3,oDp:cCtaBg4}
    oDp:aCtaGp:={oDp:cCtaGp1,oDp:cCtaGp2,oDp:cCtaGp3,oDp:cCtaGp4,oDp:cCtaGp5,oDp:cCtaGp6}

    IF ASCAN(oDp:aCtaBg,{|a,n|LEFT(cCodCta,LEN(ALLTRIM(a)))==ALLTRIM(a) })>0
      lCtaBg:=.T.
    ENDIF

    IF lCtaBg
      AEVAL(oDp:aUtiliz,{|a,n| IIF(a[2]="B",AADD(aProp,a[1]),NIL)})
    ELSE
      AEVAL(oDp:aUtiliz,{|a,n| IIF(a[2]="R",AADD(aProp,a[1]),NIL)})
    ENDIF

    ASORT(aProp)

  ENDIF

  IF Empty(aProp)
    AADD(aProp,"Ninguno")
  ENDIF


RETURN aProp

/*
Se entiende por activos corrientes aquellos activos que son susceptibles de convertirse en dinero en efectivo en un periodo inferior a un año. Ejemplo de estos activos además de caja y bancos, se tienen las inversiones a corto plazo, la cartera y los inventarios.
*/
// EOF

