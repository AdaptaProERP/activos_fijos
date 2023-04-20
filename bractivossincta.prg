// Programa   : BRACTIVOSSINCTA
// Fecha/Hora : 11/03/2017 04:23:08
// Propósito  : "Activos sin Cuenta Contables"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRACTIVOSSINCTA.MEM",V_nPeriodo:=4,cCodPar
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


   cTitle:="Activos sin Cuenta Contables" +IF(Empty(cTitle),"",cTitle)

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

   IF .T. .AND. (!nPeriodo=10 .AND. (Empty(dDesde) .OR. Empty(dhasta)))

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

   oDp:oFrm:=oACTIVOSSINCTA
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

//   DPEDIT():New(cTitle,"BRACTIVOSSINCTA.EDT","oACTIVOSSINCTA",.F.)

   DpMdi(cTitle,"oACTIVOSSINCTA","BRACTIVOSSINCTA.EDT")

   oACTIVOSSINCTA:Windows(0,0,aCoors[3]-160,MIN(1130,aCoors[4]-10),.T.) // Maximizado

//   oACTIVOSSINCTA:CreateWindow(NIL,NIL,NIL,550,850+58)




   oACTIVOSSINCTA:cCodSuc  :=cCodSuc
   oACTIVOSSINCTA:lMsgBar  :=.F.
   oACTIVOSSINCTA:cPeriodo :=aPeriodos[nPeriodo]
   oACTIVOSSINCTA:cCodSuc  :=cCodSuc
   oACTIVOSSINCTA:nPeriodo :=nPeriodo
   oACTIVOSSINCTA:cNombre  :=""
   oACTIVOSSINCTA:dDesde   :=dDesde
   oACTIVOSSINCTA:cServer  :=cServer
   oACTIVOSSINCTA:dHasta   :=dHasta
   oACTIVOSSINCTA:cWhere   :=cWhere
   oACTIVOSSINCTA:cWhere_  :=cWhere_
   oACTIVOSSINCTA:cWhereQry:=""
   oACTIVOSSINCTA:cSql     :=oDp:cSql
   oACTIVOSSINCTA:oWhere   :=TWHERE():New(oACTIVOSSINCTA)
   oACTIVOSSINCTA:cCodPar  :=cCodPar // Código del Parámetro
   oACTIVOSSINCTA:lWhen    :=.T.
   oACTIVOSSINCTA:cTextTit :="" // Texto del Titulo Heredado
    oACTIVOSSINCTA:oDb     :=oDp:oDb
   oACTIVOSSINCTA:cBrwCod  :="ACTIVOSSINCTA"
   oACTIVOSSINCTA:lTmdi    :=.F.



   oACTIVOSSINCTA:oBrw:=TXBrowse():New( IF(oACTIVOSSINCTA:lTmdi,oACTIVOSSINCTA:oWnd,oACTIVOSSINCTA:oDlg ))
   oACTIVOSSINCTA:oBrw:SetArray( aData, .F. )
   oACTIVOSSINCTA:oBrw:SetFont(oFont)

   oACTIVOSSINCTA:oBrw:lFooter     := .T.
   oACTIVOSSINCTA:oBrw:lHScroll    := .F.
   oACTIVOSSINCTA:oBrw:nHeaderLines:= 2
   oACTIVOSSINCTA:oBrw:nDataLines  := 1
   oACTIVOSSINCTA:oBrw:nFooterLines:= 1




   oACTIVOSSINCTA:aData            :=ACLONE(aData)
  oACTIVOSSINCTA:nClrText :=0
  oACTIVOSSINCTA:nClrPane1:=16771538
  oACTIVOSSINCTA:nClrPane2:=16765606

   AEVAL(oACTIVOSSINCTA:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  oCol:=oACTIVOSSINCTA:oBrw:aCols[1]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTIVOSSINCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 120

  oCol:=oACTIVOSSINCTA:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTIVOSSINCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 400

  oCol:=oACTIVOSSINCTA:oBrw:aCols[3]
  oCol:cHeader      :='Fecha'+CRLF+'Adq.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTIVOSSINCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oACTIVOSSINCTA:oBrw:aCols[4]
  oCol:cHeader      :='Costo'+CRLF+'Adquisición'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTIVOSSINCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 128
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oACTIVOSSINCTA:oBrw:aArrayData[oACTIVOSSINCTA:oBrw:nArrayAt,4],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[4],'999,999,999.99')


  oCol:=oACTIVOSSINCTA:oBrw:aCols[5]
  oCol:cHeader      :='Grupo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTIVOSSINCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 64

  oCol:=oACTIVOSSINCTA:oBrw:aCols[6]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTIVOSSINCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 280

   oACTIVOSSINCTA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oACTIVOSSINCTA:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oACTIVOSSINCTA:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oACTIVOSSINCTA:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oACTIVOSSINCTA:nClrPane1, oACTIVOSSINCTA:nClrPane2 ) } }

   oACTIVOSSINCTA:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oACTIVOSSINCTA:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oACTIVOSSINCTA:oBrw:bLDblClick:={|oBrw|oACTIVOSSINCTA:RUNCLICK() }

   oACTIVOSSINCTA:oBrw:bChange:={||oACTIVOSSINCTA:BRWCHANGE()}
   oACTIVOSSINCTA:oBrw:CreateFromCode()
    oACTIVOSSINCTA:bValid   :={|| EJECUTAR("BRWSAVEPAR",oACTIVOSSINCTA)}
    oACTIVOSSINCTA:BRWRESTOREPAR()

   oACTIVOSSINCTA:oWnd:oClient := oACTIVOSSINCTA:oBrw

   oACTIVOSSINCTA:Activate({||oACTIVOSSINCTA:ViewDatBar()})


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oACTIVOSSINCTA:lTmdi,oACTIVOSSINCTA:oWnd,oACTIVOSSINCTA:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oACTIVOSSINCTA:oBrw:nWidth()

   oACTIVOSSINCTA:oBrw:GoBottom(.T.)
   oACTIVOSSINCTA:oBrw:Refresh(.T.)

   IF !File("FORMS\BRACTIVOSSINCTA.EDT")
     oACTIVOSSINCTA:oBrw:Move(44,0,850+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD

 // Emanager no Incluye consulta de Vinculos

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XEDIT.BMP";
          ACTION EJECUTAR("DPACTIVOS",3,oACTIVOSSINCTA:oBrw:aArrayData[oACTIVOSSINCTA:oBrw:nArrayAt,1])

   oBtn:cToolTip:="Modificar Activo"

   IF .F. .AND. Empty(oACTIVOSSINCTA:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oACTIVOSSINCTA:oBrw,oACTIVOSSINCTA:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF

  
/*
   IF Empty(oACTIVOSSINCTA:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","ACTIVOSSINCTA")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","ACTIVOSSINCTA"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oACTIVOSSINCTA:oBrw,"ACTIVOSSINCTA",oACTIVOSSINCTA:cSql,oACTIVOSSINCTA:nPeriodo,oACTIVOSSINCTA:dDesde,oACTIVOSSINCTA:dHasta,oACTIVOSSINCTA)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oACTIVOSSINCTA:oBtnRun:=oBtn



       oACTIVOSSINCTA:oBrw:bLDblClick:={||EVAL(oACTIVOSSINCTA:oBtnRun:bAction) }


   ENDIF



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oACTIVOSSINCTA:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oACTIVOSSINCTA:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oACTIVOSSINCTA:oBrw);
          WHEN LEN(oACTIVOSSINCTA:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"



IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oACTIVOSSINCTA:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oACTIVOSSINCTA)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


IF nWidth>400

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oACTIVOSSINCTA:oBrw,oACTIVOSSINCTA:cTitle,oACTIVOSSINCTA:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oACTIVOSSINCTA:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oACTIVOSSINCTA:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oACTIVOSSINCTA:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oACTIVOSSINCTA:oBrw))

   oBtn:cToolTip:="Previsualización"

   oACTIVOSSINCTA:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRACTIVOSSINCTA")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oACTIVOSSINCTA:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oACTIVOSSINCTA:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oACTIVOSSINCTA:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oACTIVOSSINCTA:oBrw:GoTop(),oACTIVOSSINCTA:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oACTIVOSSINCTA:oBrw:PageDown(),oACTIVOSSINCTA:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oACTIVOSSINCTA:oBrw:PageUp(),oACTIVOSSINCTA:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oACTIVOSSINCTA:oBrw:GoBottom(),oACTIVOSSINCTA:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oACTIVOSSINCTA:Close()

  oACTIVOSSINCTA:oBrw:SetColor(0,15790320)

  EVAL(oACTIVOSSINCTA:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oACTIVOSSINCTA:oBar:=oBar

    nLin:=490

  // Controles se Inician luego del Ultimo Boton
  nLin:=32
  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ 10, nLin COMBOBOX oACTIVOSSINCTA:oPeriodo  VAR oACTIVOSSINCTA:cPeriodo ITEMS aPeriodos;
                SIZE 100,NIL;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oACTIVOSSINCTA:LEEFECHAS();
                WHEN oACTIVOSSINCTA:lWhen 


  ComboIni(oACTIVOSSINCTA:oPeriodo )

  @ 10, nLin+103 BUTTON oACTIVOSSINCTA:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oACTIVOSSINCTA:oPeriodo:nAt,oACTIVOSSINCTA:oDesde,oACTIVOSSINCTA:oHasta,-1),;
                         EVAL(oACTIVOSSINCTA:oBtn:bAction));
                WHEN oACTIVOSSINCTA:lWhen 


  @ 10, nLin+130 BUTTON oACTIVOSSINCTA:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oACTIVOSSINCTA:oPeriodo:nAt,oACTIVOSSINCTA:oDesde,oACTIVOSSINCTA:oHasta,+1),;
                         EVAL(oACTIVOSSINCTA:oBtn:bAction));
                WHEN oACTIVOSSINCTA:lWhen 


  @ 10, nLin+170 BMPGET oACTIVOSSINCTA:oDesde  VAR oACTIVOSSINCTA:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oACTIVOSSINCTA:oDesde ,oACTIVOSSINCTA:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oACTIVOSSINCTA:oPeriodo:nAt=LEN(oACTIVOSSINCTA:oPeriodo:aItems) .AND. oACTIVOSSINCTA:lWhen ;
                FONT oFont

   oACTIVOSSINCTA:oDesde:cToolTip:="F6: Calendario"

  @ 10, nLin+252 BMPGET oACTIVOSSINCTA:oHasta  VAR oACTIVOSSINCTA:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oACTIVOSSINCTA:oHasta,oACTIVOSSINCTA:dHasta);
                SIZE 80,23;
                WHEN oACTIVOSSINCTA:oPeriodo:nAt=LEN(oACTIVOSSINCTA:oPeriodo:aItems) .AND. oACTIVOSSINCTA:lWhen ;
                OF oBar;
                FONT oFont

   oACTIVOSSINCTA:oHasta:cToolTip:="F6: Calendario"

   @ 10, nLin+335 BUTTON oACTIVOSSINCTA:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oACTIVOSSINCTA:oPeriodo:nAt=LEN(oACTIVOSSINCTA:oPeriodo:aItems);
               ACTION oACTIVOSSINCTA:HACERWHERE(oACTIVOSSINCTA:dDesde,oACTIVOSSINCTA:dHasta,oACTIVOSSINCTA:cWhere,.T.);
               WHEN oACTIVOSSINCTA:lWhen

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})




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

  oRep:=REPORTE("BRACTIVOSSINCTA",cWhere)
  oRep:cSql  :=oACTIVOSSINCTA:cSql
  oRep:cTitle:=oACTIVOSSINCTA:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oACTIVOSSINCTA:oPeriodo:nAt,cWhere

  oACTIVOSSINCTA:nPeriodo:=nPeriodo


  IF oACTIVOSSINCTA:oPeriodo:nAt=LEN(oACTIVOSSINCTA:oPeriodo:aItems)

     oACTIVOSSINCTA:oDesde:ForWhen(.T.)
     oACTIVOSSINCTA:oHasta:ForWhen(.T.)
     oACTIVOSSINCTA:oBtn  :ForWhen(.T.)

     DPFOCUS(oACTIVOSSINCTA:oDesde)

  ELSE

     oACTIVOSSINCTA:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oACTIVOSSINCTA:oDesde:VarPut(oACTIVOSSINCTA:aFechas[1] , .T. )
     oACTIVOSSINCTA:oHasta:VarPut(oACTIVOSSINCTA:aFechas[2] , .T. )

     oACTIVOSSINCTA:dDesde:=oACTIVOSSINCTA:aFechas[1]
     oACTIVOSSINCTA:dHasta:=oACTIVOSSINCTA:aFechas[2]

     cWhere:=oACTIVOSSINCTA:HACERWHERE(oACTIVOSSINCTA:dDesde,oACTIVOSSINCTA:dHasta,oACTIVOSSINCTA:cWhere,.T.)

     oACTIVOSSINCTA:LEERDATA(cWhere,oACTIVOSSINCTA:oBrw,oACTIVOSSINCTA:cServer)

  ENDIF

  oACTIVOSSINCTA:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "DPACTIVOS.ATV_FCHADQ"$cWhere
     RETURN ""
   ENDIF

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

     IF !Empty(oACTIVOSSINCTA:cWhereQry)
       cWhere:=cWhere + oACTIVOSSINCTA:cWhereQry
     ENDIF

     oACTIVOSSINCTA:LEERDATA(cWhere,oACTIVOSSINCTA:oBrw,oACTIVOSSINCTA:cServer)

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


   cSql:=" SELECT  "+;
          "  ATV_CODIGO, "+;
          "  ATV_DESCRI, "+;
          "  ATV_FCHADQ, "+;
          "  ATV_COSADQ, "+;
          "  ATV_CODGRU, "+;
          "  GAC_DESCRI "+;
          "  FROM VIEW_ACTIVOSSINCTA   "+;
          "  INNER JOIN DPACTIVOS    ON ASC_CODIGO=ATV_CODIGO "+;
          "  INNER JOIN DPGRUACTIVOS ON GAC_CODIGO=ATV_CODGRU "+;
          "  WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" ATV_DEPRE='D' "+;
          "  ORDER BY ATV_CODIGO"+;
""

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.F.

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','',CTOD(""),0,'',''})
   ENDIF

   IF ValType(oBrw)="O"

      oACTIVOSSINCTA:cSql   :=cSql
      oACTIVOSSINCTA:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oACTIVOSSINCTA:oBrw:aCols[4]
         oCol:cFooter      :=FDP(aTotal[4],'999,999,999.99')

      oACTIVOSSINCTA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oACTIVOSSINCTA:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oACTIVOSSINCTA:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRACTIVOSSINCTA.MEM",V_nPeriodo:=oACTIVOSSINCTA:nPeriodo
  LOCAL V_dDesde:=oACTIVOSSINCTA:dDesde
  LOCAL V_dHasta:=oACTIVOSSINCTA:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oACTIVOSSINCTA)
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


    IF Type("oACTIVOSSINCTA")="O" .AND. oACTIVOSSINCTA:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty("oACTIVOSSINCTA":cWhere_),"oACTIVOSSINCTA":cWhere_,"oACTIVOSSINCTA":cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oACTIVOSSINCTA:LEERDATA(oACTIVOSSINCTA:cWhere_,oACTIVOSSINCTA:oBrw,oACTIVOSSINCTA:cServer)
      oACTIVOSSINCTA:oWnd:Show()
      oACTIVOSSINCTA:oWnd:Maximize()

    ENDIF

RETURN NIL

/*
// Genera Correspondencia Masiva
*/




 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oACTIVOSSINCTA)
// EOF