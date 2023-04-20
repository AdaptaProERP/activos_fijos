// Programa   : DPACTIVOSFIXFK
// Fecha/Hora : 09/10/2021 05:43:50
// Propósito  : Reparar Integridad Referencial
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
//  LOCAL aFields:=ASQL("SELECT CAM_TABLE FROM DPCAMPOS WHERE CAM_NAME"+GetWhere("=","SUCCIC_CODSUC"))
  LOCAL I
  LOCAL aLink:=ASQL("SELECT LNK_TABLED FROM DPLINK WHERE LNK_TABLES"+GetWhere("=","DPACTIVOS")+" GROUP BY LNK_TABLED" )

  aLink:=ASQL("SELECT LNK_TABLED FROM DPLINK WHERE LNK_TABLES"+GetWhere("=","DPSUCURSAL")+" GROUP BY LNK_TABLED" )

  FOR I=1 TO LEN(aLink)
     EJECUTAR("DPDROP_FK",aLink[I,1]),;
     EJECUTAR("DPDROP_PK",aLink[I,1]),;
     EJECUTAR("DPGET_FK" ,aLink[I,1],.T.,oDb)
  NEXT I

  EJECUTAR("BUILDINTREF","DPSUCURSAL")
  EJECUTAR("BUILDINTREF","DPCENCOS")


ViewArray(aLink)

//EJECUTAR("DPDROP_FK","DPSUCURSAL")

  AEVAL(aLink,{|a,n| EJECUTAR("DPDROP_FK",a[1]),;
                     EJECUTAR("DPDROP_PK",a[1]),;
                     EJECUTAR("DPGET_FK",a[1],.T.,oDb)})

/*
 
  EJECUTAR("BUILDINTREF","DPSUCURSAL")
*/

//  EJECUTAR("DPLINKADD","DPACTIVOS","DPDESINCORPACT","ATV_CODSUC,ATV_CODIGO","DAC_CODSUC,DAC_CODIGO",.T.,.T.,.T.)

RETURN
