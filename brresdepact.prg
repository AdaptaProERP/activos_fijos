// Programa   : BRRESDEPACT
// Fecha/Hora : 20/01/2019 02:16:30
// Propósito  : "Resumen de Depreciación de Activos"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRRESDEPACT.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oRESDEPACT")="O" .AND. oRESDEPACT:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oRESDEPACT,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 


   cTitle:="Resumen de Depreciación de Activos" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oRESDEPACT
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD




   DpMdi(cTitle,"oRESDEPACT","BRRESDEPACT.EDT")
// oRESDEPACT:CreateWindow(0,0,100,550)
   oRESDEPACT:Windows(0,0,aCoors[3]-160,aCoors[4]-10,.T.) // Maximizado



   oRESDEPACT:cCodSuc  :=cCodSuc
   oRESDEPACT:lMsgBar  :=.F.
   oRESDEPACT:cPeriodo :=aPeriodos[nPeriodo]
   oRESDEPACT:cCodSuc  :=cCodSuc
   oRESDEPACT:nPeriodo :=nPeriodo
   oRESDEPACT:cNombre  :=""
   oRESDEPACT:dDesde   :=dDesde
   oRESDEPACT:cServer  :=cServer
   oRESDEPACT:dHasta   :=dHasta
   oRESDEPACT:cWhere   :=cWhere
   oRESDEPACT:cWhere_  :=cWhere_
   oRESDEPACT:cWhereQry:=""
   oRESDEPACT:cSql     :=oDp:cSql
   oRESDEPACT:oWhere   :=TWHERE():New(oRESDEPACT)
   oRESDEPACT:cCodPar  :=cCodPar // Código del Parámetro
   oRESDEPACT:lWhen    :=.T.
   oRESDEPACT:cTextTit :="" // Texto del Titulo Heredado
    oRESDEPACT:oDb     :=oDp:oDb
   oRESDEPACT:cBrwCod  :="RESDEPACT"
   oRESDEPACT:lTmdi    :=.T.



   oRESDEPACT:oBrw:=TXBrowse():New( IF(oRESDEPACT:lTmdi,oRESDEPACT:oWnd,oRESDEPACT:oDlg ))
   oRESDEPACT:oBrw:SetArray( aData, .F. )
   oRESDEPACT:oBrw:SetFont(oFont)

   oRESDEPACT:oBrw:lFooter     := .T.
   oRESDEPACT:oBrw:lHScroll    := .F.
   oRESDEPACT:oBrw:nHeaderLines:= 2
   oRESDEPACT:oBrw:nDataLines  := 1
   oRESDEPACT:oBrw:nFooterLines:= 1




   oRESDEPACT:aData            :=ACLONE(aData)
  oRESDEPACT:nClrText :=0
  oRESDEPACT:nClrPane1:=16772313
  oRESDEPACT:nClrPane2:=16767411

   AEVAL(oRESDEPACT:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  oCol:=oRESDEPACT:oBrw:aCols[1]
  oCol:cHeader      :='Código de Activo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRESDEPACT:oBrw:aArrayData ) } 
  oCol:nWidth       := 120

  oCol:=oRESDEPACT:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRESDEPACT:oBrw:aArrayData ) } 
  oCol:nWidth       := 400

  oCol:=oRESDEPACT:oBrw:aCols[3]
  oCol:cHeader      :='Grupo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRESDEPACT:oBrw:aArrayData ) } 
  oCol:nWidth       := 64

  oCol:=oRESDEPACT:oBrw:aCols[4]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRESDEPACT:oBrw:aArrayData ) } 
  oCol:nWidth       := 280

  oCol:=oRESDEPACT:oBrw:aCols[5]
  oCol:cHeader      :='DESDE'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRESDEPACT:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oRESDEPACT:oBrw:aCols[6]
  oCol:cHeader      :='HASTA'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRESDEPACT:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oRESDEPACT:oBrw:aCols[7]
  oCol:cHeader      :='Monto'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oRESDEPACT:oBrw:aArrayData ) } 
  oCol:nWidth       := 128
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oRESDEPACT:oBrw:aArrayData[oRESDEPACT:oBrw:nArrayAt,7],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[7],'999,999,999.99')


   oRESDEPACT:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oRESDEPACT:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oRESDEPACT:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oRESDEPACT:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oRESDEPACT:nClrPane1, oRESDEPACT:nClrPane2 ) } }

   oRESDEPACT:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oRESDEPACT:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oRESDEPACT:oBrw:bLDblClick:={|oBrw|oRESDEPACT:RUNCLICK() }

   oRESDEPACT:oBrw:bChange:={||oRESDEPACT:BRWCHANGE()}
   oRESDEPACT:oBrw:CreateFromCode()
    oRESDEPACT:bValid   :={|| EJECUTAR("BRWSAVEPAR",oRESDEPACT)}
    oRESDEPACT:BRWRESTOREPAR()


   oRESDEPACT:oWnd:oClient := oRESDEPACT:oBrw


   oRESDEPACT:Activate({||oRESDEPACT:ViewDatBar()})


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oRESDEPACT:lTmdi,oRESDEPACT:oWnd,oRESDEPACT:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oRESDEPACT:oBrw:nWidth()

   oRESDEPACT:oBrw:GoBottom(.T.)
   oRESDEPACT:oBrw:Refresh(.T.)

   IF !File("FORMS\BRRESDEPACT.EDT")
     oRESDEPACT:oBrw:Move(44,0,850+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD




 // Emanager no Incluye consulta de Vinculos


   IF .F. .AND. Empty(oRESDEPACT:cServer)

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\VIEW.BMP";
            ACTION EJECUTAR("BRWRUNLINK",oRESDEPACT:oBrw,oRESDEPACT:cSql)

     oBtn:cToolTip:="Consultar Vinculos"


   ENDIF






  
/*
   IF Empty(oRESDEPACT:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","RESDEPACT")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","RESDEPACT"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oRESDEPACT:oBrw,"RESDEPACT",oRESDEPACT:cSql,oRESDEPACT:nPeriodo,oRESDEPACT:dDesde,oRESDEPACT:dHasta,oRESDEPACT)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oRESDEPACT:oBtnRun:=oBtn



       oRESDEPACT:oBrw:bLDblClick:={||EVAL(oRESDEPACT:oBtnRun:bAction) }


   ENDIF



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oRESDEPACT:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oRESDEPACT:oBrw,oRESDEPACT);
          ACTION EJECUTAR("BRWSETFILTER",oRESDEPACT:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oRESDEPACT:oBrw);
          WHEN LEN(oRESDEPACT:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

/*
      DEFINE BUTTON oBtn;
             OF oBar;
             NOBORDER;
             FONT oFont;
             MENU EJECUTAR("BRBTNMENU",{"Opción1","Opción"},"oFrm");
             FILENAME "BITMAPS\MENU.BMP";
             ACTION 1=1;

             oBtn:cToolTip:="Boton con Menu"

*/


IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oRESDEPACT:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oRESDEPACT)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


