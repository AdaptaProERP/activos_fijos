// Programa   : BRAXIINI
// Fecha/Hora : 19/10/2014 12:36:37
// Propósito  : "Ajuste Inicial y Fiscal de Activos"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRAXIINI.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SDB_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 


   cTitle:="Ajuste Inicial y Fiscal de Activos" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4 


   // Obtiene el Código del Parámetro

   IF !Empty(cWhere)
 
      cCodPar:=ATAIL(_VECTOR(cWhere,"="))
 
      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF .T.

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

   ViewData(aData,cTitle)

   oDp:oFrm:=oAXIINI
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)


   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DPEDIT():New(cTitle,"BRAXIINI.EDT","oAXIINI",.F.)

   oAXIINI:CreateWindow(NIL,NIL,NIL,550,850+58)

   oAXIINI:cCodSuc  :=cCodSuc
   oAXIINI:lMsgBar  :=.F.
   oAXIINI:cPeriodo :=aPeriodos[nPeriodo]
   oAXIINI:cCodSuc  :=cCodSuc
   oAXIINI:nPeriodo :=nPeriodo
   oAXIINI:cNombre  :=""
   oAXIINI:dDesde   :=dDesde
   oAXIINI:cServer  :=cServer
   oAXIINI:dHasta   :=dHasta
   oAXIINI:cWhere   :=cWhere
   oAXIINI:cWhere_  :=""
   oAXIINI:cWhereQry:=""
   oAXIINI:cSql     :=oDp:cSql
   oAXIINI:oWhere   :=TWHERE():New(oAXIINI)
   oAXIINI:cCodPar  :=cCodPar // Código del Parámetro


   oAXIINI:oBrw:=TXBrowse():New( oAXIINI:oDlg )
   oAXIINI:oBrw:SetArray( aData, .F. )
   oAXIINI:oBrw:SetFont(oFont)

   oAXIINI:oBrw:lFooter     := .T.
   oAXIINI:oBrw:lHScroll    := .T.
   oAXIINI:oBrw:nHeaderLines:= 3
   oAXIINI:oBrw:nDataLines  := 1
   oAXIINI:oBrw:nFooterLines:= 1

   oAXIINI:aData            :=ACLONE(aData)

   AEVAL(oAXIINI:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})
  

  oCol:=oAXIINI:oBrw:aCols[1]
  oCol:cHeader      :='A'+CRLF+'Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIINI:oBrw:aArrayData ) } 
  oCol:nWidth       := 300

  oCol:=oAXIINI:oBrw:aCols[2]
  oCol:cHeader      :='B'+CRLF+'Fecha Adq.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIINI:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oAXIINI:oBrw:aCols[3]
  oCol:cHeader      :='C'+CRLF+'IPC Cierre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIINI:oBrw:aArrayData ) } 
  oCol:nWidth       := 70
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIINI:oBrw:aArrayData[oAXIINI:oBrw:nArrayAt,3],FDP(nMonto,'999.99999')}



  oCol:=oAXIINI:oBrw:aCols[4]
  oCol:cHeader      :='D'+CRLF+'IPC Fin'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIINI:oBrw:aArrayData ) } 
  oCol:nWidth       := 70
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIINI:oBrw:aArrayData[oAXIINI:oBrw:nArrayAt,4],FDP(nMonto,'999.99999')}



  oCol:=oAXIINI:oBrw:aCols[5]
  oCol:cHeader      :='E'+CRLF+'Factor'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIINI:oBrw:aArrayData ) } 
  oCol:nWidth       := 70
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIINI:oBrw:aArrayData[oAXIINI:oBrw:nArrayAt,5],FDP(nMonto,'999.99999')}



  oCol:=oAXIINI:oBrw:aCols[6]
  oCol:cHeader      :='F'+CRLF+'Costo Histórico'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIINI:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIINI:oBrw:aArrayData[oAXIINI:oBrw:nArrayAt,6],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[6],'999,999,999.99')


  oCol:=oAXIINI:oBrw:aCols[7]
  oCol:cHeader      :="G"+CRLF+"Costo Histórico"+CRLF+"Actualizado"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIINI:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIINI:oBrw:aArrayData[oAXIINI:oBrw:nArrayAt,7],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[7],'999,999,999.99')


  oCol:=oAXIINI:oBrw:aCols[8]
  oCol:cHeader      :='H'+CRLF+'Dep. Acumulada'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIINI:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIINI:oBrw:aArrayData[oAXIINI:oBrw:nArrayAt,8],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[8],'999,999,999.99')


  oCol:=oAXIINI:oBrw:aCols[9]
  oCol:cHeader      :='I'+CRLF+'Dep. Acumulada Actz.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIINI:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIINI:oBrw:aArrayData[oAXIINI:oBrw:nArrayAt,9],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[9],'999,999,999.99')


  oCol:=oAXIINI:oBrw:aCols[10]
  oCol:cHeader      :='J'+CRLF+"Ajuste Inicial"+CRLF+"Costo"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIINI:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIINI:oBrw:aArrayData[oAXIINI:oBrw:nArrayAt,10],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[10],'999,999,999.99')


  oCol:=oAXIINI:oBrw:aCols[11]
  oCol:cHeader      :='K=I-H'+CRLF+"Ajuste Inicial"+CRLF+"Depreciación"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIINI:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIINI:oBrw:aArrayData[oAXIINI:oBrw:nArrayAt,11],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[11],'999,999,999.99')


  oCol:=oAXIINI:oBrw:aCols[12]
  oCol:cHeader      :='L=J-K'+CRLF+"Ajuste Inicial"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIINI:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIINI:oBrw:aArrayData[oAXIINI:oBrw:nArrayAt,12],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[12],'999,999,999.99')


  oCol:=oAXIINI:oBrw:aCols[13]
  oCol:cHeader      :='M=L*3%'+CRLF+"Reg.Activo"+CRLF+"Actualizado"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIINI:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIINI:oBrw:aArrayData[oAXIINI:oBrw:nArrayAt,13],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[13],'999,999,999.99')


   oAXIINI:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oAXIINI:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oAXIINI:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 16383993, 14876633 ) } }

   oAXIINI:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oAXIINI:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oAXIINI:oBrw:bLDblClick:={|oBrw|oAXIINI:oRep:=oAXIINI:RUNCLICK() }

   oAXIINI:oBrw:bChange:={||oAXIINI:BRWCHANGE()}
   oAXIINI:oBrw:CreateFromCode()

   oAXIINI:Activate({||oAXIINI:ViewDatBar(oAXIINI)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oAXIINI)
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oAXIINI:oDlg
   LOCAL nLin:=0

   oAXIINI:oBrw:GoBottom(.T.)
   oAXIINI:oBrw:Refresh(.T.)

   IF !File("FORMS\BRAXIINI.EDT")
     oAXIINI:oBrw:Move(44,0,850+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD


   IF .F. .AND. Empty(oAXIINI:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oAXIINI:oBrw,oAXIINI:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

   IF .F.

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EMAIL.BMP";
            ACTION oAXIINI:GENMAIL()

     oBtn:cToolTip:="Generar Correspondencia Masiva"


   ENDIF

  

   IF Empty(oAXIINI:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","AXIINI")))

         DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\XBROWSE.BMP";
         ACTION EJECUTAR("BRWRUNBRWLINK",oAXIINI:oBrw,"AXIINI",oAXIINI:cSql,oAXIINI:nPeriodo,oAXIINI:dDesde,oAXIINI:dHasta)

         oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"

         oAXIINI:oBtnRun:=oBtn

         oAXIINI:oBrw:bLDblClick:={||EVAL(oAXIINI:oBtnRun:bAction) }


   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oAXIINI:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oAXIINI:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oAXIINI)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oAXIINI:oBrw,oAXIINI:cTitle,oAXIINI:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   oAXIINI:oBtnXls:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oAXIINI:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oAXIINI:oBtnHtml:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oAXIINI:oBrw))

   oBtn:cToolTip:="Previsualización"

   oAXIINI:oBtnPreview:=oBtn

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRAXIINI")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oAXIINI:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oAXIINI:oBtnPrint:=oBtn

   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oAXIINI:BRWQUERY()

   oBtn:cToolTip:="Imprimir"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oAXIINI:oBrw:GoTop(),oAXIINI:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oAXIINI:oBrw:PageDown(),oAXIINI:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oAXIINI:oBrw:PageUp(),oAXIINI:oBrw:Setfocus())


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oAXIINI:oBrw:GoBottom(),oAXIINI:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oAXIINI:Close()

  oAXIINI:oBrw:SetColor(0,16383993)

  EVAL(oAXIINI:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oAXIINI:oBar:=oBar

  

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

  oRep:=REPORTE("BRAXIINI",cWhere)
  oRep:cSql  :=oAXIINI:cSql
  oRep:cTitle:=oAXIINI:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oAXIINI:oPeriodo:nAt,cWhere

  oAXIINI:nPeriodo:=nPeriodo

  IF oAXIINI:oPeriodo:nAt=LEN(oAXIINI:oPeriodo:aItems)

     oAXIINI:oDesde:ForWhen(.T.)
     oAXIINI:oHasta:ForWhen(.T.)
     oAXIINI:oBtn  :ForWhen(.T.)

     DPFOCUS(oAXIINI:oDesde)

  ELSE

     oAXIINI:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oAXIINI:oDesde:VarPut(oAXIINI:aFechas[1] , .T. )
     oAXIINI:oHasta:VarPut(oAXIINI:aFechas[2] , .T. )

     oAXIINI:dDesde:=oAXIINI:aFechas[1]
     oAXIINI:dHasta:=oAXIINI:aFechas[2]

     cWhere:=oAXIINI:HACERWHERE(oAXIINI:dDesde,oAXIINI:dHasta,oAXIINI:cWhere,.T.)

     oAXIINI:LEERDATA(cWhere,oAXIINI:oBrw,oAXIINI:cServer)

  ENDIF

  oAXIINI:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   IF !Empty(dDesde)
       
   ELSE
     IF !Empty(dHasta)
       
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oAXIINI:cWhereQry)
       cWhere:=cWhere + oAXIINI:cWhereQry
     ENDIF

     oAXIINI:LEERDATA(cWhere,oAXIINI:oBrw,oAXIINI:cServer)

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


   cSql:=" SELECT ATV_DESCRI AS A, "+;
          "  ATV_FCHADQ AS B, "+;
          "  MIN(DEP_IPCINI) AS C, "+;
          "  MAX(DEP_IPCFIN) AS D, "+;
          "  MIN(DEP_IPCINI)/MAX(DEP_IPCFIN) AS E, "+;
          "  ATV_COSADQ AS F, "+;
          "  SUM(DEP_MTOFIS)+ATV_COSADQ AS G, "+;
          "  SUM(DEP_MONTO) AS H, "+;
          "  SUM(DEP_DEPFIS+DEP_MONTO) AS I, "+;
          "  SUM(DEP_MTOFIS) AS J, "+;
          "  SUM(DEP_DEPFIS) AS K, "+;
          "  SUM(DEP_MONTO-DEP_MTOFIS) AS L, "+;
          "  SUM(DEP_MONTO-DEP_MTOFIS)*.3 AS M "+;
          "  FROM DPDEPRECIAACT "+;
          "  INNER JOIN DPACTIVOS ON ATV_CODIGO=DEP_CODACT "+;
          "  WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" DEP_TIPTRA='D' "+;
          "  GROUP BY ATV_CODIGO "+;
