// Programa   : BRAXIFISCED
// Fecha/Hora : 21/10/2014 11:34:50
// Propósito  : "Cedula de Ajuste Fiscal de Activos"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo,cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRAXIFISCED.MEM",V_nPeriodo:=9,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   DEFAULT cCodigo :=SQLGET("DPACTIVOS","ATV_CODIGO"),;
           cCodSuc :=oDp:cSucursal,;
           cWhere  :="DEP_CODACT"+GetWhere("=",cCodigo)

   oDp:cRunServer:=NIL

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SDB_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 


   cTitle:="Cedula de Ajuste Fiscal de Activos" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=9 


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

   oDp:oFrm:=oAXIFISCED
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)


   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DPEDIT():New(cTitle,"BRAXIFISCED.EDT","oAXIFISCED",.F.)

   oAXIFISCED:CreateWindow(NIL,NIL,NIL,550,140+58)

   oAXIFISCED:cCodSuc  :=cCodSuc
   oAXIFISCED:lMsgBar  :=.F.
   oAXIFISCED:cPeriodo :=aPeriodos[nPeriodo]
   oAXIFISCED:cCodSuc  :=cCodSuc
   oAXIFISCED:nPeriodo :=nPeriodo
   oAXIFISCED:cNombre  :=""
   oAXIFISCED:dDesde   :=dDesde
   oAXIFISCED:cServer  :=cServer
   oAXIFISCED:dHasta   :=dHasta
   oAXIFISCED:cWhere   :=cWhere
   oAXIFISCED:cWhere_  :=""
   oAXIFISCED:cWhereQry:=""
   oAXIFISCED:cSql     :=oDp:cSql
   oAXIFISCED:oWhere   :=TWHERE():New(oAXIFISCED)
   oAXIFISCED:cCodPar  :=cCodPar // Código del Parámetro


   oAXIFISCED:oBrw:=TXBrowse():New( oAXIFISCED:oDlg )
   oAXIFISCED:oBrw:SetArray( aData, .T. )
   oAXIFISCED:oBrw:SetFont(oFont)

   oAXIFISCED:oBrw:lFooter     := .T.
   oAXIFISCED:oBrw:lHScroll    := .F.
   oAXIFISCED:oBrw:nHeaderLines:= 3
   oAXIFISCED:oBrw:nDataLines  := 1
   oAXIFISCED:oBrw:nFooterLines:= 1

   oAXIFISCED:aData            :=ACLONE(aData)

   AEVAL(oAXIFISCED:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})
  

  oCol:=oAXIFISCED:oBrw:aCols[1]
  oCol:cHeader      :='A'+CRLF+"Fecha"+CRLF+"Desde"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIFISCED:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oAXIFISCED:oBrw:aCols[2]
  oCol:cHeader      :='B'+CRLF+"Fecha"+CRLF+"Hasta"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIFISCED:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oAXIFISCED:oBrw:aCols[3]
  oCol:cHeader      :='C'+CRLF+'IPC Cierre'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIFISCED:oBrw:aArrayData ) } 
  oCol:nWidth       := 70
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIFISCED:oBrw:aArrayData[oAXIFISCED:oBrw:nArrayAt,3],FDP(nMonto,'999.99999')}



  oCol:=oAXIFISCED:oBrw:aCols[4]
  oCol:cHeader      :='D'+CRLF+'IPC Fin'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIFISCED:oBrw:aArrayData ) } 
  oCol:nWidth       := 70
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIFISCED:oBrw:aArrayData[oAXIFISCED:oBrw:nArrayAt,4],FDP(nMonto,'999.99999')}



  oCol:=oAXIFISCED:oBrw:aCols[5]
  oCol:cHeader      :='E'+CRLF+'Factor'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIFISCED:oBrw:aArrayData ) } 
  oCol:nWidth       := 70
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIFISCED:oBrw:aArrayData[oAXIFISCED:oBrw:nArrayAt,5],FDP(nMonto,'999.99999')}



  oCol:=oAXIFISCED:oBrw:aCols[6]
  oCol:cHeader      :='F'+CRLF+'Costo Histórico'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIFISCED:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIFISCED:oBrw:aArrayData[oAXIFISCED:oBrw:nArrayAt,6],FDP(nMonto,'999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[6],'999,999,999.99')


  oCol:=oAXIFISCED:oBrw:aCols[7]
  oCol:cHeader      :="G"+CRLF+"Costo Histórico"+CRLF+"Actualizado"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIFISCED:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIFISCED:oBrw:aArrayData[oAXIFISCED:oBrw:nArrayAt,7],FDP(nMonto,'999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[7],'999,999,999.99')


  oCol:=oAXIFISCED:oBrw:aCols[8]
  oCol:cHeader      :='H'+CRLF+'Dep. Acumulada'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIFISCED:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIFISCED:oBrw:aArrayData[oAXIFISCED:oBrw:nArrayAt,8],FDP(nMonto,'999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[8],'999,999,999.99')


  oCol:=oAXIFISCED:oBrw:aCols[9]
  oCol:cHeader      :='I'+CRLF+'Dep. Acumulada Actz.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIFISCED:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIFISCED:oBrw:aArrayData[oAXIFISCED:oBrw:nArrayAt,9],FDP(nMonto,'999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[9],'999,999,999.99')


  oCol:=oAXIFISCED:oBrw:aCols[10]
  oCol:cHeader      :='J'+CRLF+"Ajuste Inicial"+CRLF+"Costo"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIFISCED:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIFISCED:oBrw:aArrayData[oAXIFISCED:oBrw:nArrayAt,10],FDP(nMonto,'999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[10],'999,999,999.99')


  oCol:=oAXIFISCED:oBrw:aCols[11]
  oCol:cHeader      :='K=I-H'+CRLF+"Ajuste Inicial"+CRLF+"Depreciación"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIFISCED:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIFISCED:oBrw:aArrayData[oAXIFISCED:oBrw:nArrayAt,11],FDP(nMonto,'999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[11],'999,999,999.99')


  oCol:=oAXIFISCED:oBrw:aCols[12]
  oCol:cHeader      :='L=J-K'+CRLF+"Variación"+CRLF+"Ajuste"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oAXIFISCED:oBrw:aArrayData ) } 
  oCol:nWidth       := 110
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oAXIFISCED:oBrw:aArrayData[oAXIFISCED:oBrw:nArrayAt,12],FDP(nMonto,'999,999,999.99')}
  oCol:cFooter      :=FDP(aTotal[12],'999,999,999.99')

  oAXIFISCED:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oAXIFISCED:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oAXIFISCED:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 15794145, 14286796 ) } }

   oAXIFISCED:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oAXIFISCED:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oAXIFISCED:oBrw:bLDblClick:={|oBrw|oAXIFISCED:oRep:=oAXIFISCED:RUNCLICK() }

   oAXIFISCED:oBrw:bChange:={||oAXIFISCED:BRWCHANGE()}
   oAXIFISCED:oBrw:CreateFromCode()

   oAXIFISCED:Activate({||oAXIFISCED:ViewDatBar(oAXIFISCED)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oAXIFISCED)
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oAXIFISCED:oDlg
   LOCAL nLin:=0

   oAXIFISCED:oBrw:GoBottom(.T.)
   oAXIFISCED:oBrw:Refresh(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD


   IF .F. .AND. Empty(oAXIFISCED:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oAXIFISCED:oBrw,oAXIFISCED:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

   IF .F.

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EMAIL.BMP";
            ACTION oAXIFISCED:GENMAIL()

     oBtn:cToolTip:="Generar Correspondencia Masiva"


   ENDIF

  

   IF Empty(oAXIFISCED:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","AXIFISCED")))

         DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\XBROWSE.BMP";
         ACTION EJECUTAR("BRWRUNBRWLINK",oAXIFISCED:oBrw,"AXIFISCED",oAXIFISCED:cSql,oAXIFISCED:nPeriodo,oAXIFISCED:dDesde,oAXIFISCED:dHasta)

         oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"

         oAXIFISCED:oBtnRun:=oBtn

         oAXIFISCED:oBrw:bLDblClick:={||EVAL(oAXIFISCED:oBtnRun:bAction) }


   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oAXIFISCED:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oAXIFISCED:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oAXIFISCED)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oAXIFISCED:oBrw,oAXIFISCED:cTitle,oAXIFISCED:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   oAXIFISCED:oBtnXls:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oAXIFISCED:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oAXIFISCED:oBtnHtml:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oAXIFISCED:oBrw))

   oBtn:cToolTip:="Previsualización"

   oAXIFISCED:oBtnPreview:=oBtn

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRAXIFISCED")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oAXIFISCED:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oAXIFISCED:oBtnPrint:=oBtn

   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oAXIFISCED:BRWQUERY()

   oBtn:cToolTip:="Imprimir"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oAXIFISCED:oBrw:GoTop(),oAXIFISCED:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oAXIFISCED:oBrw:PageDown(),oAXIFISCED:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oAXIFISCED:oBrw:PageUp(),oAXIFISCED:oBrw:Setfocus())


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oAXIFISCED:oBrw:GoBottom(),oAXIFISCED:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oAXIFISCED:Close()

  oAXIFISCED:oBrw:SetColor(0,15794145)

  EVAL(oAXIFISCED:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oAXIFISCED:oBar:=oBar

  nLin:=620

  //
  // Campo : Periodo
  //

  @ 10, nLin COMBOBOX oAXIFISCED:oPeriodo  VAR oAXIFISCED:cPeriodo ITEMS aPeriodos;
                SIZE 100,NIL;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oAXIFISCED:LEEFECHAS()
  ComboIni(oAXIFISCED:oPeriodo )

  @ 10, nLin+103 BUTTON oAXIFISCED:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oAXIFISCED:oPeriodo:nAt,oAXIFISCED:oDesde,oAXIFISCED:oHasta,-1),;
                         EVAL(oAXIFISCED:oBtn:bAction))



  @ 10, nLin+130 BUTTON oAXIFISCED:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oAXIFISCED:oPeriodo:nAt,oAXIFISCED:oDesde,oAXIFISCED:oHasta,+1),;
                         EVAL(oAXIFISCED:oBtn:bAction))


  @ 10, nLin+170 BMPGET oAXIFISCED:oDesde  VAR oAXIFISCED:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oAXIFISCED:oDesde ,oAXIFISCED:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oAXIFISCED:oPeriodo:nAt=LEN(oAXIFISCED:oPeriodo:aItems);
                FONT oFont

   oAXIFISCED:oDesde:cToolTip:="F6: Calendario"

  @ 10, nLin+252 BMPGET oAXIFISCED:oHasta  VAR oAXIFISCED:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oAXIFISCED:oHasta,oAXIFISCED:dHasta);
                SIZE 80,23;
                WHEN oAXIFISCED:oPeriodo:nAt=LEN(oAXIFISCED:oPeriodo:aItems);
                OF oBar;
                FONT oFont

   oAXIFISCED:oHasta:cToolTip:="F6: Calendario"

   @ 10, nLin+335 BUTTON oAXIFISCED:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oAXIFISCED:oPeriodo:nAt=LEN(oAXIFISCED:oPeriodo:aItems);
               ACTION oAXIFISCED:HACERWHERE(oAXIFISCED:dDesde,oAXIFISCED:dHasta,oAXIFISCED:cWhere,.T.)




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

  oRep:=REPORTE("BRAXIFISCED",cWhere)
  oRep:cSql  :=oAXIFISCED:cSql
  oRep:cTitle:=oAXIFISCED:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oAXIFISCED:oPeriodo:nAt,cWhere

  oAXIFISCED:nPeriodo:=nPeriodo

  IF oAXIFISCED:oPeriodo:nAt=LEN(oAXIFISCED:oPeriodo:aItems)

     oAXIFISCED:oDesde:ForWhen(.T.)
     oAXIFISCED:oHasta:ForWhen(.T.)
     oAXIFISCED:oBtn  :ForWhen(.T.)

     DPFOCUS(oAXIFISCED:oDesde)

  ELSE

     oAXIFISCED:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oAXIFISCED:oDesde:VarPut(oAXIFISCED:aFechas[1] , .T. )
     oAXIFISCED:oHasta:VarPut(oAXIFISCED:aFechas[2] , .T. )

     oAXIFISCED:dDesde:=oAXIFISCED:aFechas[1]
     oAXIFISCED:dHasta:=oAXIFISCED:aFechas[2]

     cWhere:=oAXIFISCED:HACERWHERE(oAXIFISCED:dDesde,oAXIFISCED:dHasta,oAXIFISCED:cWhere,.T.)

     oAXIFISCED:LEERDATA(cWhere,oAXIFISCED:oBrw,oAXIFISCED:cServer)

  ENDIF

  oAXIFISCED:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('DPDEPRECIAACT .DEP_FECHA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('DPDEPRECIAACT .DEP_FECHA',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oAXIFISCED:cWhereQry)
       cWhere:=cWhere + oAXIFISCED:cWhereQry
     ENDIF

     oAXIFISCED:LEERDATA(cWhere,oAXIFISCED:oBrw,oAXIFISCED:cServer)

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


   cSql:=" SELECT DEP_FCHFIS AS A,"+;
          " DEP_FECHA AS B,"+;
          " DEP_IPCINI AS C,"+;
          " DEP_IPCFIN AS D,"+;
          " DEP_IPCINI/DEP_IPCFIN AS E,"+;
          " ATV_COSADQ AS F,"+;
          " DEP_MTOFIS+ATV_COSADQ AS G,"+;
          " DEP_MONTO AS H, "+;
          " DEP_DEPFIS+DEP_MONTO AS I,  "+;
          " DEP_MTOFIS AS J,  "+;
          " DEP_DEPFIS AS K,"+;
          " DEP_MONTO-DEP_MTOFIS AS L"+;
          " FROM DPDEPRECIAACT"+;
          "  INNER JOIN DPACTIVOS ON ATV_CODIGO=DEP_CODACT  "+;
          "  WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" DEP_TIPTRA='D'"+;
""

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql :=EJECUTAR("WHERE_VAR",cSql)
   aData:=ASQL(cSql,oDb)

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql)
//    AADD(aData,{CTOD(""),CTOD(""),0,0,0,0,0,0,0,0,0,0})
   ENDIF

   IF ValType(oBrw)="O"

      oAXIFISCED:cSql   :=cSql
      oAXIFISCED:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oAXIFISCED:oBrw:aCols[3]
         oCol:cFooter      :=FDP(aTotal[3],'999,999,999.99')
      oCol:=oAXIFISCED:oBrw:aCols[4]
         oCol:cFooter      :=FDP(aTotal[4],'999,999,999.99')
      oCol:=oAXIFISCED:oBrw:aCols[5]
         oCol:cFooter      :=FDP(aTotal[5],'999,999,999.99')
      oCol:=oAXIFISCED:oBrw:aCols[6]
         oCol:cFooter      :=FDP(aTotal[6],'999,999,999.99')
      oCol:=oAXIFISCED:oBrw:aCols[7]
         oCol:cFooter      :=FDP(aTotal[7],'999,999,999.99')
      oCol:=oAXIFISCED:oBrw:aCols[8]
         oCol:cFooter      :=FDP(aTotal[8],'999,999,999.99')
      oCol:=oAXIFISCED:oBrw:aCols[9]
         oCol:cFooter      :=FDP(aTotal[9],'999,999,999.99')
      oCol:=oAXIFISCED:oBrw:aCols[10]
         oCol:cFooter      :=FDP(aTotal[10],'999,999,999.99')
      oCol:=oAXIFISCED:oBrw:aCols[11]
         oCol:cFooter      :=FDP(aTotal[11],'999,999,999.99')
      oCol:=oAXIFISCED:oBrw:aCols[12]
         oCol:cFooter      :=FDP(aTotal[12],'999,999,999.99')

      oAXIFISCED:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oAXIFISCED:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oAXIFISCED:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRAXIFISCED.MEM",V_nPeriodo:=oAXIFISCED:nPeriodo
  LOCAL V_dDesde:=oAXIFISCED:dDesde
  LOCAL V_dHasta:=oAXIFISCED:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oAXIFISCED)
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

    IF Type("oAXIFISCED")="O" .AND. oAXIFISCED:oWnd:hWnd>0

      oAXIFISCED:LEERDATA(oAXIFISCED:cWhere_,oAXIFISCED:oBrw,oAXIFISCED:cServer)
      oAXIFISCED:oWnd:Show()
      oAXIFISCED:oWnd:Maximize()

    ENDIF

RETURN NIL

/*
// Genera Correspondencia Masiva
*/


// EOF