IF nWidth>400

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oRESDEPACT:oBrw,oRESDEPACT:cTitle,oRESDEPACT:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oRESDEPACT:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oRESDEPACT:HTMLHEAD(),EJECUTAR("BRWTOHTML",oRESDEPACT:oBrw,NIL,oRESDEPACT:cTitle,oRESDEPACT:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oRESDEPACT:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oRESDEPACT:oBrw))

   oBtn:cToolTip:="Previsualización"

   oRESDEPACT:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRRESDEPACT")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oRESDEPACT:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oRESDEPACT:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oRESDEPACT:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oRESDEPACT:oBrw:GoTop(),oRESDEPACT:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oRESDEPACT:oBrw:PageDown(),oRESDEPACT:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oRESDEPACT:oBrw:PageUp(),oRESDEPACT:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oRESDEPACT:oBrw:GoBottom(),oRESDEPACT:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oRESDEPACT:Close()

  oRESDEPACT:oBrw:SetColor(0,oRESDEPACT:nClrPane1)

  EVAL(oRESDEPACT:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oRESDEPACT:oBar:=oBar

    nLin:=490

  // Controles se Inician luego del Ultimo Boton
  nLin:=32
  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ 10, nLin COMBOBOX oRESDEPACT:oPeriodo  VAR oRESDEPACT:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oRESDEPACT:LEEFECHAS();
                WHEN oRESDEPACT:lWhen 


  ComboIni(oRESDEPACT:oPeriodo )

  @ 10, nLin+103 BUTTON oRESDEPACT:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oRESDEPACT:oPeriodo:nAt,oRESDEPACT:oDesde,oRESDEPACT:oHasta,-1),;
                         EVAL(oRESDEPACT:oBtn:bAction));
                WHEN oRESDEPACT:lWhen 


  @ 10, nLin+130 BUTTON oRESDEPACT:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oRESDEPACT:oPeriodo:nAt,oRESDEPACT:oDesde,oRESDEPACT:oHasta,+1),;
                         EVAL(oRESDEPACT:oBtn:bAction));
                WHEN oRESDEPACT:lWhen 


  @ 10, nLin+170 BMPGET oRESDEPACT:oDesde  VAR oRESDEPACT:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oRESDEPACT:oDesde ,oRESDEPACT:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oRESDEPACT:oPeriodo:nAt=LEN(oRESDEPACT:oPeriodo:aItems) .AND. oRESDEPACT:lWhen ;
                FONT oFont

   oRESDEPACT:oDesde:cToolTip:="F6: Calendario"

  @ 10, nLin+252 BMPGET oRESDEPACT:oHasta  VAR oRESDEPACT:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oRESDEPACT:oHasta,oRESDEPACT:dHasta);
                SIZE 80,23;
                WHEN oRESDEPACT:oPeriodo:nAt=LEN(oRESDEPACT:oPeriodo:aItems) .AND. oRESDEPACT:lWhen ;
                OF oBar;
                FONT oFont

   oRESDEPACT:oHasta:cToolTip:="F6: Calendario"

   @ 10, nLin+335 BUTTON oRESDEPACT:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oRESDEPACT:oPeriodo:nAt=LEN(oRESDEPACT:oPeriodo:aItems);
               ACTION oRESDEPACT:HACERWHERE(oRESDEPACT:dDesde,oRESDEPACT:dHasta,oRESDEPACT:cWhere,.T.);
               WHEN oRESDEPACT:lWhen

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

  oRep:=REPORTE("BRRESDEPACT",cWhere)
  oRep:cSql  :=oRESDEPACT:cSql
  oRep:cTitle:=oRESDEPACT:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oRESDEPACT:oPeriodo:nAt,cWhere

  oRESDEPACT:nPeriodo:=nPeriodo


  IF oRESDEPACT:oPeriodo:nAt=LEN(oRESDEPACT:oPeriodo:aItems)

     oRESDEPACT:oDesde:ForWhen(.T.)
     oRESDEPACT:oHasta:ForWhen(.T.)
     oRESDEPACT:oBtn  :ForWhen(.T.)

     DPFOCUS(oRESDEPACT:oDesde)

  ELSE

     oRESDEPACT:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oRESDEPACT:oDesde:VarPut(oRESDEPACT:aFechas[1] , .T. )
     oRESDEPACT:oHasta:VarPut(oRESDEPACT:aFechas[2] , .T. )

     oRESDEPACT:dDesde:=oRESDEPACT:aFechas[1]
     oRESDEPACT:dHasta:=oRESDEPACT:aFechas[2]

     cWhere:=oRESDEPACT:HACERWHERE(oRESDEPACT:dDesde,oRESDEPACT:dHasta,oRESDEPACT:cWhere,.T.)

     oRESDEPACT:LEERDATA(cWhere,oRESDEPACT:oBrw,oRESDEPACT:cServer)

  ENDIF

  oRESDEPACT:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "DPDEPRECIAACT .DEP_FECHA"$cWhere
     RETURN ""
   ENDIF

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

     IF !Empty(oRESDEPACT:cWhereQry)
       cWhere:=cWhere + oRESDEPACT:cWhereQry
     ENDIF

     oRESDEPACT:LEERDATA(cWhere,oRESDEPACT:oBrw,oRESDEPACT:cServer)

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
          " ATV_CODGRU,"+;
          " GAC_DESCRI,"+;
          " MIN(DEP_FECHA) AS DESDE,"+;
          " MAX(DEP_FECHA) AS HASTA,"+;
          " SUM(DEP_MONTO) AS DEP_MONTO"+;
          " FROM DPDEPRECIAACT"+;
          " INNER JOIN DPACTIVOS ON ATV_CODIGO=DEP_CODACT"+;
          " INNER JOIN DPGRUACTIVOS ON ATV_CODGRU=GAC_CODIGO"+;
          " WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" ATV_CODSUC=&oDp:cSucursal AND (ATV_ESTADO='A' OR ATV_ESTADO=' ')"+;
          " GROUP BY DEP_CODACT"+;
          " ORDER BY DEP_CODACT"+;
