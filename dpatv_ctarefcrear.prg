// Programa   : DPATV_CTAREFCREAR
// Fecha/Hora : 31/12/2018 23:53:09
// Propósito  : Crear Referencia de Codigos de Integración Grupo de Productos
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lCrear)
  LOCAL aRef:={},I,aFields
 
  DEFAULT lCrear:=.T.

  IF !EJECUTAR("DBISTABLE",oDp:cDsnData,"DPATV_CTAREF",.F.)
     aFields:={}

     AADD(aFields,{"CIR_CODINT","C",006,0,"Cédula"      ,""})
     AADD(aFields,{"CIR_DESCRI","C",120,0,"Descripción" ,""})
     EJECUTAR("DPTABLEADD","DPATV_CTAREF","Referencia de las Cuentas de Activos","<MULTIPLE>",aFields)

  ENDIF

  EJECUTAR("DBISTABLE",oDp:cDsnData,"DPATV_CTAREF",.T.)

  AADD(aRef,{"CTAACT","Activos Corrientes"    ,""})
  AADD(aRef,{"CTADEP","Depreciación Gasto"    ,""})
  AADD(aRef,{"CTAACU","Depreciación Acumulada",""})
  AADD(aRef,{"CTAREV","Revalorización" ,""})

  IF lCrear .OR. COUNT("DPATV_CTAREF")=0

     FOR I=1 TO LEN(aRef)
       EJECUTAR("CREATERECORD","DPATV_CTAREF",{"CIR_CODINT","CIR_DESCRI"},{aRef[I,1],aRef[I,2]},NIL,.T.,"CIR_CODINT"+GetWhere("=",aRef[I,1]))
     NEXT I

  ENDIF

  
RETURN aRef


