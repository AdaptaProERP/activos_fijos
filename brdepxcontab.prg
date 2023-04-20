// Programa   : BRDEPXCONTAB
// Fecha/Hora : 31/12/2018 01:28:45
// Propósito  : "Depreciaciones de Activos por Contabilizar"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRDEPXCONTAB.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   DEFAULT oDp:cNumCom:=STRZERO(1,8)


   IF Type("oDEPXCONTAB")="O" .AND. oDEPXCONTAB:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oDEPXCONTAB,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 


   cTitle:="Depreciaciones de Activos por Contabilizar" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")

   IF Empty(dDesde)
      nPeriodo:=4
   ENDIF


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

   oDp:oFrm:=oDEPXCONTAB
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 BOLD
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oDEPXCONTAB","BRDEPXCONTAB.EDT")
// oDEPXCONTAB:CreateWindow(0,0,100,550)
   oDEPXCONTAB:Windows(0,0,aCoors[3]-160,MIN(1170,aCoors[4]-10),.T.) // Maximizado

   oDEPXCONTAB:cCodSuc  :=cCodSuc
   oDEPXCONTAB:lMsgBar  :=.F.
   oDEPXCONTAB:cPeriodo :=aPeriodos[nPeriodo]
   oDEPXCONTAB:cCodSuc  :=cCodSuc
   oDEPXCONTAB:nPeriodo :=nPeriodo
   oDEPXCONTAB:cNombre  :=""
   oDEPXCONTAB:dDesde   :=dDesde
   oDEPXCONTAB:cServer  :=cServer
   oDEPXCONTAB:dHasta   :=dHasta
   oDEPXCONTAB:cWhere   :=cWhere
   oDEPXCONTAB:cWhere_  :=cWhere_
   oDEPXCONTAB:cWhereQry:=""
   oDEPXCONTAB:cSql     :=oDp:cSql
   oDEPXCONTAB:oWhere   :=TWHERE():New(oDEPXCONTAB)
   oDEPXCONTAB:cCodPar  :=cCodPar // Código del Parámetro
   oDEPXCONTAB:lWhen    :=.T.
   oDEPXCONTAB:cTextTit :="" // Texto del Titulo Heredado
    oDEPXCONTAB:oDb     :=oDp:oDb
   oDEPXCONTAB:cBrwCod  :="DEPXCONTAB"
   oDEPXCONTAB:lTmdi    :=.T.
   oDEPXCONTAB:cNumero  :=oDp:cNumCom

   oDEPXCONTAB:nCuantos :=0
   oDEPXCONTAB:lTodos   :=.T.

   oDEPXCONTAB:oBrw:=TXBrowse():New( IF(oDEPXCONTAB:lTmdi,oDEPXCONTAB:oWnd,oDEPXCONTAB:oDlg ))
   oDEPXCONTAB:oBrw:SetArray( aData, .F. )
   oDEPXCONTAB:oBrw:SetFont(oFont)

   oDEPXCONTAB:oBrw:lFooter     := .T.
   oDEPXCONTAB:oBrw:lHScroll    := .F.
   oDEPXCONTAB:oBrw:nHeaderLines:= 2
   oDEPXCONTAB:oBrw:nDataLines  := 1
   oDEPXCONTAB:oBrw:nFooterLines:= 1

   oDEPXCONTAB:aData            :=ACLONE(aData)
  oDEPXCONTAB:nClrText :=6250335
  oDEPXCONTAB:nClrPane1:=16772055
  oDEPXCONTAB:nClrPane2:=16768185

   AEVAL(oDEPXCONTAB:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oCol:=oDEPXCONTAB:oBrw:aCols[1]
  oCol:cHeader      :='Código'+CRLF+'Activo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPXCONTAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 120

  oCol:=oDEPXCONTAB:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPXCONTAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 400

  oCol:=oDEPXCONTAB:oBrw:aCols[3]
  oCol:cHeader      :='Fecha'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPXCONTAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oDEPXCONTAB:oBrw:aCols[4]
  oCol:cHeader      :='Núm.'+CRLF+'Dep.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPXCONTAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 40

  oCol:=oDEPXCONTAB:oBrw:aCols[5]
  oCol:cHeader      :='Monto'+CRLF+'Depreciación'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPXCONTAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 128
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oDEPXCONTAB:oBrw:aArrayData[oDEPXCONTAB:oBrw:nArrayAt,5],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[5],'999,999,999.99')


  oCol:=oDEPXCONTAB:oBrw:aCols[6]
  oCol:cHeader      :='Cbte.'+CRLF+'Contab.'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPXCONTAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 64

  oCol:=oDEPXCONTAB:oBrw:aCols[7]
  oCol:cHeader      :='Estado'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPXCONTAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 20

  oCol:=oDEPXCONTAB:oBrw:aCols[8]
  oCol:cHeader      :='Monto'+CRLF+'Asiento'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPXCONTAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 192
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oDEPXCONTAB:oBrw:aArrayData[oDEPXCONTAB:oBrw:nArrayAt,8],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[8],'999,999,999.99')


  oCol:=oDEPXCONTAB:oBrw:aCols[9]
  oCol:cHeader      :='Tipo'+CRLF+'Asiento'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPXCONTAB:oBrw:aArrayData ) } 
  oCol:nWidth       := 60

  oCol:AddBmpFile("BITMAPS\ledrojo.bmp")
  oCol:AddBmpFile("BITMAPS\ledverde.bmp")
  oCol:AddBmpFile("BITMAPS\ledamarillo.bmp")

  oCol:bBmpData    := { ||oBrw:=oDEPXCONTAB:oBrw,oBrw:aArrayData[oBrw:nArrayAt,10] }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)


  oDEPXCONTAB:oBrw:DelCol(10)


   oDEPXCONTAB:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oDEPXCONTAB:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oDEPXCONTAB:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oDEPXCONTAB:nClrText,;
                                           nClrText:=IF(Empty(oBrw:aArrayData[oBrw:nArrayAt,5]),6250335,nClrText),;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oDEPXCONTAB:nClrPane1, oDEPXCONTAB:nClrPane2 ) } }

   oDEPXCONTAB:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oDEPXCONTAB:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oDEPXCONTAB:oBrw:bLDblClick:={|oBrw|oDEPXCONTAB:RUNCLICK() }

   oDEPXCONTAB:oBrw:bChange:={||oDEPXCONTAB:BRWCHANGE()}
   oDEPXCONTAB:oBrw:CreateFromCode()
    oDEPXCONTAB:bValid   :={|| EJECUTAR("BRWSAVEPAR",oDEPXCONTAB)}
    oDEPXCONTAB:BRWRESTOREPAR()

   oDEPXCONTAB:oWnd:oClient := oDEPXCONTAB:oBrw

   oDEPXCONTAB:Activate({||oDEPXCONTAB:ViewDatBar()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oDEPXCONTAB:lTmdi,oDEPXCONTAB:oWnd,oDEPXCONTAB:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oDEPXCONTAB:oBrw:nWidth()

   oDEPXCONTAB:oBrw:GoBottom(.T.)
   oDEPXCONTAB:oBrw:Refresh(.T.)

   IF !File("FORMS\BRDEPXCONTAB.EDT")
     oDEPXCONTAB:oBrw:Move(44,0,850+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD


 // Emanager no Incluye consulta de Vinculos


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RUN.BMP";
          ACTION oDEPXCONTAB:RUNCONTAB()

   oBtn:cToolTip:="Crear Asientos Contables"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\ACTIVOS.BMP";
          ACTION oDEPXCONTAB:DPACTIVOS()

   oBtn:cToolTip:="Editar Activo"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\VIEW.BMP";
          ACTION oDEPXCONTAB:VERACTIVOS()

   oBtn:cToolTip:="Visualizar Activo"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\cbtediferido.BMP";
          ACTION oDEPXCONTAB:VERCBTE()

   oBtn:cToolTip:="Visualizar Asiento"

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP";
          ACTION oDEPXCONTAB:DPDEPREC()

   oBtn:cToolTip:="Visualizar Depreciaciones"








   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oDEPXCONTAB:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oDEPXCONTAB:oBrw,oDEPXCONTAB);
          ACTION EJECUTAR("BRWSETFILTER",oDEPXCONTAB:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oDEPXCONTAB:oBrw);
          WHEN LEN(oDEPXCONTAB:oBrw:aArrayData)>1

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
          ACTION oDEPXCONTAB:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oDEPXCONTAB)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


IF nWidth>400

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oDEPXCONTAB:oBrw,oDEPXCONTAB:cTitle,oDEPXCONTAB:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oDEPXCONTAB:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oDEPXCONTAB:HTMLHEAD(),EJECUTAR("BRWTOHTML",oDEPXCONTAB:oBrw,NIL,oDEPXCONTAB:cTitle,oDEPXCONTAB:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oDEPXCONTAB:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oDEPXCONTAB:oBrw))

   oBtn:cToolTip:="Previsualización"

   oDEPXCONTAB:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRDEPXCONTAB")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oDEPXCONTAB:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oDEPXCONTAB:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oDEPXCONTAB:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oDEPXCONTAB:oBrw:GoTop(),oDEPXCONTAB:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oDEPXCONTAB:oBrw:PageDown(),oDEPXCONTAB:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oDEPXCONTAB:oBrw:PageUp(),oDEPXCONTAB:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oDEPXCONTAB:oBrw:GoBottom(),oDEPXCONTAB:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oDEPXCONTAB:Close()

  oDEPXCONTAB:oBrw:SetColor(0,oDEPXCONTAB:nClrPane1)

  EVAL(oDEPXCONTAB:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oDEPXCONTAB:oBar:=oBar

    nLin:=490

  // Controles se Inician luego del Ultimo Boton
  nLin:=32
  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  //
  // Campo : Periodo
  //

  @ 10, nLin COMBOBOX oDEPXCONTAB:oPeriodo  VAR oDEPXCONTAB:cPeriodo ITEMS aPeriodos;
                SIZE 100,200;
                PIXEL;
                OF oBar;
                FONT oFont;
                ON CHANGE oDEPXCONTAB:LEEFECHAS();
                WHEN oDEPXCONTAB:lWhen 


  ComboIni(oDEPXCONTAB:oPeriodo )

  @ 10, nLin+103 BUTTON oDEPXCONTAB:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oDEPXCONTAB:oPeriodo:nAt,oDEPXCONTAB:oDesde,oDEPXCONTAB:oHasta,-1),;
                         EVAL(oDEPXCONTAB:oBtn:bAction));
                WHEN oDEPXCONTAB:lWhen 


  @ 10, nLin+130 BUTTON oDEPXCONTAB:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 PIXEL;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oDEPXCONTAB:oPeriodo:nAt,oDEPXCONTAB:oDesde,oDEPXCONTAB:oHasta,+1),;
                         EVAL(oDEPXCONTAB:oBtn:bAction));
                WHEN oDEPXCONTAB:lWhen 


  @ 10, nLin+170 BMPGET oDEPXCONTAB:oDesde  VAR oDEPXCONTAB:dDesde;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDEPXCONTAB:oDesde ,oDEPXCONTAB:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oDEPXCONTAB:oPeriodo:nAt=LEN(oDEPXCONTAB:oPeriodo:aItems) .AND. oDEPXCONTAB:lWhen ;
                FONT oFont

   oDEPXCONTAB:oDesde:cToolTip:="F6: Calendario"

  @ 10, nLin+252 BMPGET oDEPXCONTAB:oHasta  VAR oDEPXCONTAB:dHasta;
                PICTURE "99/99/9999";
                PIXEL;
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDEPXCONTAB:oHasta,oDEPXCONTAB:dHasta);
                SIZE 80,23;
                WHEN oDEPXCONTAB:oPeriodo:nAt=LEN(oDEPXCONTAB:oPeriodo:aItems) .AND. oDEPXCONTAB:lWhen ;
                OF oBar;
                FONT oFont

   oDEPXCONTAB:oHasta:cToolTip:="F6: Calendario"

   @ 10, nLin+335 BUTTON oDEPXCONTAB:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               PIXEL;
               WHEN oDEPXCONTAB:oPeriodo:nAt=LEN(oDEPXCONTAB:oPeriodo:aItems);
               ACTION oDEPXCONTAB:HACERWHERE(oDEPXCONTAB:dDesde,oDEPXCONTAB:dHasta,oDEPXCONTAB:cWhere,.T.);
               WHEN oDEPXCONTAB:lWhen

  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})


  @ 10,nLin+380 SAY oDEPXCONTAB:oSay    PROMPT "Número " SIZE 80,20 RIGHT OF oBar PIXEL BORDER
  @ 10,nLin+460 GET oDEPXCONTAB:oNumero VAR oDEPXCONTAB:cNumero OF oBar PIXEL SIZE 80,20 
 
  AEVAL(oBar:aControls,{|o|o:ForWhen(.T.)})

  @ 01,nLin+380 SAY   oDEPXCONTAB:oSayProgress PROMPT "Lectura"             OF oBar PIXEL SIZE 160,20
  @ 20,nLin+380 METER oDEPXCONTAB:oMeter       VAR oDEPXCONTAB:nCuantos  OF oBar PIXEL SIZE 160,20
 
  oDEPXCONTAB:oSayProgress:Hide()
  oDEPXCONTAB:oMeter:Hide()



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

  oRep:=REPORTE("BRDEPXCONTAB",cWhere)
  oRep:cSql  :=oDEPXCONTAB:cSql
  oRep:cTitle:=oDEPXCONTAB:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oDEPXCONTAB:oPeriodo:nAt,cWhere

  oDEPXCONTAB:nPeriodo:=nPeriodo


  IF oDEPXCONTAB:oPeriodo:nAt=LEN(oDEPXCONTAB:oPeriodo:aItems)

     oDEPXCONTAB:oDesde:ForWhen(.T.)
     oDEPXCONTAB:oHasta:ForWhen(.T.)
     oDEPXCONTAB:oBtn  :ForWhen(.T.)

     DPFOCUS(oDEPXCONTAB:oDesde)

  ELSE

     oDEPXCONTAB:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oDEPXCONTAB:oDesde:VarPut(oDEPXCONTAB:aFechas[1] , .T. )
     oDEPXCONTAB:oHasta:VarPut(oDEPXCONTAB:aFechas[2] , .T. )

     oDEPXCONTAB:dDesde:=oDEPXCONTAB:aFechas[1]
     oDEPXCONTAB:dHasta:=oDEPXCONTAB:aFechas[2]

     cWhere:=oDEPXCONTAB:HACERWHERE(oDEPXCONTAB:dDesde,oDEPXCONTAB:dHasta,oDEPXCONTAB:cWhere,.T.)

     oDEPXCONTAB:LEERDATA(cWhere,oDEPXCONTAB:oBrw,oDEPXCONTAB:cServer)

  ENDIF

  oDEPXCONTAB:SAVEPERIODO()

