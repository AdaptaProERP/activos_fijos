// Programa   : DPAADONCREA
// Fecha/Hora : 11/06/2017 16:36:48
// Propósito  : Crear ADD-ON Estandar
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lRun)
  LOCAL oTable,cId:="20210212",oData,aTablas:={},aData:={},cWhere,I

  DEFAULT lRun:=.F.

  oData   :=DATACNF("DPAADONCREA","ALL")

  IF oData:Get("DPAADONCREA","")==cId
     oData:End()
     RETURN .T.
  ENDIF

  oData:End()

  IF EJECUTAR("DBISTABLE",oDp:cDsnConfig,"DPADDON") .OR. lRun

     IF COUNT("DPADDON")=0

        oTable:=OpenTable("SELECT * FROM DPADDON",.F.)
        oTable:AppendBlank()
        oTable:Replace("ADD_CODIGO","STD")
        oTable:Replace("ADD_DESCRI","Estandar")
        oTable:Replace("ADD_INSTAL",.T.)
        oTable:Replace("ADD_LLAVE","")
        oTable:Commit()
        oTable:End()

     ENDIF

     IF COUNT("DPADDON","ADD_CODIGO"+GetWhere("=","PER"))=0

        oTable:=OpenTable("SELECT * FROM DPADDON",.F.)
        oTable:AppendBlank()
        oTable:Replace("ADD_CODIGO","PER")
        oTable:Replace("ADD_DESCRI","Personalizaciones del Cliente")
        oTable:Replace("ADD_INSTAL",.T.)
        oTable:Replace("ADD_LLAVE","")
        oTable:Commit()
        oTable:End()

     ENDIF

/*
// Esto lo hace dpiniadd
     EJECUTAR("DPCAMPOSADD","DPPROGRA"    ,"PRG_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
     EJECUTAR("DPCAMPOSADD","DPTABLAS"    ,"TAB_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
     EJECUTAR("DPCAMPOSADD","DPMENU"      ,"MNU_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
     EJECUTAR("DPCAMPOSADD","DPBRW"       ,"BRW_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
     EJECUTAR("DPCAMPOSADD","DPVISTAS"    ,"VIS_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
     EJECUTAR("DPCAMPOSADD","DPBOTBAR"    ,"BOT_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
     EJECUTAR("DPCAMPOSADD","DPCAMPOS"    ,"CAM_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
     EJECUTAR("DPCAMPOSADD","DPPROCESOS"  ,"PRC_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
     EJECUTAR("DPCAMPOSADD","DPBOTBAR"    ,"BOT_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
     EJECUTAR("DPCAMPOSADD","DPTRIGGERS"  ,"TRG_CODADD","C",06,0,"Código de Add-On",NIL,.T.,"STD",["STD"])
*/

  ENDIF

aData:={}
AADD(aData,{"STD","Inventarios, Compras, Facturación y Tesorería."})
AADD(aData,{"CNT","Contabilidad"})
AADD(aData,{"TRB","Tributación y deberes formales"})
AADD(aData,{"ATV","Activos"})
AADD(aData,{"NOM","Nómina de Pagos"})
AADD(aData,{"RRH","Recursos Humanos"})
AADD(aData,{"PLF","Planificación Financiera"})
AADD(aData,{"GSC","Gestión de Sociedades"})
AADD(aData,{"GAC","Gestión de Accionistas"})
AADD(aData,{"PAP","Presupuesto Administración Pública"})
AADD(aData,{"STF","Estructura de costo financiera"})
AADD(aData,{"MAT","Mantenimiento de Activos"})
AADD(aData,{"PIV","Proveeduría Interna."})
AADD(aData,{"PRD","Producción"})
AADD(aData,{"CMR","Comercialización"})
AADD(aData,{"PLC","Aprovisionamiento y plan de compras"})
AADD(aData,{"PYS","Proyectos y Servicios"})
AADD(aData,{"GEN","Generador de reporte"})
AADD(aData,{"DIC","Diccionario de Datos"})
AADD(aData,{"ALJ","Alojamiento de personalizaciones."})
AADD(aData,{"SDK","SDK (Programación DpXbase)"})

  aTablas:={}

  AADD(aTablas,{"DPPROGRA"  ,"PRG_CODADD","PRG_ALTER"})
  AADD(aTablas,{"DPTABLAS"  ,"TAB_CODADD","TAB_ALTER"})
  AADD(aTablas,{"DPMENU"    ,"MNU_CODADD","MNU_ALTER"})
  AADD(aTablas,{"DPBRW"     ,"BRW_CODADD","BRW_ALTER"})
  AADD(aTablas,{"DPVISTAS"  ,"VIS_CODADD","VIS_ALTER"})
  AADD(aTablas,{"DPBOTBAR"  ,"BOT_CODADD","BOT_ALTER"})
  AADD(aTablas,{"DPCAMPOS"  ,"CAM_CODADD","CAM_ALTER"})
  AADD(aTablas,{"DPPROCESOS","PRC_CODADD","PRC_ALTER"})
  AADD(aTablas,{"DPBOTBAR"  ,"BOT_CODADD","BOT_ALTER"})
  AADD(aTablas,{"DPVISTAS"  ,"VIS_CODADD","VIS_ALTER"})
  AADD(aTablas,{"DPTRIGGERS","TRG_CODADD","TRG_ALTER"})

  FOR I=1 TO LEN(aData)

   cWhere:="ADD_CODIGO"+GetWhere("=",aData[I,1])

    IF COUNT("DPADDON",cWhere)=0
      oTable:=OpenTable("SELECT * FROM DPADDON",.F.)
      oTable:AppendBlank()
      oTable:Replace("ADD_CODIGO",aData[I,1])
      oTable:Replace("ADD_DESCRI",aData[I,2])
      oTable:Replace("ADD_ACTIVO",.T.)
      oTable:Commit()
      oTable:End()

    ENDIF

  NEXT I

  AEVAL(aTablas,{|a,n| SQLUPDATE(a[1],a[2],"PER",a[3]+GetWhere("=",.T.))})
  
  oData:=DATACNF("DPAADONCREA","ALL")
  oData:Set("DPAADONCREA",cId)
  oData:Save()
  oData:End()

RETURN NIL
// EOF
