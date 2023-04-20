// Programa   : BRPCDEPREC
// Fecha/Hora : 29/10/2018 12:08:25
// Propósito  : "Post-Conversion Depreciaciones"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRPCDEPREC.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 


   cTitle:="Post-Conversion Depreciaciones" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")


   // Obtiene el Código del Parámetro

   IF !Empty(cWhere)
 
      cCodPar:=ATAIL(_VECTOR(cWhere,"="))
 
      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF .T. .AND. (!nPeriodo=11 .AND. (Empty(dDesde) .OR. Empty(dhasta)))

       aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
       dDesde :=aFechas[1]
       dHasta :=aFechas[2]

   ENDIF

   IF .F.

      IF nPeriodo=10
        dDesde :=V_dDesde
        dHasta :=V_dHasta
      ELSE
        aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
        dDesde :=aFechas[1]
        dHasta :=aFechas[2]
      ENDIF

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)


   ELSEIF (.T.)

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)

   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle,oDp:cWhere)

   oDp:oFrm:=oPCDEPREC
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD




   DpMdi(cTitle,"oPCDEPREC","BRPCDEPREC.EDT")
// oPCDEPREC:CreateWindow(0,0,100,550)
   oPCDEPREC:Windows(0,0,aCoors[3]-160,aCoors[4]-10,.T.) // Maximizado



   oPCDEPREC:cCodSuc  :=cCodSuc
   oPCDEPREC:lMsgBar  :=.F.
   oPCDEPREC:cPeriodo :=aPeriodos[nPeriodo]
   oPCDEPREC:cCodSuc  :=cCodSuc
   oPCDEPREC:nPeriodo :=nPeriodo
   oPCDEPREC:cNombre  :=""
   oPCDEPREC:dDesde   :=dDesde
   oPCDEPREC:cServer  :=cServer
   oPCDEPREC:dHasta   :=dHasta
   oPCDEPREC:cWhere   :=cWhere
   oPCDEPREC:cWhere_  :=cWhere_
   oPCDEPREC:cWhereQry:=""
   oPCDEPREC:cSql     :=oDp:cSql
   oPCDEPREC:oWhere   :=TWHERE():New(oPCDEPREC)
   oPCDEPREC:cCodPar  :=cCodPar // Código del Parámetro
   oPCDEPREC:lWhen    :=.T.
   oPCDEPREC:cTextTit :="" // Texto del Titulo Heredado
    oPCDEPREC:oDb     :=oDp:oDb
   oPCDEPREC:cBrwCod  :="PCDEPREC"
   oPCDEPREC:lTmdi    :=.T.



   oPCDEPREC:oBrw:=TXBrowse():New( IF(oPCDEPREC:lTmdi,oPCDEPREC:oWnd,oPCDEPREC:oDlg ))
   oPCDEPREC:oBrw:SetArray( aData, .F. )
   oPCDEPREC:oBrw:SetFont(oFont)

   oPCDEPREC:oBrw:lFooter     := .T.
   oPCDEPREC:oBrw:lHScroll    := .F.
   oPCDEPREC:oBrw:nHeaderLines:= 2
   oPCDEPREC:oBrw:nDataLines  := 1
   oPCDEPREC:oBrw:nFooterLines:= 1




   oPCDEPREC:aData            :=ACLONE(aData)
  oPCDEPREC:nClrText :=0
  oPCDEPREC:nClrPane1:=16769217
  oPCDEPREC:nClrPane2:=16764573

   AEVAL(oPCDEPREC:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  oCol:=oPCDEPREC:oBrw:aCols[1]
  oCol:cHeader      :='Código de Activo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPCDEPREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 120

  oCol:=oPCDEPREC:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPCDEPREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 400

  oCol:=oPCDEPREC:oBrw:aCols[3]
  oCol:cHeader      :='Año'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPCDEPREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oPCDEPREC:oBrw:aArrayData[oPCDEPREC:oBrw:nArrayAt,3],FDP(nMonto,'9999')}
   oCol:cFooter      :=FDP(aTotal[3],'9999')


  oCol:=oPCDEPREC:oBrw:aCols[4]
  oCol:cHeader      :='Depreciacion'+CRLF+'Anual'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPCDEPREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oPCDEPREC:oBrw:aArrayData[oPCDEPREC:oBrw:nArrayAt,4],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[4],'999,999,999.99')


  oCol:=oPCDEPREC:oBrw:aCols[5]
  oCol:cHeader      :='Depreciación'+CRLF+'Reconvertida'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPCDEPREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oPCDEPREC:oBrw:aArrayData[oPCDEPREC:oBrw:nArrayAt,5],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[5],'999,999,999.99')


  oCol:=oPCDEPREC:oBrw:aCols[6]
  oCol:cHeader      :='Depreciación'+CRLF+'Monto Origen Anual'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPCDEPREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oPCDEPREC:oBrw:aArrayData[oPCDEPREC:oBrw:nArrayAt,6],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[6],'999,999,999.99')


  oCol:=oPCDEPREC:oBrw:aCols[7]
  oCol:cHeader      :='Depreciación'+CRLF+'Origen Reconvertido'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPCDEPREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oPCDEPREC:oBrw:aArrayData[oPCDEPREC:oBrw:nArrayAt,7],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[7],'999,999,999.99')


  oCol:=oPCDEPREC:oBrw:aCols[8]
  oCol:cHeader      :='Desde'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPCDEPREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oPCDEPREC:oBrw:aCols[9]
  oCol:cHeader      :='Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oPCDEPREC:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

   oPCDEPREC:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oPCDEPREC:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oPCDEPREC:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oPCDEPREC:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oPCDEPREC:nClrPane1, oPCDEPREC:nClrPane2 ) } }

   oPCDEPREC:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oPCDEPREC:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oPCDEPREC:oBrw:bLDblClick:={|oBrw|oPCDEPREC:RUNCLICK() }

   oPCDEPREC:oBrw:bChange:={||oPCDEPREC:BRWCHANGE()}
   oPCDEPREC:oBrw:CreateFromCode()
    oPCDEPREC:bValid   :={|| EJECUTAR("BRWSAVEPAR",oPCDEPREC)}
    oPCDEPREC:BRWRESTOREPAR()


   oPCDEPREC:oWnd:oClient := oPCDEPREC:oBrw


   oPCDEPREC:Activate({||oPCDEPREC:ViewDatBar()})


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oPCDEPREC:lTmdi,oPCDEPREC:oWnd,oPCDEPREC:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oPCDEPREC:oBrw:nWidth()

   oPCDEPREC:oBrw:GoBottom(.T.)
   oPCDEPREC:oBrw:Refresh(.T.)

   IF !File("FORMS\BRPCDEPREC.EDT")
     oPCDEPREC:oBrw:Move(44,0,850+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD




 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oPCDEPREC:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oPCDEPREC:oBrw,oPCDEPREC:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSAVE.BMP";
          ACTION oPCDEPREC:GUADARDEP()

   oBtn:cToolTip:="Guardar Depreciaciones"




  
/*
   IF Empty(oPCDEPREC:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","PCDEPREC")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","PCDEPREC"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oPCDEPREC:oBrw,"PCDEPREC",oPCDEPREC:cSql,oPCDEPREC:nPeriodo,oPCDEPREC:dDesde,oPCDEPREC:dHasta,oPCDEPREC)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oPCDEPREC:oBtnRun:=oBtn



       oPCDEPREC:oBrw:bLDblClick:={||EVAL(oPCDEPREC:oBtnRun:bAction) }


   ENDIF



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oPCDEPREC:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oPCDEPREC:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oPCDEPREC:oBrw);
          WHEN LEN(oPCDEPREC:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"



IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oPCDEPREC:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oPCDEPREC)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


IF nWidth>400

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oPCDEPREC:oBrw,oPCDEPREC:cTitle,oPCDEPREC:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oPCDEPREC:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oPCDEPREC:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oPCDEPREC:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oPCDEPREC:oBrw))

   oBtn:cToolTip:="Previsualización"

   oPCDEPREC:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRPCDEPREC")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oPCDEPREC:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oPCDEPREC:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oPCDEPREC:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oPCDEPREC:oBrw:GoTop(),oPCDEPREC:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oPCDEPREC:oBrw:PageDown(),oPCDEPREC:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oPCDEPREC:oBrw:PageUp(),oPCDEPREC:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oPCDEPREC:oBrw:GoBottom(),oPCDEPREC:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oPCDEPREC:Close()

  oPCDEPREC:oBrw:SetColor(0,oPCDEPREC:nClrPane1)

  EVAL(oPCDEPREC:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oPCDEPREC:oBar:=oBar

  

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()


RETURN .T.


/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRPCDEPREC",cWhere)
  oRep:cSql  :=oPCDEPREC:cSql
  oRep:cTitle:=oPCDEPREC:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oPCDEPREC:oPeriodo:nAt,cWhere

  oPCDEPREC:nPeriodo:=nPeriodo


  IF oPCDEPREC:oPeriodo:nAt=LEN(oPCDEPREC:oPeriodo:aItems)

     oPCDEPREC:oDesde:ForWhen(.T.)
     oPCDEPREC:oHasta:ForWhen(.T.)
     oPCDEPREC:oBtn  :ForWhen(.T.)

     DPFOCUS(oPCDEPREC:oDesde)

  ELSE

     oPCDEPREC:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oPCDEPREC:oDesde:VarPut(oPCDEPREC:aFechas[1] , .T. )
     oPCDEPREC:oHasta:VarPut(oPCDEPREC:aFechas[2] , .T. )

     oPCDEPREC:dDesde:=oPCDEPREC:aFechas[1]
     oPCDEPREC:dHasta:=oPCDEPREC:aFechas[2]

     cWhere:=oPCDEPREC:HACERWHERE(oPCDEPREC:dDesde,oPCDEPREC:dHasta,oPCDEPREC:cWhere,.T.)

     oPCDEPREC:LEERDATA(cWhere,oPCDEPREC:oBrw,oPCDEPREC:cServer)

  ENDIF

  oPCDEPREC:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF ""$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       
   ELSE
     IF !Empty(dHasta)
       
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oPCDEPREC:cWhereQry)
       cWhere:=cWhere + oPCDEPREC:cWhereQry
     ENDIF

     oPCDEPREC:LEERDATA(cWhere,oPCDEPREC:oBrw,oPCDEPREC:cServer)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL oDb

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF


   cSql:=" SELECT "+;
          " DEP_CODACT,"+;
          " ATV_DESCRI,"+;
          " YEAR(DEP_FECHA),"+;
          " SUM(DEP_MONTO),"+;
          " SUM(DEP_MONTO)/100000,"+;
          " SUM(DEP_MTOORG),"+;
          " SUM(DEP_MTOORG)/100000,"+;
          " MIN(DEP_FECHA),"+;
          " MAX(DEP_FECHA)"+;
          " FROM DPDEPRECIAACT_HIS"+;
          " LEFT JOIN DPACTIVOS ON DEP_CODACT=ATV_CODIGO"+;
          " GROUP BY DEP_CODACT,ATV_DESCRI,YEAR(DEP_FECHA)"+;
""

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.F.

   DPWRITE("TEMP\BRPCDEPREC.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','',0,0,0,0,0,CTOD(""),CTOD("")})
   ENDIF

   IF ValType(oBrw)="O"

      oPCDEPREC:cSql   :=cSql
      oPCDEPREC:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oPCDEPREC:oBrw:aCols[3]
         oCol:cFooter      :=FDP(aTotal[3],'9999')
      oCol:=oPCDEPREC:oBrw:aCols[4]
         oCol:cFooter      :=FDP(aTotal[4],'999,999,999.99')
      oCol:=oPCDEPREC:oBrw:aCols[5]
         oCol:cFooter      :=FDP(aTotal[5],'999,999,999.99')
      oCol:=oPCDEPREC:oBrw:aCols[6]
         oCol:cFooter      :=FDP(aTotal[6],'999,999,999.99')
      oCol:=oPCDEPREC:oBrw:aCols[7]
         oCol:cFooter      :=FDP(aTotal[7],'999,999,999.99')

      oPCDEPREC:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oPCDEPREC:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oPCDEPREC:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRPCDEPREC.MEM",V_nPeriodo:=oPCDEPREC:nPeriodo
  LOCAL V_dDesde:=oPCDEPREC:dDesde
  LOCAL V_dHasta:=oPCDEPREC:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oPCDEPREC)
RETURN .T.

/*
// Ejecución Cambio de Linea 
*/
FUNCTION BRWCHANGE()
RETURN NIL

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()
    LOCAL cWhere


    IF Type("oPCDEPREC")="O" .AND. oPCDEPREC:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oPCDEPREC:cWhere_),oPCDEPREC:cWhere_,oPCDEPREC:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oPCDEPREC:LEERDATA(oPCDEPREC:cWhere_,oPCDEPREC:oBrw,oPCDEPREC:cServer)
      oPCDEPREC:oWnd:Show()
      oPCDEPREC:oWnd:Maximize()

    ENDIF