RETURN .T.


FUNCTION HACERWHERE(dDesde,dHasta,cWhere_,lRun)
   LOCAL cWhere:=""

   DEFAULT lRun:=.F.

   // Campo fecha no puede estar en la nueva clausula
   IF "DPDEPRECIAACT.DEP_FECHA"$cWhere
     RETURN ""
   ENDIF

   IF !Empty(dDesde)
       cWhere:=GetWhereAnd('DPDEPRECIAACT.DEP_FECHA',dDesde,dHasta)
   ELSE
     IF !Empty(dHasta)
       cWhere:=GetWhereAnd('DPDEPRECIAACT.DEP_FECHA',dDesde,dHasta)
     ENDIF
   ENDIF


   IF !Empty(cWhere_)
      cWhere:=cWhere + IIF( Empty(cWhere),""," AND ") +cWhere_
   ENDIF

   IF lRun

     IF !Empty(oDEPXCONTAB:cWhereQry)
       cWhere:=cWhere + oDEPXCONTAB:cWhereQry
     ENDIF

     oDEPXCONTAB:LEERDATA(cWhere,oDEPXCONTAB:oBrw,oDEPXCONTAB:cServer)

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
          "  DEP_CODACT, "+;
          "  ATV_DESCRI, "+;
          "  DEP_FECHA, "+;
          "  DEP_NUMERO, "+;
          "  DEP_MONTO, "+;
          "  DEP_COMPRO, "+;
          "  DEP_ESTADO, "+;
          "  MOC_MONTO, "+;
          "  MOC_ACTUAL,0 AS LED "+;
          "  FROM DPDEPRECIAACT "+;
          "  INNER JOIN DPACTIVOS  ON DEP_CODACT=ATV_CODIGO "+;
          "  LEFT  JOIN DPASIENTOS ON DEP_CODSUC=MOC_CODSUC AND  DEP_COMPRO=MOC_NUMCBT AND DEP_FECHA=MOC_FECHA AND MOC_TIPO='ACT' AND DEP_CODACT=MOC_DOCUME AND DEP_CODACT=MOC_CODAUX  "+;
          "  WHERE DEP_CODSUC"+GetWhere("=",oDp:cSucursal)+IF(Empty(cWhere),""," AND ")+cWhere+;
          "  GROUP BY DEP_CODACT,DEP_NUMERO "+;
          "  ORDER BY DEP_CODACT "+;
          ""

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.F.

   DPWRITE("TEMP\BRDEPXCONTAB.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   AEVAL(aData,{|a,n| aData[n,10]:=1,;
                      aData[n,10]:=IF(a[9]="S",2,aData[n,10]),;
                      aData[n,10]:=IF(a[9]="N",3,aData[n,10])})

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','',CTOD(""),'',0,'','',0,''})
   ENDIF

   IF ValType(oBrw)="O"

      oDEPXCONTAB:cSql   :=cSql
      oDEPXCONTAB:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oDEPXCONTAB:oBrw:aCols[5]
         oCol:cFooter      :=FDP(aTotal[5],'999,999,999.99')
      oCol:=oDEPXCONTAB:oBrw:aCols[8]
         oCol:cFooter      :=FDP(aTotal[8],'999,999,999.99')

      oDEPXCONTAB:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oDEPXCONTAB:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oDEPXCONTAB:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRDEPXCONTAB.MEM",V_nPeriodo:=oDEPXCONTAB:nPeriodo
  LOCAL V_dDesde:=oDEPXCONTAB:dDesde
  LOCAL V_dHasta:=oDEPXCONTAB:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oDEPXCONTAB)
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


    IF Type("oDEPXCONTAB")="O" .AND. oDEPXCONTAB:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oDEPXCONTAB:cWhere_),oDEPXCONTAB:cWhere_,oDEPXCONTAB:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oDEPXCONTAB:LEERDATA(oDEPXCONTAB:cWhere_,oDEPXCONTAB:oBrw,oDEPXCONTAB:cServer)
      oDEPXCONTAB:oWnd:Show()
      oDEPXCONTAB:oWnd:Restore()

    ENDIF

