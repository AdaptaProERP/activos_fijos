// Programa   : DPACTIVOS_CTA
// Fecha/Hora : 21/08/2014 02:26:55
// Prop�sito  : Solicitar Edicion de las Cuentas Contables
// Creado Por :
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo,lView)
  LOCAL cTable:="DPACTIVOS"
  LOCAL cCod2:="",cDescri:="",aRef:={}

  DEFAULT cCodigo:=SQLGET("DPACTIVOS","ATV_CODIGO"),;
          lView  :=.T.

  cDescri:=SQLGET("DPACTIVOS","ATV_DESCRI","ATV_CODIGO"+GetWhere("=",cCodigo))

  AADD(aRef,{"CTAACT","Activo"                ,"ATV"})
  AADD(aRef,{"CTAACU","Depreciaci�n Acumulada","DEP"})
  AADD(aRef,{"CTADEP","Depreciaci�n Gasto"    ,"GAS"})
  AADD(aRef,{"CTAREV","Revalorizaci�n"        ,"REV"})

  EJECUTAR("DPEDITCTAMOD",cTable,cCodigo,cCod2,cDescri,aRef,NIL,lView)


RETURN NIL
// EOF
