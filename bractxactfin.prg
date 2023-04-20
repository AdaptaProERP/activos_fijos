// Programa   : BRACTXACTFIN
// Fecha/Hora : 08/03/2017 05:31:55
// Propósito  : "Activos por Actualización Financiera"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRACTXACTFIN.MEM",V_nPeriodo:=4,cCodPar
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


   cTitle:="Activos por Actualización Financiera" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oACTXACTFIN
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)


   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD


   DPEDIT():New(cTitle,"BRACTXACTFIN.EDT","oACTXACTFIN",.F.)
   oACTXACTFIN:CreateWindow(NIL,NIL,NIL,550,820+58)




   oACTXACTFIN:cCodSuc  :=cCodSuc
   oACTXACTFIN:lMsgBar  :=.F.
   oACTXACTFIN:cPeriodo :=aPeriodos[nPeriodo]
   oACTXACTFIN:cCodSuc  :=cCodSuc
   oACTXACTFIN:nPeriodo :=nPeriodo
   oACTXACTFIN:cNombre  :=""
   oACTXACTFIN:dDesde   :=dDesde
   oACTXACTFIN:cServer  :=cServer
   oACTXACTFIN:dHasta   :=dHasta
   oACTXACTFIN:cWhere   :=cWhere
   oACTXACTFIN:cWhere_  :=cWhere_
   oACTXACTFIN:cWhereQry:=""
   oACTXACTFIN:cSql     :=oDp:cSql
   oACTXACTFIN:oWhere   :=TWHERE():New(oACTXACTFIN)
   oACTXACTFIN:cCodPar  :=cCodPar // Código del Parámetro
   oACTXACTFIN:lWhen    :=.T.
   oACTXACTFIN:cTextTit :="" // Texto del Titulo Heredado
    oACTXACTFIN:oDb     :=oDp:oDb
   oACTXACTFIN:cBrwCod  :="ACTXACTFIN"
   oACTXACTFIN:lTmdi    :=.F.



   oACTXACTFIN:oBrw:=TXBrowse():New( IF(oACTXACTFIN:lTmdi,oACTXACTFIN:oWnd,oACTXACTFIN:oDlg ))
   oACTXACTFIN:oBrw:SetArray( aData, .F. )
   oACTXACTFIN:oBrw:SetFont(oFont)

   oACTXACTFIN:oBrw:lFooter     := .T.
   oACTXACTFIN:oBrw:lHScroll    := .F.
   oACTXACTFIN:oBrw:nHeaderLines:= 2
   oACTXACTFIN:oBrw:nDataLines  := 1
   oACTXACTFIN:oBrw:nFooterLines:= 1




   oACTXACTFIN:aData            :=ACLONE(aData)

   AEVAL(oACTXACTFIN:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  oCol:=oACTXACTFIN:oBrw:aCols[1]
  oCol:cHeader      :='Código'+CRLF+'Activo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXACTFIN:oBrw:aArrayData ) } 
  oCol:nWidth       := 120

  oCol:=oACTXACTFIN:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXACTFIN:oBrw:aArrayData ) } 
  oCol:nWidth       := 400

  oCol:=oACTXACTFIN:oBrw:aCols[3]
  oCol:cHeader      :='Desde'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXACTFIN:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oACTXACTFIN:oBrw:aCols[4]
  oCol:cHeader      :='Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXACTFIN:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oACTXACTFIN:oBrw:aCols[5]
  oCol:cHeader      :='Monto'+CRLF+'Depreciación'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXACTFIN:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oACTXACTFIN:oBrw:aArrayData[oACTXACTFIN:oBrw:nArrayAt,5],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[5],'999,999,999.99')


  oCol:=oACTXACTFIN:oBrw:aCols[6]
  oCol:cHeader      :='Cant.'+CRLF+'Reg.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oACTXACTFIN:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oACTXACTFIN:oBrw:aArrayData[oACTXACTFIN:oBrw:nArrayAt,6],FDP(nMonto,'9,999')}
   oCol:cFooter      :=FDP(aTotal[6],'9,999')


   oACTXACTFIN:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oACTXACTFIN:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oACTXACTFIN:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 16055551, 14283517 ) } }

   oACTXACTFIN:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oACTXACTFIN:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oACTXACTFIN:oBrw:bLDblClick:={|oBrw|oACTXACTFIN:RUNCLICK() }

   oACTXACTFIN:oBrw:bChange:={||oACTXACTFIN:BRWCHANGE()}
   oACTXACTFIN:oBrw:CreateFromCode()



   oACTXACTFIN:Activate({||oACTXACTFIN:ViewDatBar()})


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oACTXACTFIN:lTmdi,oACTXACTFIN:oWnd,oACTXACTFIN:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oACTXACTFIN:oBrw:nWidth()

   oACTXACTFIN:oBrw:GoBottom(.T.)
   oACTXACTFIN:oBrw:Refresh(.T.)

   IF !File("FORMS\BRACTXACTFIN.EDT")
     oACTXACTFIN:oBrw:Move(44,0,820+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD




 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oACTXACTFIN:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oACTXACTFIN:oBrw,oACTXACTFIN:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF






  
/*
   IF Empty(oACTXACTFIN:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","ACTXACTFIN")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","ACTXACTFIN"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oACTXACTFIN:oBrw,"ACTXACTFIN",oACTXACTFIN:cSql,oACTXACTFIN:nPeriodo,oACTXACTFIN:dDesde,oACTXACTFIN:dHasta,oACTXACTFIN)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oACTXACTFIN:oBtnRun:=oBtn



       oACTXACTFIN:oBrw:bLDblClick:={||EVAL(oACTXACTFIN:oBtnRun:bAction) }


   ENDIF



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oACTXACTFIN:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oACTXACTFIN:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oACTXACTFIN:oBrw);
          WHEN LEN(oACTXACTFIN:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"



IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oACTXACTFIN:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oACTXACTFIN)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


IF nWidth>400

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oACTXACTFIN:oBrw,oACTXACTFIN:cTitle,oACTXACTFIN:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oACTXACTFIN:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oACTXACTFIN:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oACTXACTFIN:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oACTXACTFIN:oBrw))

   oBtn:cToolTip:="Previsualización"

   oACTXACTFIN:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRACTXACTFIN")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oACTXACTFIN:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oACTXACTFIN:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oACTXACTFIN:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oACTXACTFIN:oBrw:GoTop(),oACTXACTFIN:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oACTXACTFIN:oBrw:PageDown(),oACTXACTFIN:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oACTXACTFIN:oBrw:PageUp(),oACTXACTFIN:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oACTXACTFIN:oBrw:GoBottom(),oACTXACTFIN:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oACTXACTFIN:Close()

  oACTXACTFIN:oBrw:SetColor(0,16055551)

  EVAL(oACTXACTFIN:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oACTXACTFIN:oBar:=oBar

    nLin:=460

  // Controles se Inician luego del Ultimo Boton
  nLin:=32
  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ 10, nLin COMBOBOX oACTXACTFIN:oPeriodo  VAR oACTXACTFIN:cPeriodo ITEMS aPeriodos;
                SIZE 100,NIL;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oACTXACTFIN:LEEFECHAS();
                WHEN oACTXACTFIN:lWhen 


  ComboIni(oACTXACTFIN:oPeriodo )

  @ 10, nLin+103 BUTTON oACTXACTFIN:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oACTXACTFIN:oPeriodo:nAt,oACTXACTFIN:oDesde,oACTXACTFIN:oHasta,-1),;
                         EVAL(oACTXACTFIN:oBtn:bAction));
                WHEN oACTXACTFIN:lWhen 


  @ 10, nLin+130 BUTTON oACTXACTFIN:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oACTXACTFIN:oPeriodo:nAt,oACTXACTFIN:oDesde,oACTXACTFIN:oHasta,+1),;
                         EVAL(oACTXACTFIN:oBtn:bAction));
                WHEN oACTXACTFIN:lWhen 


  @ 10, nLin+170 BMPGET oACTXACTFIN:oDesde  VAR oACTXACTFIN:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oACTXACTFIN:oDesde ,oACTXACTFIN:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oACTXACTFIN:oPeriodo:nAt=LEN(oACTXACTFIN:oPeriodo:aItems) .AND. oACTXACTFIN:lWhen ;
                FONT oFont

   oACTXACTFIN:oDesde:cToolTip:="F6: Calendario"

  @ 10, nLin+252 BMPGET oACTXACTFIN:oHasta  VAR oACTXACTFIN:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oACTXACTFIN:oHasta,oACTXACTFIN:dHasta);
                SIZE 80,23;
                WHEN oACTXACTFIN:oPeriodo:nAt=LEN(oACTXACTFIN:oPeriodo:aItems) .AND. oACTXACTFIN:lWhen ;
                OF oBar;
                FONT oFont

   oACTXACTFIN:oHasta:cToolTip:="F6: Calendario"

   @ 10, nLin+335 BUTTON oACTXACTFIN:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oACTXACTFIN:oPeriodo:nAt=LEN(oACTXACTFIN:oPeriodo:aItems);
               ACTION oACTXACTFIN:HACERWHERE(oACTXACTFIN:dDesde,oACTXACTFIN:dHasta,oACTXACTFIN:cWhere,.T.);
               WHEN oACTXACTFIN:lWhen

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

  oRep:=REPORTE("BRACTXACTFIN",cWhere)
  oRep:cSql  :=oACTXACTFIN:cSql
  oRep:cTitle:=oACTXACTFIN:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oACTXACTFIN:oPeriodo:nAt,cWhere

  oACTXACTFIN:nPeriodo:=nPeriodo


  IF oACTXACTFIN:oPeriodo:nAt=LEN(oACTXACTFIN:oPeriodo:aItems)

     oACTXACTFIN:oDesde:ForWhen(.T.)
     oACTXACTFIN:oHasta:ForWhen(.T.)
     oACTXACTFIN:oBtn  :ForWhen(.T.)

     DPFOCUS(oACTXACTFIN:oDesde)

  ELSE

     oACTXACTFIN:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oACTXACTFIN:oDesde:VarPut(oACTXACTFIN:aFechas[1] , .T. )
     oACTXACTFIN:oHasta:VarPut(oACTXACTFIN:aFechas[2] , .T. )

     oACTXACTFIN:dDesde:=oACTXACTFIN:aFechas[1]
     oACTXACTFIN:dHasta:=oACTXACTFIN:aFechas[2]

     cWhere:=oACTXACTFIN:HACERWHERE(oACTXACTFIN:dDesde,oACTXACTFIN:dHasta,oACTXACTFIN:cWhere,.T.)

     oACTXACTFIN:LEERDATA(cWhere,oACTXACTFIN:oBrw,oACTXACTFIN:cServer)

  ENDIF

  oACTXACTFIN:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "dpdepreciaact .DEP_FECHA"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('dpdepreciaact .DEP_FECHA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('dpdepreciaact .DEP_FECHA',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oACTXACTFIN:cWhereQry)
       cWhere:=cWhere + oACTXACTFIN:cWhereQry
     ENDIF

     oACTXACTFIN:LEERDATA(cWhere,oACTXACTFIN:oBrw,oACTXACTFIN:cServer)

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


   cSql:=" SELECT    "+;
          "  DEP_CODACT,     "+;
          "  ATV_DESCRI,     "+;
          "  MIN(DEP_FECHA), "+;
          "  MAX(DEP_FECHA), "+;
          "  SUM(DEP_MONTO), "+;
          "  COUNT(*)        "+;
          "  FROM dpdepreciaact   "+;
          "  INNER JOIN DPACTIVOS ON DEP_CODACT=ATV_CODIGO "+;
          "  WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" DEP_DEPFIN=0 OR DEP_DEPFIN IS NULL AND DEP_ESTADO='A' "+;
          "  GROUP BY DEP_CODACT   "+;
          "  ORDER BY DEP_CODACT "+;
""

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.T.

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','',CTOD(""),CTOD(""),0,0})
   ENDIF

   IF ValType(oBrw)="O"

      oACTXACTFIN:cSql   :=cSql
      oACTXACTFIN:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oACTXACTFIN:oBrw:aCols[5]
         oCol:cFooter      :=FDP(aTotal[5],'999,999,999.99')
      oCol:=oACTXACTFIN:oBrw:aCols[6]
         oCol:cFooter      :=FDP(aTotal[6],'9,999')

      oACTXACTFIN:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oACTXACTFIN:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oACTXACTFIN:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRACTXACTFIN.MEM",V_nPeriodo:=oACTXACTFIN:nPeriodo
  LOCAL V_dDesde:=oACTXACTFIN:dDesde
  LOCAL V_dHasta:=oACTXACTFIN:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oACTXACTFIN)
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


    IF Type("oACTXACTFIN")="O" .AND. oACTXACTFIN:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty("oACTXACTFIN":cWhere_),"oACTXACTFIN":cWhere_,"oACTXACTFIN":cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oACTXACTFIN:LEERDATA(oACTXACTFIN:cWhere_,oACTXACTFIN:oBrw,oACTXACTFIN:cServer)
      oACTXACTFIN:oWnd:Show()
      oACTXACTFIN:oWnd:Maximize()

    ENDIF

RETURN NIL

/*
// Genera Correspondencia Masiva
*/


// EOF