RETURN NIL


FUNCTION BTNMENU(nOption,cOption)

   IF nOption=1
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oDEPXCONTAB:aHead:=EJECUTAR("HTMLHEAD",oDEPXCONTAB)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

/*
// Contabilizar; no Contabiliza Asientos Actualizados
*/
FUNCTION RUNCONTAB()
   LOCAL I,aData:=ACLONE(oDEPXCONTAB:oBrw:aArrayData)
   LOCAL cCodigo,dFecha

//   ADEPURA(aData,{|a,n| !a[9]="C" .AND. !"00107"$a[1]})

   ADEPURA(aData,{|a,n| Empty(a[5]) .AND. !a[9]="C" })

   oDEPXCONTAB:oBrw:aArrayData:=aData
   oDEPXCONTAB:oBrw:Refresh(.T.)

   IF !MsgYesNo("Desea Contabilizar "+LSTR(LEN(aData))+" Depuraciones")
      oDEPXCONTAB:BRWREFRESCAR()
      RETURN .F.
   ENDIF

  oDEPXCONTAB:oSay:Hide()
  oDEPXCONTAB:oNumero:Hide()

  oDEPXCONTAB:oMeter:Show()
  oDEPXCONTAB:oMeter:SetTotal(LEN(aData))

  FOR I=1 TO LEN(aData)

      oDEPXCONTAB:oMeter:Set(I)
 
      cCodigo:=aData[I,1]
      dFecha :=aData[I,3]

      EJECUTAR("DPACTCONTAB", oDEPXCONTAB:cNumero,oDp:cSucursal,;
                              cCodigo,;
                              dFecha,dFecha,.F.)

   NEXT I


  oDEPXCONTAB:BRWREFRESCAR()

  oDEPXCONTAB:oSayProgress:Hide()
  oDEPXCONTAB:oMeter:Hide()

  oDEPXCONTAB:oSay:Show()
  oDEPXCONTAB:oNumero:Show()

  oDEPXCONTAB:BRWREFRESCAR()

