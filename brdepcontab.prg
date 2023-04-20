// Programa   : BRDEPCONTAB
// Fecha/Hora : 03/11/2014 16:54:51
// Propósito  : "Contabilizar Activos"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cCodigo,cWhere,lRun,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRACTCONTAB.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   DEFAULT cCodSuc:=oDp:cSucursal,;
           cCodigo:=SQLGET("DPDEPRECIAACT","DEP_CODACT","DEP_CODSUC"+GetWhere("=",cCodSuc)),;
           lRun   :=.T.

   oDp:cRunServer:=NIL

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SDB_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 

   DEFAULT oDp:lCbteNumEdit:=.T.

   cTitle:="Contabilizar Depreciacion de Activos" +IF(Empty(cTitle),"",cTitle)

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

   cWhere:=IIF(!Empty(cWhere)," AND ","")+"DEP_CODACT"+GetWhere("=",cCodigo)

   aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)


   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle)

   oDp:oFrm:=oACTCONTAB
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)


   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DPEDIT():New(cTitle,"BRACTCONTAB.EDT","oACTCONTAB",.F.)

   oACTCONTAB:CreateWindow(NIL,NIL,NIL,550,726+58)

   oACTCONTAB:cCodSuc  :=cCodSuc
   oACTCONTAB:cCodigo  :=cCodigo
   oACTCONTAB:lRun     :=lRun
   oACTCONTAB:lMsgBar  :=.F.
   oACTCONTAB:cPeriodo :=aPeriodos[nPeriodo]
   oACTCONTAB:cCodSuc  :=cCodSuc
   oACTCONTAB:nPeriodo :=nPeriodo
   oACTCONTAB:cNombre  :=SQLGET("DPACTIVOS","ATV_DESCRI","ATV_CODIGO"+GetWhere("=",cCodigo))
   oACTCONTAB:dDesde   :=dDesde
   oACTCONTAB:cServer  :=cServer
   oACTCONTAB:dHasta   :=dHasta
   oACTCONTAB:cWhere   :=cWhere
   oACTCONTAB:cWhereQry:=""
   oACTCONTAB:cSql     :=oDp:cSql
   oACTCONTAB:cWhere_  :=cWhere
   oACTCONTAB:cCodPar  :=cCodPar // Código del Parámetro
   oACTCONTAB:cNumero  :=EJECUTAR("DPNUMCBTE","ACTFIJ") // Número del Activo

   @ 09,2 SAY "Número Cbte: "
   @ 10,2 GET oACTCONTAB:oNumero VAR oACTCONTAB:cNumero VALID EJECUTAR("CBTVALNUM",oACTCONTAB:oNumero);
              PICTURE oDp:cCbtePicture;
              WHEN oDp:lCbteNumEdit

   oACTCONTAB:oBrw:=TXBrowse():New( oACTCONTAB:oDlg )
   oACTCONTAB:oBrw:SetArray( aData, .F. )
   oACTCONTAB:oBrw:SetFont(oFont)

   oACTCONTAB:oBrw:lFooter     := .T.
   oACTCONTAB:oBrw:lHScroll    := .F.
   oACTCONTAB:oBrw:nHeaderLines:= 2
   oACTCONTAB:oBrw:nDataLines  := 1
   oACTCONTAB:oBrw:nFooterLines:= 1

   oACTCONTAB:aData            :=ACLONE(aData)

   AEVAL(oACTCONTAB:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oACTCONTAB:oBrw:aCols[1]
   oCol:cHeader      :='Fecha Desde'
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTCONTAB:oBrw:aArrayData ) } 
   oCol:nWidth       := 70

   oCol:=oACTCONTAB:oBrw:aCols[2]
   oCol:cHeader      :='Fecha'+CRLF+"Hasta"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTCONTAB:oBrw:aArrayData ) } 
   oCol:nWidth       := 70

   oCol:=oACTCONTAB:oBrw:aCols[3]
   oCol:cHeader      :='Monto'+CRLF+"Depreciación"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTCONTAB:oBrw:aArrayData ) } 
   oCol:nWidth       := 128
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bStrData:={|nMonto|nMonto:= oACTCONTAB:oBrw:aArrayData[oACTCONTAB:oBrw:nArrayAt,3],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[3],'999,999,999.99')


   oCol:=oACTCONTAB:oBrw:aCols[4]
   oCol:cHeader      :="Ajuste"+CRLF+"Fiscal"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTCONTAB:oBrw:aArrayData ) } 
   oCol:nWidth       := 112
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bStrData:={|nMonto|nMonto:= oACTCONTAB:oBrw:aArrayData[oACTCONTAB:oBrw:nArrayAt,4],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[4],'999,999,999.99')


   oCol:=oACTCONTAB:oBrw:aCols[5]
   oCol:cHeader      :="Ajuste"+CRLF+"Financiero"
   oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTCONTAB:oBrw:aArrayData ) } 
   oCol:nWidth       := 112
   oCol:nDataStrAlign:= AL_RIGHT 
   oCol:nHeadStrAlign:= AL_RIGHT 
   oCol:nFootStrAlign:= AL_RIGHT 
   oCol:bStrData:={|nMonto|nMonto:= oACTCONTAB:oBrw:aArrayData[oACTCONTAB:oBrw:nArrayAt,5],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[5],'999,999,999.99')


  oCol:=oACTCONTAB:oBrw:aCols[6]
  oCol:cHeader      :="Cbte."+CRLF+"Contable"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTCONTAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 64

  oCol:=oACTCONTAB:oBrw:aCols[7]
  oCol:cHeader      :="Fecha"+CRLF+"Contab."
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTCONTAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oACTCONTAB:oBrw:aCols[8]
  oCol:cHeader      :="Num."+CRLF+"Partd"
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTCONTAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 45

  oCol:=oACTCONTAB:oBrw:aCols[9]
  oCol:cHeader      :="Cbte"+CRLF+"Actz."
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTCONTAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 45

  oCol:=oACTCONTAB:oBrw:aCols[10]
  oCol:cHeader      :='Estado'+CRLF+"Deprec."
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTCONTAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 60

  oCol:=oACTCONTAB:oBrw:aCols[11]
  oCol:cHeader      :='Num.'+CRLF+'Reg.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTCONTAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  oCol:=oACTCONTAB:oBrw:aCols[12]
  oCol:cHeader      :='Num.'+CRLF+'Ejerc.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTCONTAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  oCol:=oACTCONTAB:oBrw:aCols[13]
  oCol:cHeader      :='Contabilizar'
  oCol:nWidth       := 75
  oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
  oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")
  oCol:bBmpData     := { |oBrw|oBrw:=oACTCONTAB:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,13],1,2) }
  oCol:bStrData     :={||""}
  oCol:bLClickHeader:={||oACTCONTAB:SELALL()}

  oACTCONTAB:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

  oACTCONTAB:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oACTCONTAB:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                            nClrText:=0,;
                                            nClrText:=IF(Empty(oBrw:aArrayData[oBrw:nArrayAt,6]),nClrText,CLR_GREEN),;       
                                            nClrText:=IF(!oBrw:aArrayData[oBrw:nArrayAt,13],nClrText,CLR_HBLUE),;
                                           {nClrText,iif( oBrw:nArrayAt%2=0, 15532012, 15466455 ) } }

  oACTCONTAB:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oACTCONTAB:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oACTCONTAB:oBrw:bLDblClick:={|oBrw|oACTCONTAB:oRep:=oACTCONTAB:RUNCLICK() }

  oACTCONTAB:oBrw:bChange:={||oACTCONTAB:BRWCHANGE()}
  oACTCONTAB:oBrw:CreateFromCode()

  oACTCONTAB:Activate({||oACTCONTAB:ViewDatBar()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oACTCONTAB:oDlg
   LOCAL nLin:=0

   oACTCONTAB:oBrw:GoBottom(.T.)
   oACTCONTAB:oBrw:Refresh(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD

   IF oACTCONTAB:lRun

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\RUN.BMP";
            ACTION oACTCONTAB:RUNCONTAB()

     oBtn:cToolTip:="Ejecutar Proceso de Contabilización"

   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\VIEW.BMP";
          ACTION EJECUTAR("DPACTIVOCON",NIL,oACTCONTAB:cCodigo)

   oBtn:cToolTip:="Consultar Activo"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XDELETE.BMP";
          ACTION oACTCONTAB:DELETECONTAB()

   oBtn:cToolTip:="Remover Asiento de Contabilización"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oACTCONTAB:oBrw)

   oBtn:cToolTip:="Buscar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oACTCONTAB)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oACTCONTAB:oBrw,oACTCONTAB:cTitle,oACTCONTAB:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   oACTCONTAB:oBtnXls:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oACTCONTAB:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oACTCONTAB:oBtnHtml:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oACTCONTAB:oBrw))

   oBtn:cToolTip:="Previsualización"

   oACTCONTAB:oBtnPreview:=oBtn

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRACTCONTAB")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oACTCONTAB:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oACTCONTAB:oBtnPrint:=oBtn

   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oACTCONTAB:BRWQUERY()

   oBtn:cToolTip:="Imprimir"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oACTCONTAB:oBrw:GoTop(),oACTCONTAB:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oACTCONTAB:oBrw:PageDown(),oACTCONTAB:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oACTCONTAB:oBrw:PageUp(),oACTCONTAB:oBrw:Setfocus())


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oACTCONTAB:oBrw:GoBottom(),oACTCONTAB:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oACTCONTAB:Close()

  oACTCONTAB:oBrw:SetColor(0,15532012)

  EVAL(oACTCONTAB:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oACTCONTAB:oBar:=oBar

  @ .1,90 SAY " Activo: "+ALLTRIM(oACTCONTAB:cCodigo)+" "+oACTCONTAB:cNombre BORDER OF oBar SIZE 380,20

RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()
  LOCAL lOk:=oACTCONTAB:oBrw:aArrayData[oACTCONTAB:oBrw:nArrayAt,13]

  IF oACTCONTAB:oBrw:aArrayData[oACTCONTAB:oBrw:nArrayAt,10]="S"
     MensajeErr("Comprobante Contable está Actualizado")
     RETURN .F.
  ENDIF


  oACTCONTAB:oBrw:aArrayData[oACTCONTAB:oBrw:nArrayAt,13]:=!lOk
  oACTCONTAB:oBrw:DrawLine(.T.)

RETURN .T.

/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRACTCONTAB",cWhere)
  oRep:cSql  :=oACTCONTAB:cSql
  oRep:cTitle:=oACTCONTAB:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oACTCONTAB:oPeriodo:nAt,cWhere

  oACTCONTAB:nPeriodo:=nPeriodo

  IF oACTCONTAB:oPeriodo:nAt=LEN(oACTCONTAB:oPeriodo:aItems)

     oACTCONTAB:oDesde:ForWhen(.T.)
     oACTCONTAB:oHasta:ForWhen(.T.)
     oACTCONTAB:oBtn  :ForWhen(.T.)

     DPFOCUS(oACTCONTAB:oDesde)

  ELSE

     oACTCONTAB:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oACTCONTAB:oDesde:VarPut(oACTCONTAB:aFechas[1] , .T. )
     oACTCONTAB:oHasta:VarPut(oACTCONTAB:aFechas[2] , .T. )

     oACTCONTAB:dDesde:=oACTCONTAB:aFechas[1]
     oACTCONTAB:dHasta:=oACTCONTAB:aFechas[2]

     cWhere:=oACTCONTAB:HACERWHERE(oACTCONTAB:dDesde,oACTCONTAB:dHasta,oACTCONTAB:cWhere,.T.)

     oACTCONTAB:LEERDATA(cWhere,oACTCONTAB:oBrw,oACTCONTAB:cServer)

  ENDIF

  oACTCONTAB:SAVEPERIODO()

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

     IF !Empty(oACTCONTAB:cWhereQry)
       cWhere:=cWhere + oACTCONTAB:cWhereQry
     ENDIF

     oACTCONTAB:LEERDATA(cWhere,oACTCONTAB:oBrw,oACTCONTAB:cServer)

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

   cSql:=" SELECT DEP_DESDE,DEP_FECHA,DEP_MONTO,DEP_MTOFIS,DEP_MTOFIN,ADA_NUMCBT,DEP_FCHCON,DEP_NUMPAR,ADA_ACTUAL,DEP_ESTADO,DEP_NUMERO,DEP_NUMEJE,0 LOGICO "+;
         " FROM DPDEPRECIAACT "+;
         " LEFT JOIN VIEW_ASIENTOSDEPHIS ON DEP_CODSUC=ADA_CODSUC AND DEP_FECHA=ADA_FECHA AND DEP_COMPRO=ADA_NUMCBT AND DEP_NUMPAR=ADA_NUMPAR "+;
         " WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" DEP_TIPTRA='D' ORDER BY DEP_FECHA"

   aData:=ASQL(cSql)

   AEVAL(aData,{|a,n| aData[n,10]:=SAYOPTIONS("DPDEPRECIAACT","DEP_ESTADO",a[10]) })

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql)
   ENDIF

   AEVAL(aData,{|a,n| aData[n,13]:=Empty(a[6]) .and. oDp:cNumEje=a[12]})


   IF ValType(oBrw)="O"

      oACTCONTAB:cSql   :=cSql
      oACTCONTAB:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1
      
      oCol:=oACTCONTAB:oBrw:aCols[3]
      oCol:cFooter      :=FDP(aTotal[3],'999,999,999.99')
      oCol:=oACTCONTAB:oBrw:aCols[4]
      oCol:cFooter      :=FDP(aTotal[4],'999,999,999.99')
      oCol:=oACTCONTAB:oBrw:aCols[5]
      oCol:cFooter      :=FDP(aTotal[5],'999,999,999.99')

      oACTCONTAB:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oACTCONTAB:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oACTCONTAB:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRACTCONTAB.MEM",V_nPeriodo:=oACTCONTAB:nPeriodo
  LOCAL V_dDesde:=oACTCONTAB:dDesde
  LOCAL V_dHasta:=oACTCONTAB:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oACTCONTAB)

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

    IF Type("oACTCONTAB")="O" .AND. oACTCONTAB:oWnd:hWnd>0
      oACTCONTAB:cWhere_:=IIF(Empty(oACTCONTAB:cWhere_),oACTCONTAB:cWhere,oACTCONTAB:cWhere_)
      oACTCONTAB:LEERDATA(oACTCONTAB:cWhere_,oACTCONTAB:oBrw,oACTCONTAB:cServer)
      oACTCONTAB:oWnd:Show()
      oACTCONTAB:oWnd:Maximize()

    ENDIF

