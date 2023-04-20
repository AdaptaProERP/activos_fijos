// Programa   : BRACTXGRU
// Fecha/Hora : 15/11/2014 17:29:53
// Propósito  : "Todos los Activos"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRACTXGRU.MEM",V_nPeriodo:=7,cCodPar
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


   cTitle:="Todos los Activos" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=10 


   // Obtiene el Código del Parámetro

   IF !Empty(cWhere)
 
      cCodPar:=ATAIL(_VECTOR(cWhere,"="))
 
      IF TYPE(cCodPar)="C"
        cCodPar:=SUBS(cCodPar,2,LEN(cCodPar))
        cCodPar:=LEFT(cCodPar,LEN(cCodPar)-1)
      ENDIF

   ENDIF

   IF Empty(dDesde)
      aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
      dDesde :=aFechas[1]
      dHasta :=aFechas[2]
   ENDIF

   aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle)

   oDp:oFrm:=oACTXGRU
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)


   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DPEDIT():New(cTitle,"BRACTXGRU.EDT","oACTXGRU",.F.)

   oACTXGRU:CreateWindow(NIL,NIL,NIL,550,850+58)

   oACTXGRU:cCodSuc  :=cCodSuc
   oACTXGRU:lMsgBar  :=.F.
   oACTXGRU:cPeriodo :=aPeriodos[nPeriodo]
   oACTXGRU:cCodSuc  :=cCodSuc
   oACTXGRU:nPeriodo :=nPeriodo
   oACTXGRU:cNombre  :=""
   oACTXGRU:dDesde   :=dDesde
   oACTXGRU:cServer  :=cServer
   oACTXGRU:dHasta   :=dHasta
   oACTXGRU:cWhere   :=cWhere
   oACTXGRU:cWhere_  :=""
   oACTXGRU:cWhereQry:=""
   oACTXGRU:cSql     :=oDp:cSql
   oACTXGRU:oWhere   :=TWHERE():New(oACTXGRU)
   oACTXGRU:cCodPar  :=cCodPar // Código del Parámetro


   oACTXGRU:oBrw:=TXBrowse():New( oACTXGRU:oDlg )
   oACTXGRU:oBrw:SetArray( aData, .T. )
   oACTXGRU:oBrw:SetFont(oFont)

   oACTXGRU:oBrw:lFooter     := .T.
   oACTXGRU:oBrw:lHScroll    := .F.
   oACTXGRU:oBrw:nHeaderLines:= 2
   oACTXGRU:oBrw:nDataLines  := 1
   oACTXGRU:oBrw:nFooterLines:= 1

   oACTXGRU:aData            :=ACLONE(aData)

   AEVAL(oACTXGRU:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})
   

  oCol:=oACTXGRU:oBrw:aCols[1]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXGRU:oBrw:aArrayData ) } 
  oCol:nWidth       := 120

  oCol:=oACTXGRU:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXGRU:oBrw:aArrayData ) } 
  oCol:nWidth       := 300

  oCol:=oACTXGRU:oBrw:aCols[3]
  oCol:cHeader      :='Deprec.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXGRU:oBrw:aArrayData ) } 
  oCol:nWidth       := 20

  oCol:=oACTXGRU:oBrw:aCols[4]
  oCol:cHeader      :='Ubicación'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXGRU:oBrw:aArrayData ) } 
  oCol:nWidth       := 64

  oCol:=oACTXGRU:oBrw:aCols[5]
  oCol:cHeader      :='Fecha'+CRLF+'Adq.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXGRU:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oACTXGRU:oBrw:aCols[6]
  oCol:cHeader      :='Fin'+CRLF+'Deprec'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXGRU:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oACTXGRU:oBrw:aCols[7]
  oCol:cHeader      :='Costo de Adquisición'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXGRU:oBrw:aArrayData ) } 
  oCol:nWidth       := 112
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oACTXGRU:oBrw:aArrayData[oACTXGRU:oBrw:nArrayAt,7],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[7],'999,999,999.99')


  oCol:=oACTXGRU:oBrw:aCols[8]
  oCol:cHeader      :='Monto'+CRLF+'Depreciación'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXGRU:oBrw:aArrayData ) } 
  oCol:nWidth       := 112
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oACTXGRU:oBrw:aArrayData[oACTXGRU:oBrw:nArrayAt,8],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[8],'999,999,999.99')


  oCol:=oACTXGRU:oBrw:aCols[9]
  oCol:cHeader      :='Ajuste'+CRLF+'Fiscal'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXGRU:oBrw:aArrayData ) } 
  oCol:nWidth       := 112
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oACTXGRU:oBrw:aArrayData[oACTXGRU:oBrw:nArrayAt,9],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[9],'999,999,999.99')


  oCol:=oACTXGRU:oBrw:aCols[10]
  oCol:cHeader      :='Ajuste'+CRLF+'Financiero'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXGRU:oBrw:aArrayData ) } 
  oCol:nWidth       := 112
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oACTXGRU:oBrw:aArrayData[oACTXGRU:oBrw:nArrayAt,10],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[10],'999,999,999.99')


   oACTXGRU:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oACTXGRU:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oACTXGRU:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0,oMdi:nClrPane1,oMdi:nClrPane2 ) } }

   oACTXGRU:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oACTXGRU:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oACTXGRU:oBrw:bLDblClick:={|oBrw|oACTXGRU:oRep:=oACTXGRU:RUNCLICK() }

   oACTXGRU:oBrw:bChange:={||oACTXGRU:BRWCHANGE()}
   oACTXGRU:oBrw:CreateFromCode()

   oACTXGRU:Activate({||oACTXGRU:ViewDatBar(oACTXGRU)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oACTXGRU)
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oACTXGRU:oDlg
   LOCAL nLin:=0

   oACTXGRU:oBrw:GoBottom(.T.)
   oACTXGRU:oBrw:Refresh(.T.)

   IF !File("FORMS\BRACTXGRU.EDT")
     oACTXGRU:oBrw:Move(44,0,850+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\VIEW.BMP",NIL,"BITMAPS\VIEWG.BMP";
          ACTION EJECUTAR("DPACTIVOCON",NIL,oACTXGRU:oBrw:aArrayData[oACTXGRU:oBrw:nArrayAt,1]);
          WHEN !Empty(oACTXGRU:oBrw:aArrayData[oACTXGRU:oBrw:nArrayAt,1])

   oBtn:cToolTip:="Consultar Activo"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XEDIT.BMP",NIL,"BITMAPS\XEDITG.BMP";
          ACTION oACTXGRU:ACTIVOMOD(3);
          WHEN !Empty(oACTXGRU:oBrw:aArrayData[oACTXGRU:oBrw:nArrayAt,1]) .AND. ISTABMOD("DPACTIVOS")

   oBtn:cToolTip:="Modificar Activo"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\ACTIVOS.BMP",NIL,"BITMAPS\ACTIVOSG.BMP";
          ACTION oACTXGRU:ACTIVOMOD(0);
          WHEN !Empty(oACTXGRU:oBrw:aArrayData[oACTXGRU:oBrw:nArrayAt,1]) 

   oBtn:cToolTip:="Editar Activo"


   IF Empty(oACTXGRU:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","ACTXGRU")))

         DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\XBROWSE.BMP";
         ACTION EJECUTAR("BRWRUNBRWLINK",oACTXGRU:oBrw,"ACTXGRU",oACTXGRU:cSql,oACTXGRU:nPeriodo,oACTXGRU:dDesde,oACTXGRU:dHasta)

         oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"

         oACTXGRU:oBtnRun:=oBtn

         oACTXGRU:oBrw:bLDblClick:={||EVAL(oACTXGRU:oBtnRun:bAction) }


   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oACTXGRU:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oACTXGRU:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oACTXGRU:oBrw);
          WHEN LEN(oACTXGRU:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oACTXGRU:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oACTXGRU)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oACTXGRU:oBrw,oACTXGRU:cTitle,oACTXGRU:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   oACTXGRU:oBtnXls:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oACTXGRU:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oACTXGRU:oBtnHtml:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oACTXGRU:oBrw))

   oBtn:cToolTip:="Previsualización"

   oACTXGRU:oBtnPreview:=oBtn

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRACTXGRU")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oACTXGRU:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oACTXGRU:oBtnPrint:=oBtn

   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oACTXGRU:BRWQUERY()

   oBtn:cToolTip:="Imprimir"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oACTXGRU:oBrw:GoTop(),oACTXGRU:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oACTXGRU:oBrw:PageDown(),oACTXGRU:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oACTXGRU:oBrw:PageUp(),oACTXGRU:oBrw:Setfocus())


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oACTXGRU:oBrw:GoBottom(),oACTXGRU:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oACTXGRU:Close()

  oACTXGRU:oBrw:SetColor(0,15790320)

  EVAL(oACTXGRU:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oACTXGRU:oBar:=oBar

  nLin:=490+150

  //
  // Campo : Periodo
  //

  @ 10, nLin COMBOBOX oACTXGRU:oPeriodo  VAR oACTXGRU:cPeriodo ITEMS aPeriodos;
                SIZE 100,NIL;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oACTXGRU:LEEFECHAS()
  ComboIni(oACTXGRU:oPeriodo )

  @ 10, nLin+103 BUTTON oACTXGRU:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oACTXGRU:oPeriodo:nAt,oACTXGRU:oDesde,oACTXGRU:oHasta,-1),;
                         EVAL(oACTXGRU:oBtn:bAction))



  @ 10, nLin+130 BUTTON oACTXGRU:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oACTXGRU:oPeriodo:nAt,oACTXGRU:oDesde,oACTXGRU:oHasta,+1),;
                         EVAL(oACTXGRU:oBtn:bAction))


  @ 10, nLin+170 BMPGET oACTXGRU:oDesde  VAR oACTXGRU:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oACTXGRU:oDesde ,oACTXGRU:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oACTXGRU:oPeriodo:nAt=LEN(oACTXGRU:oPeriodo:aItems);
                FONT oFont

   oACTXGRU:oDesde:cToolTip:="F6: Calendario"

  @ 10, nLin+252 BMPGET oACTXGRU:oHasta  VAR oACTXGRU:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oACTXGRU:oHasta,oACTXGRU:dHasta);
                SIZE 80,23;
                WHEN oACTXGRU:oPeriodo:nAt=LEN(oACTXGRU:oPeriodo:aItems);
                OF oBar;
                FONT oFont

   oACTXGRU:oHasta:cToolTip:="F6: Calendario"

   @ 10, nLin+335 BUTTON oACTXGRU:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oACTXGRU:oPeriodo:nAt=LEN(oACTXGRU:oPeriodo:aItems);
               ACTION oACTXGRU:HACERWHERE(oACTXGRU:dDesde,oACTXGRU:dHasta,oACTXGRU:cWhere,.T.)




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

  oRep:=REPORTE("BRACTXGRU",cWhere)
  oRep:cSql  :=oACTXGRU:cSql
  oRep:cTitle:=oACTXGRU:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oACTXGRU:oPeriodo:nAt,cWhere

  oACTXGRU:nPeriodo:=nPeriodo

  IF oACTXGRU:oPeriodo:nAt=LEN(oACTXGRU:oPeriodo:aItems)

     oACTXGRU:oDesde:ForWhen(.T.)
     oACTXGRU:oHasta:ForWhen(.T.)
     oACTXGRU:oBtn  :ForWhen(.T.)

     DPFOCUS(oACTXGRU:oDesde)

  ELSE

     oACTXGRU:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oACTXGRU:oDesde:VarPut(oACTXGRU:aFechas[1] , .T. )
     oACTXGRU:oHasta:VarPut(oACTXGRU:aFechas[2] , .T. )

     oACTXGRU:dDesde:=oACTXGRU:aFechas[1]
     oACTXGRU:dHasta:=oACTXGRU:aFechas[2]

     cWhere:=oACTXGRU:HACERWHERE(oACTXGRU:dDesde,oACTXGRU:dHasta,oACTXGRU:cWhere,.T.)

     oACTXGRU:LEERDATA(cWhere,oACTXGRU:oBrw,oACTXGRU:cServer)

  ENDIF

  oACTXGRU:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('DPACTIVOS.ATV_FCHADQ',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('DPACTIVOS.ATV_FCHADQ',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oACTXGRU:cWhereQry)
       cWhere:=cWhere + oACTXGRU:cWhereQry
     ENDIF

     oACTXGRU:LEERDATA(cWhere,oACTXGRU:oBrw,oACTXGRU:cServer)

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


   cSql:=" SELECT ATV_CODIGO, "+;
          "  ATV_DESCRI, "+;
          "  ATV_DEPRE, "+;
          "  ATV_CODUBI, "+;
          "  ATV_FCHADQ, "+;
          "  ATV_FCHMAX, "+;
          "  ATV_COSADQ, "+;
          "  SUM(IF(DEP_TIPTRA='D',DEP_MONTO,0)) AS DEP_MONTO, "+;
          "  SUM(DEP_MTOFIS) AS DEP_MTOFIS, "+;
          "  SUM(DEP_MTOFIN) AS DEP_MTOFIN "+;
          "  FROM DPACTIVOS "+;
          "  LEFT JOIN DPDEPRECIAACT ON ATV_CODSUC=DEP_CODSUC AND ATV_CODIGO=DEP_CODACT "+;
          IF(Empty(cWhere),"","  WHERE "+cWhere)+;
          "  GROUP BY ATV_CODIGO,ATV_DESCRI"+;
          ""

   aData:=ASQL(cSql,oDb)

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql)
//    AADD(aData,{'','','','',CTOD(""),CTOD(""),0,0,0,0})
   ENDIF

   IF ValType(oBrw)="O"

      oACTXGRU:cSql   :=cSql
      oACTXGRU:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oACTXGRU:oBrw:aCols[7]
         oCol:cFooter      :=FDP(aTotal[7],'999,999,999.99')
      oCol:=oACTXGRU:oBrw:aCols[8]
         oCol:cFooter      :=FDP(aTotal[8],'999,999,999.99')
      oCol:=oACTXGRU:oBrw:aCols[9]
         oCol:cFooter      :=FDP(aTotal[9],'999,999,999.99')
      oCol:=oACTXGRU:oBrw:aCols[10]
         oCol:cFooter      :=FDP(aTotal[10],'999,999,999.99')

      oACTXGRU:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oACTXGRU:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oACTXGRU:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRACTXGRU.MEM",V_nPeriodo:=oACTXGRU:nPeriodo
  LOCAL V_dDesde:=oACTXGRU:dDesde
  LOCAL V_dHasta:=oACTXGRU:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oACTXGRU)
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

    IF Type("oACTXGRU")="O" .AND. oACTXGRU:oWnd:hWnd>0

      oACTXGRU:LEERDATA(oACTXGRU:cWhere_,oACTXGRU:oBrw,oACTXGRU:cServer)
      oACTXGRU:oWnd:Show()
      oACTXGRU:oWnd:Maximize()

    ENDIF

RETURN NIL

/*
// Genera Correspondencia Masiva
*/

FUNCTION ACTIVOMOD(nOption)
   LOCAL cCodigo:=oACTXGRU:oBrw:aArrayData[oACTXGRU:oBrw:nArrayAt,1]

   EJECUTAR("DPACTIVOS",nOption,cCodigo)
 
RETURN  NIL




 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oACTXGRU)
// EOF