RETURN .T.

FUNCTION VERCBTE()
  LOCAL aLine  :=oDEPXCONTAB:oBrw:aArrayData[oDEPXCONTAB:oBrw:nArrayAt]
  LOCAL cNumero:=aLine[6]
  LOCAL cActual:=aLine[9]
  LOCAL dFecha :=aLine[3]
  LOCAL lView,cScope

  IF !Empty(cNumero)
    EJECUTAR("DPCBTE",cActual,cNumero,dFecha,lView,cScope)
  ENDIF

RETURN .T.

FUNCTION DPACTIVOS()
  LOCAL aLine  :=oDEPXCONTAB:oBrw:aArrayData[oDEPXCONTAB:oBrw:nArrayAt]
  LOCAL cCodigo:=aLine[1]
  
  IF !Empty(cCodigo)
     EJECUTAR("DPACTIVOS",0,cCodigo)
  ENDIF

RETURN .T.

FUNCTION VERACTIVOS()
  LOCAL aLine  :=oDEPXCONTAB:oBrw:aArrayData[oDEPXCONTAB:oBrw:nArrayAt]
  LOCAL cCodigo:=aLine[1]
  
  IF !Empty(cCodigo)
     EJECUTAR("DPACTIVOCON",NIL,cCodigo)
  ENDIF

RETURN .T.

FUNCTION DPDEPREC()
  LOCAL aLine  :=oDEPXCONTAB:oBrw:aArrayData[oDEPXCONTAB:oBrw:nArrayAt]
  LOCAL cCodigo:=aLine[1]

  IF !Empty(cCodigo)
    EJECUTAR("DPDEPREC",NIL,cCodigo,.F.,"DEP_FECHA"+GetWhere("=",aLine[3]))
  ENDIF

RETURN .T.




 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oDEPXCONTAB)
// EOF