""

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRRESDEPACT.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','',CTOD(""),CTOD(""),0})
   ENDIF

   IF ValType(oBrw)="O"

      oRESDEPACT:cSql   :=cSql
      oRESDEPACT:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oRESDEPACT:oBrw:aCols[7]
         oCol:cFooter      :=FDP(aTotal[7],'999,999,999.99')

      oRESDEPACT:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oRESDEPACT:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oRESDEPACT:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRRESDEPACT.MEM",V_nPeriodo:=oRESDEPACT:nPeriodo
  LOCAL V_dDesde:=oRESDEPACT:dDesde
  LOCAL V_dHasta:=oRESDEPACT:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oRESDEPACT)
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


    IF Type("oRESDEPACT")="O" .AND. oRESDEPACT:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oRESDEPACT:cWhere_),oRESDEPACT:cWhere_,oRESDEPACT:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oRESDEPACT:LEERDATA(oRESDEPACT:cWhere_,oRESDEPACT:oBrw,oRESDEPACT:cServer)
      oRESDEPACT:oWnd:Show()
      oRESDEPACT:oWnd:Restore()

    ENDIF

RETURN NIL


FUNCTION BTNMENU(nOption,cOption)

   IF nOption=1
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oRESDEPACT:aHead:=EJECUTAR("HTMLHEAD",oRESDEPACT)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN



/*
// Genera Correspondencia Masiva
*/




 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oRESDEPACT)
// EOF