RETURN NIL

/*
// Genera Correspondencia Masiva
*/


FUNCTION GUADARDEP()
  LOCAL I,oOrg,aLine,cWhere,cNumEje
  LOCAL oTable

  IF !MsgNoYes("Desea Reincorporar Depreciaciones Depuradas hacia Depreciaciones Reconvertidas")
      RETURN .F.
  ENDIF

  oTable:=OpenTable("SELECT * FROM DPDEPRECIAACT",.F.)

  FOR I=1 TO LEN(oPCDEPREC:oBrw:aArrayData)

     IF I%10=0
         MsgRun("Registro "+LSTR(I)+"/"+LSTR(LEN(oPCDEPREC:oBrw:aArrayData)))
     ENDIF

     aLine  :=oPCDEPREC:oBrw:aArrayData[I]

     cNumEje:=EJECUTAR("GETNUMEJE",aLine[9],.T.)
     cWhere :="DEP_CODACT"+GetWhere("=",aLine[1])

     oOrg:=OpenTable("SELECT * FROM DPDEPRECIAACT_HIS WHERE "+cWhere+" LIMIT 1",.T.)
//   oOrg:Browse()  

     SQLDELETE("DPDEPRECIAACT",cWhere+" AND "+GetWhereAnd("DEP_FECHA",aLine[8],aLine[9]))

     oTable:AppendBlank()
     AEVAL(oOrg:aFields,{|a,n| oTable:Replace(a[1],oOrg:FieldGet(a[1]))})
     oTable:Replace("DEP_FECHA" ,aLine[9])
     oTable:Replace("DEP_MONTO" ,aLine[5])
     oTable:Replace("DEP_MTOORG",aLine[7])
     oTable:Replace("DEP_CODMON",oDp:cMoneda)
     oTable:Replace("DEP_NUMEJE",cNumEje    ) // Numero del Ejercicio
     oTable:Replace("DEP_ESTADO","A"        ) // Activos
     oTable:Commit()

  NEXT I

  oTable:End()
  
  MsgAlert("Proceso Concluido "+LSTR(LEN(oPCDEPREC:oBrw:aArrayData)))

RETURN 



 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oPCDEPREC)
// EOF