// Programa   : BRACTXDEP
// Fecha/Hora : 31/01/2015 09:55:53
// Propósito  : "Activos sin Depreciación"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRACTXDEP.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   DEFAULT cCodSuc:=oDp:cSucursal,;
           cWhere :="ATV_CODSUC"+GetWhere("=",cCodSuc)

   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SDB_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 


   cTitle:="Activos sin Depreciación" +IF(Empty(cTitle),"",cTitle)

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

   IF .F. .OR. (!nPeriodo=10 .OR. (Empty(dDesde) .OR. Empty(dhasta)))

       aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
       dDesde :=aFechas[1]
       dHasta :=aFechas[2]

   ENDIF

   IF .T.

      IF nPeriodo=10
        dDesde :=V_dDesde
        dHasta :=V_dHasta
      ELSE
        aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
        dDesde :=aFechas[1]
        dHasta :=aFechas[2]
      ENDIF

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)


   ELSEIF (.F.)

     aData :=LEERDATA(HACERWHERE(dDesde,dHasta,cWhere),NIL,cServer)

   ENDIF

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle)

   oDp:oFrm:=oACTXDEP
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)


   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DPEDIT():New(cTitle,"BRACTXDEP.EDT","oACTXDEP",.F.)

   oACTXDEP:CreateWindow(NIL,NIL,NIL,550,718+58)

   oACTXDEP:cCodSuc  :=cCodSuc
   oACTXDEP:lMsgBar  :=.F.
   oACTXDEP:cPeriodo :=aPeriodos[nPeriodo]
   oACTXDEP:cCodSuc  :=cCodSuc
   oACTXDEP:nPeriodo :=nPeriodo
   oACTXDEP:cNombre  :=""
   oACTXDEP:dDesde   :=dDesde
   oACTXDEP:cServer  :=cServer
   oACTXDEP:dHasta   :=dHasta
   oACTXDEP:cWhere   :=cWhere
   oACTXDEP:cWhere_  :=""
   oACTXDEP:cWhereQry:=""
   oACTXDEP:cSql     :=oDp:cSql
   oACTXDEP:oWhere   :=TWHERE():New(oACTXDEP)
   oACTXDEP:cCodPar  :=cCodPar // Código del Parámetro


   oACTXDEP:oBrw:=TXBrowse():New( oACTXDEP:oDlg )
   oACTXDEP:oBrw:SetArray( aData, .T. )
   oACTXDEP:oBrw:SetFont(oFont)

   oACTXDEP:oBrw:lFooter     := .T.
   oACTXDEP:oBrw:lHScroll    := .F.
   oACTXDEP:oBrw:nHeaderLines:= 2
   oACTXDEP:oBrw:nDataLines  := 1
   oACTXDEP:oBrw:nFooterLines:= 1

   oACTXDEP:aData            :=ACLONE(aData)

   AEVAL(oACTXDEP:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  oCol:=oACTXDEP:oBrw:aCols[1]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXDEP:oBrw:aArrayData ) } 
  oCol:nWidth       := 120

  oCol:=oACTXDEP:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXDEP:oBrw:aArrayData ) } 
  oCol:nWidth       := 500

  oCol:=oACTXDEP:oBrw:aCols[3]
  oCol:cHeader      :='Fecha'+CRLF+'Adquisión'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXDEP:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oACTXDEP:oBrw:aCols[4]
  oCol:cHeader      :='Costo'+CRLF+'Adquisición'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXDEP:oBrw:aArrayData ) } 
  oCol:nWidth       := 128
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oACTXDEP:oBrw:aArrayData[oACTXDEP:oBrw:nArrayAt,4],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[4],'999,999,999.99')


   oACTXDEP:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oACTXDEP:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oACTXDEP:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 16318448, 14680053 ) } }

   oACTXDEP:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oACTXDEP:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oACTXDEP:oBrw:bLDblClick:={|oBrw|oACTXDEP:oRep:=oACTXDEP:RUNCLICK() }

   oACTXDEP:oBrw:bChange:={||oACTXDEP:BRWCHANGE()}
   oACTXDEP:oBrw:CreateFromCode()

   oACTXDEP:Activate({||oACTXDEP:ViewDatBar(oACTXDEP)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oACTXDEP)
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oACTXDEP:oDlg
   LOCAL nLin:=0

   oACTXDEP:oBrw:GoBottom(.T.)
   oACTXDEP:oBrw:Refresh(.T.)

//   IF !File("FORMS\BRACTXDEP.EDT")
//     oACTXDEP:oBrw:Move(44,0,718+50,460)
//   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          ACTION oACTXDEP:RUN_DEPRECIA()

   oBtn:cToolTip:="Calcular Depreciación "

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\ACTIVOS.BMP";
          ACTION oACTXDEP:EDITAR_ACTIVO()

   oBtn:cToolTip:="Editar Activo"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oACTXDEP:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oACTXDEP:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oACTXDEP:oBrw);
          WHEN LEN(oACTXDEP:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oACTXDEP:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oACTXDEP)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oACTXDEP:oBrw,oACTXDEP:cTitle,oACTXDEP:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   oACTXDEP:oBtnXls:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oACTXDEP:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oACTXDEP:oBtnHtml:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oACTXDEP:oBrw))

   oBtn:cToolTip:="Previsualización"

   oACTXDEP:oBtnPreview:=oBtn

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRACTXDEP")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oACTXDEP:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oACTXDEP:oBtnPrint:=oBtn

   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oACTXDEP:BRWQUERY()

   oBtn:cToolTip:="Imprimir"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oACTXDEP:oBrw:GoTop(),oACTXDEP:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oACTXDEP:oBrw:PageDown(),oACTXDEP:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oACTXDEP:oBrw:PageUp(),oACTXDEP:oBrw:Setfocus())


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oACTXDEP:oBrw:GoBottom(),oACTXDEP:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oACTXDEP:Close()

  oACTXDEP:oBrw:SetColor(0,16318448)

  EVAL(oACTXDEP:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oACTXDEP:oBar:=oBar

    //
  // Campo : Fecha
  //


  nLin:=608+70

  @ 10, nLin GET oACTXDEP:oHasta  VAR oACTXDEP:dHasta;
               SIZE 100,20;
               COLOR CLR_BLACK,CLR_WHITE;
               VALID !Empty(oACTXDEP:dHasta);
               OF oBar;
               SPINNER;
               ON CHANGE EVAL(oACTXDEP:oHasta:bValid);
               FONT oFont PIXEL

   oACTXDEP:oHasta:bKeyDown:={|nKey| IF( nKey=117 , LbxDate(oACTXDEP:oHasta ,oACTXDEP:dHasta) , NIL )}


  @ oACTXDEP:oHasta:nTop,nLin-56 SAY "Hasta:" OF oBar BORDER SIZE 54,20 PIXEL

  @ oACTXDEP:oHasta:nTop,nLin+123 BUTTON oACTXDEP:oBtn PROMPT " > " SIZE 27,20;
              FONT oFont;
              PIXEL;
              OF oBar;
              ACTION oACTXDEP:HACERWHERE(oACTXDEP:dDesde,oACTXDEP:dHasta,oACTXDEP:cWhere,.T.)




RETURN .T.

/*
// Evento para presionar CLICK
*/
FUNCTION RUNCLICK()

  oACTXDEP:EDITAR_ACTIVO()

RETURN .T.

/*
// Imprimir
*/
FUNCTION IMPRIMIR()
  LOCAL oRep,cWhere

  oRep:=REPORTE("BRACTXDEP",cWhere)
  oRep:cSql  :=oACTXDEP:cSql
  oRep:cTitle:=oACTXDEP:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oACTXDEP:oPeriodo:nAt,cWhere

  oACTXDEP:nPeriodo:=nPeriodo

  IF oACTXDEP:oPeriodo:nAt=LEN(oACTXDEP:oPeriodo:aItems)

     oACTXDEP:oDesde:ForWhen(.T.)
     oACTXDEP:oHasta:ForWhen(.T.)
     oACTXDEP:oBtn  :ForWhen(.T.)

     DPFOCUS(oACTXDEP:oDesde)

  ELSE

     oACTXDEP:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oACTXDEP:oDesde:VarPut(oACTXDEP:aFechas[1] , .T. )
     oACTXDEP:oHasta:VarPut(oACTXDEP:aFechas[2] , .T. )

     oACTXDEP:dDesde:=oACTXDEP:aFechas[1]
     oACTXDEP:dHasta:=oACTXDEP:aFechas[2]

     cWhere:=oACTXDEP:HACERWHERE(oACTXDEP:dDesde,oACTXDEP:dHasta,oACTXDEP:cWhere,.T.)

     oACTXDEP:LEERDATA(cWhere,oACTXDEP:oBrw,oACTXDEP:cServer)

  ENDIF

  oACTXDEP:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   IF !Empty(dDesde)
       cWhere:= "DPACTIVOS.ATV_FCHADQ"+GetWhere("<=",dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:= "DPACTIVOS.ATV_FCHADQ"+GetWhere("<=",dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oACTXDEP:cWhereQry)
       cWhere:=cWhere + oACTXDEP:cWhereQry
     ENDIF

     oACTXDEP:LEERDATA(cWhere,oACTXDEP:oBrw,oACTXDEP:cServer)

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


   cSql:=" SELECT ATV_CODIGO,ATV_DESCRI,ATV_FCHADQ,ATV_COSADQ"+;
          " FROM DPACTIVOS"+;
          " LEFT JOIN DPDEPRECIAACT ON DEP_CODACT=ATV_CODIGO"+;
          " WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" ATV_ESTADO='A'   AND ATV_DEPRE ='D'    AND DEP_CODACT IS NULL"+;
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
//    AADD(aData,{'','',CTOD(""),0})
   ENDIF

   IF ValType(oBrw)="O"

      oACTXDEP:cSql   :=cSql
      oACTXDEP:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oACTXDEP:oBrw:aCols[4]
         oCol:cFooter      :=FDP(aTotal[4],'999,999,999.99')

      oACTXDEP:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oACTXDEP:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oACTXDEP:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRACTXDEP.MEM",V_nPeriodo:=oACTXDEP:nPeriodo
  LOCAL V_dDesde:=oACTXDEP:dDesde
  LOCAL V_dHasta:=oACTXDEP:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oACTXDEP)
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

    IF Type("oACTXDEP")="O" .AND. oACTXDEP:oWnd:hWnd>0

      oACTXDEP:LEERDATA(oACTXDEP:cWhere,oACTXDEP:oBrw,oACTXDEP:cServer)
      oACTXDEP:oWnd:Show()
      oACTXDEP:oWnd:Maximize()

    ENDIF

RETURN NIL

FUNCTION EDITAR_ACTIVO()
  LOCAL cCodigo :=oACTXDEP:oBrw:aArrayData[oACTXDEP:oBrw:nArrayAt,1]

  EJECUTAR("DPACTIVOS",3,cCodigo)


RETURN NIL

FUNCTION RUN_DEPRECIA()
  LOCAL cCodigo :=oACTXDEP:oBrw:aArrayData[oACTXDEP:oBrw:nArrayAt,1]

  MsgRun("Recalculando Depreciación","Por Favor Espere...",{||EJECUTAR("DPDEPRECCALC",oDp:cSucMain,cCodigo,.T.)})

  oACTXDEP:BRWREFRESCAR()

RETURN NIL

// EOF