RETURN NIL

FUNCTION RUNCONTAB()
   LOCAL aLines:={},I,cNumDep:="",cNumCom:=STRZERO(1,8)

   AEVAL(oACTCONTAB:oBrw:aArrayData,{|a,n| IF(a[13],AADD(aLines,a[11]),NIL)})

   IF Empty(aLines)
      MensajeErr("No hay Depreciaciones seleccionadas para Contabilizar")
      RETURN .T.
   ENDIF

   IF !MsgYesNo("Desea contabilizar "+LSTR(LEN(aLines))+" Registro(s) ")
      RETURN .T.
   ENDIF

   CursorWait()
   EJECUTAR("DPCONTABDEPREC",oACTCONTAB:cCodSuc,oACTCONTAB:cCodigo,aLines,cNumCom)

   oACTCONTAB:BRWREFRESCAR()

RETURN .T.

/*
// Remover Asientos Contables
*/

FUNCTION DELETECONTAB()
   LOCAL aLine :=oACTCONTAB:oBrw:aArrayData[oACTCONTAB:oBrw:nArrayAt]
   LOCAL cWhere:="MOC_CODSUC"+getWhere("=",oDp:cSucursal)+" AND "+;
                 "MOC_NUMCBT"+GetWhere("=",aLine[6])+" AND "+;
                 "MOC_FECHA" +GetWhere("=",aLine[2])+" AND "+;
                 "MOC_NUMPAR"+GetWhere("=",aLine[8])

   LOCAL aData :={}
   LOCAL cTitle:="Desea Eliminar Registro de Depreciación "+aLine[11]
   LOCAL cWhere

   AEVAL(oACTCONTAB:oBrw:aCols,{|oCol,n| AADD(aData,{STRTRAN(oCol:cHeader,CRLF,"/"),aLine[n]}) })

   IF EJECUTAR("MSGBROWSE",aData,cTitle,{150,400})
     SQLDELETE("DPASIENTOS",cWhere)
     oACTCONTAB:BRWREFRESCAR()
   ENDIF

RETURN NIL

/*
// Marcar Todos, no incluye los Contabilizados
*/
FUNCTION SELALL()
  LOCAL lAll:=ATAIL(oACTCONTAB:oBrw:aArrayData)[13]

  AEVAL(oACTCONTAB:oBrw:aArrayData,{|a,n| oACTCONTAB:oBrw:aArrayData[n,13]:=!lAll .AND. Empty(a[6]) })
  oACTCONTAB:oBrw:Refresh(.T.)

RETURN .T.

// EOF
