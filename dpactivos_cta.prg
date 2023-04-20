// Programa   : DPACTIVOS_CTA
// Fecha/Hora : 21/08/2014 02:26:55
// Propósito  : Solicitar Edicion de las Cuentas Contables
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo,lView)
  LOCAL cTable:="DPACTIVOS"
  LOCAL cCod2:="",cDescri:="",aRef:={}

  DEFAULT cCodigo:=SQLGET("DPACTIVOS","ATV_CODIGO"),;
          lView  :=.T.

  cDescri:=SQLGET("DPACTIVOS","ATV_DESCRI","ATV_CODIGO"+GetWhere("=",cCodigo))

  AADD(aRef,{"CTAACT","Activo"                ,"ATV"})
  AADD(aRef,{"CTAACU","Depreciación Acumulada","DEP"})
  AADD(aRef,{"CTADEP","Depreciación Gasto"    ,"GAS"})
  AADD(aRef,{"CTAREV","Revalorización"        ,"REV"})

  EJECUTAR("DPEDITCTAMOD",cTable,cCodigo,cCod2,cDescri,aRef,NIL,lView)


RETURN NIL
// EOF
