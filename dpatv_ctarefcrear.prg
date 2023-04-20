// Programa   : DPATV_CTAREFCREAR
// Fecha/Hora : 31/12/2018 23:53:09
// Prop�sito  : Crear Referencia de Codigos de Integraci�n Grupo de Productos
// Creado Por : Juan Navas
// Llamado por:
// Aplicaci�n :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lCrear)
  LOCAL aRef:={},I,aFields
 
  DEFAULT lCrear:=.T.

  IF !EJECUTAR("DBISTABLE",oDp:cDsnData,"DPATV_CTAREF",.F.)
     aFields:={}

     AADD(aFields,{"CIR_CODINT","C",006,0,"C�dula"      ,""})
     AADD(aFields,{"CIR_DESCRI","C",120,0,"Descripci�n" ,""})
     EJECUTAR("DPTABLEADD","DPATV_CTAREF","Referencia de las Cuentas de Activos","<MULTIPLE>",aFields)

  ENDIF

  EJECUTAR("DBISTABLE",oDp:cDsnData,"DPATV_CTAREF",.T.)

  AADD(aRef,{"CTAACT","Activos Corrientes"    ,""})
  AADD(aRef,{"CTADEP","Depreciaci�n Gasto"    ,""})
  AADD(aRef,{"CTAACU","Depreciaci�n Acumulada",""})
  AADD(aRef,{"CTAREV","Revalorizaci�n" ,""})

  IF lCrear .OR. COUNT("DPATV_CTAREF")=0

     FOR I=1 TO LEN(aRef)
       EJECUTAR("CREATERECORD","DPATV_CTAREF",{"CIR_CODINT","CIR_DESCRI"},{aRef[I,1],aRef[I,2]},NIL,.T.,"CIR_CODINT"+GetWhere("=",aRef[I,1]))
     NEXT I

  ENDIF

  
RETURN aRef