""

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)


   aData:=ASQL(cSql,oDb)

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql)
//    AADD(aData,{'',CTOD(""),0,0,0,0,0,0,0,0,0,0,0})
   ENDIF

   IF ValType(oBrw)="O"

      oAXIINI:cSql   :=cSql
      oAXIINI:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oAXIINI:oBrw:aCols[3]
      
      oCol:=oAXIINI:oBrw:aCols[4]
      
      oCol:=oAXIINI:oBrw:aCols[5]
      
      oCol:=oAXIINI:oBrw:aCols[6]
         oCol:cFooter      :=FDP(aTotal[6],'999,999,999.99')
      oCol:=oAXIINI:oBrw:aCols[7]
         oCol:cFooter      :=FDP(aTotal[7],'999,999,999.99')
      oCol:=oAXIINI:oBrw:aCols[8]
         oCol:cFooter      :=FDP(aTotal[8],'999,999,999.99')
      oCol:=oAXIINI:oBrw:aCols[9]
         oCol:cFooter      :=FDP(aTotal[9],'999,999,999.99')
      oCol:=oAXIINI:oBrw:aCols[10]
         oCol:cFooter      :=FDP(aTotal[10],'999,999,999.99')
      oCol:=oAXIINI:oBrw:aCols[11]
         oCol:cFooter      :=FDP(aTotal[11],'999,999,999.99')
      oCol:=oAXIINI:oBrw:aCols[12]
         oCol:cFooter      :=FDP(aTotal[12],'999,999,999.99')
      oCol:=oAXIINI:oBrw:aCols[13]
         oCol:cFooter      :=FDP(aTotal[13],'999,999,999.99')

      oAXIINI:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oAXIINI:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oAXIINI:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRAXIINI.MEM",V_nPeriodo:=oAXIINI:nPeriodo
  LOCAL V_dDesde:=oAXIINI:dDesde
  LOCAL V_dHasta:=oAXIINI:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oAXIINI)
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

    IF Type("oAXIINI")="O" .AND. oAXIINI:oWnd:hWnd>0

      oAXIINI:LEERDATA(oAXIINI:cWhere_,oAXIINI:oBrw,oAXIINI:cServer)
      oAXIINI:oWnd:Show()
      oAXIINI:oWnd:Maximize()

    ENDIF

RETURN NIL

/*
// Genera Correspondencia Masiva
*/


// EOF
