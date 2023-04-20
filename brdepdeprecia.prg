// Programa   : BRDEPDEPRECIA
// Fecha/Hora : 20/08/2018 12:24:00
// Propósito  : "Depuración de Pre-Reconversión Depreciación de Activos"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRDEPDEPRECIA.MEM",V_nPeriodo:=4,cCodPar
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


   cTitle:="Depuración de Pre-Reconversión Depreciación de Activos" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oDEPDEPRECIA
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD


   DpMdi(cTitle,"oDEPDEPRECIA","BRDEPDEPRECIA.EDT")


// oDEPDEPRECIA:CreateWindow(0,0,100,550)
   oDEPDEPRECIA:Windows(0,0,aCoors[3]-160,aCoors[4]-10,.T.) // Maximizado



   oDEPDEPRECIA:cCodSuc  :=cCodSuc
   oDEPDEPRECIA:lMsgBar  :=.F.
   oDEPDEPRECIA:cPeriodo :=aPeriodos[nPeriodo]
   oDEPDEPRECIA:cCodSuc  :=cCodSuc
   oDEPDEPRECIA:nPeriodo :=nPeriodo
   oDEPDEPRECIA:cNombre  :=""
   oDEPDEPRECIA:dDesde   :=dDesde
   oDEPDEPRECIA:cServer  :=cServer
   oDEPDEPRECIA:dHasta   :=dHasta
   oDEPDEPRECIA:cWhere   :=cWhere
   oDEPDEPRECIA:cWhere_  :=cWhere_
   oDEPDEPRECIA:cWhereQry:=""
   oDEPDEPRECIA:cSql     :=oDp:cSql
   oDEPDEPRECIA:oWhere   :=TWHERE():New(oDEPDEPRECIA)
   oDEPDEPRECIA:cCodPar  :=cCodPar // Código del Parámetro
   oDEPDEPRECIA:lWhen    :=.T.
   oDEPDEPRECIA:cTextTit :="" // Texto del Titulo Heredado
   oDEPDEPRECIA:oDb      :=oDp:oDb
   oDEPDEPRECIA:cBrwCod  :="DEPDEPRECIA"
   oDEPDEPRECIA:lTmdi    :=.T.
   oDEPDEPRECIA:cDb      :=IF(!Empty(oDp:cDbDepura),oDp:cDbDepura,oDp:cDsnData)

   oDEPDEPRECIA:oBrw:=TXBrowse():New( IF(oDEPDEPRECIA:lTmdi,oDEPDEPRECIA:oWnd,oDEPDEPRECIA:oDlg ))
   oDEPDEPRECIA:oBrw:SetArray( aData, .F. )
   oDEPDEPRECIA:oBrw:SetFont(oFont)

   oDEPDEPRECIA:oBrw:lFooter     := .T.
   oDEPDEPRECIA:oBrw:lHScroll    := .F.
   oDEPDEPRECIA:oBrw:nHeaderLines:= 2
   oDEPDEPRECIA:oBrw:nDataLines  := 1
   oDEPDEPRECIA:oBrw:nFooterLines:= 1




   oDEPDEPRECIA:aData            :=ACLONE(aData)
  oDEPDEPRECIA:nClrText :=0
  oDEPDEPRECIA:nClrPane1:=16771797
  oDEPDEPRECIA:nClrPane2:=16768959

   AEVAL(oDEPDEPRECIA:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   

  oCol:=oDEPDEPRECIA:oBrw:aCols[1]
  oCol:cHeader      :='Cód.'+CRLF+'Suc'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPDEPRECIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 48

  oCol:=oDEPDEPRECIA:oBrw:aCols[2]
  oCol:cHeader      :='Código de Activo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPDEPRECIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 120

  oCol:=oDEPDEPRECIA:oBrw:aCols[3]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPDEPRECIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 400

  oCol:=oDEPDEPRECIA:oBrw:aCols[4]
  oCol:cHeader      :='Desde'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPDEPRECIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oDEPDEPRECIA:oBrw:aCols[5]
  oCol:cHeader      :='Hasta'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPDEPRECIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 70

  oCol:=oDEPDEPRECIA:oBrw:aCols[6]
  oCol:cHeader      :='Deprec.'+CRLF+'Acumulado'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPDEPRECIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oDEPDEPRECIA:oBrw:aArrayData[oDEPDEPRECIA:oBrw:nArrayAt,6],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[6],'999,999,999.99')


  oCol:=oDEPDEPRECIA:oBrw:aCols[7]
  oCol:cHeader      :='Deprec'+CRLF+'Reconvertida'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPDEPRECIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 120
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oDEPDEPRECIA:oBrw:aArrayData[oDEPDEPRECIA:oBrw:nArrayAt,7],FDP(nMonto,'999,999,999.99')}
   oCol:cFooter      :=FDP(aTotal[7],'999,999,999.99')


  oCol:=oDEPDEPRECIA:oBrw:aCols[8]
  oCol:cHeader      :='Cant'+CRLF+"Reg."
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDEPDEPRECIA:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oDEPDEPRECIA:oBrw:aArrayData[oDEPDEPRECIA:oBrw:nArrayAt,8],FDP(nMonto,'999,999,999')}
  oCol:cFooter      :=FDP(aTotal[8],'999,999,999')



  oCol:=oDEPDEPRECIA:oBrw:aCols[9]
  oCol:cHeader      := "Ok."
  oCol:nWidth       := 40
  oCol:AddBmpFile("BITMAPS\ledverde.bmp")
  oCol:AddBmpFile("BITMAPS\ledrojo.bmp")
  oCol:bBmpData    := { ||oBrw:=oDEPDEPRECIA:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,9],1,2) }
  oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
  oCol:bStrData    :={||""}

   oDEPDEPRECIA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oDEPDEPRECIA:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oDEPDEPRECIA:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oDEPDEPRECIA:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oDEPDEPRECIA:nClrPane1, oDEPDEPRECIA:nClrPane2 ) } }

   oDEPDEPRECIA:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oDEPDEPRECIA:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oDEPDEPRECIA:oBrw:bLDblClick:={|oBrw|oDEPDEPRECIA:RUNCLICK() }

   oDEPDEPRECIA:oBrw:bChange:={||oDEPDEPRECIA:BRWCHANGE()}
   oDEPDEPRECIA:oBrw:CreateFromCode()
    oDEPDEPRECIA:bValid   :={|| EJECUTAR("BRWSAVEPAR",oDEPDEPRECIA)}
    oDEPDEPRECIA:BRWRESTOREPAR()


   oDEPDEPRECIA:oWnd:oClient := oDEPDEPRECIA:oBrw


   oDEPDEPRECIA:Activate({||oDEPDEPRECIA:ViewDatBar()})


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oDEPDEPRECIA:lTmdi,oDEPDEPRECIA:oWnd,oDEPDEPRECIA:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oDEPDEPRECIA:oBrw:nWidth()

   oDEPDEPRECIA:oBrw:GoBottom(.T.)
   oDEPDEPRECIA:oBrw:Refresh(.T.)

   IF !File("FORMS\BRDEPDEPRECIA.EDT")
     oDEPDEPRECIA:oBrw:Move(44,0,850+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD




 // Emanager no Incluye consulta de Vinculos

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\ACTIVOS.BMP";
          ACTION EJECUTAR("DPACTIVOS",2,oDEPDEPRECIA:oBrw:aArrayData[oDEPDEPRECIA:oBrw:nArrayAt,2])
*/

/*
 DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("DPDEPREC",oDEPDEPRECIA:oBrw:aArrayData[oDEPDEPRECIA:oBrw:nArrayAt,1],oDEPDEPRECIA:oBrw:aArrayData[oDEPDEPRECIA:oBrw:nArrayAt,2],.F.,oDEPDEPRECIA:cDb)
*/
  
/*
   IF Empty(oDEPDEPRECIA:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","DEPDEPRECIA")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","DEPDEPRECIA"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oDEPDEPRECIA:oBrw,"DEPDEPRECIA",oDEPDEPRECIA:cSql,oDEPDEPRECIA:nPeriodo,oDEPDEPRECIA:dDesde,oDEPDEPRECIA:dHasta,oDEPDEPRECIA)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oDEPDEPRECIA:oBtnRun:=oBtn



       oDEPDEPRECIA:oBrw:bLDblClick:={||EVAL(oDEPDEPRECIA:oBtnRun:bAction) }


   ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XDELETE.BMP";
          ACTION oDEPDEPRECIA:DEPCELIMINAR()

   oBtn:cToolTip:="Depurar Registros"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oDEPDEPRECIA:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oDEPDEPRECIA:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oDEPDEPRECIA:oBrw);
          WHEN LEN(oDEPDEPRECIA:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"



IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oDEPDEPRECIA:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"
ENDIF
/*

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oDEPDEPRECIA)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"
*/

IF nWidth>400 .OR. .T.

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oDEPDEPRECIA:oBrw,oDEPDEPRECIA:cTitle,oDEPDEPRECIA:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oDEPDEPRECIA:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oDEPDEPRECIA:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oDEPDEPRECIA:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oDEPDEPRECIA:oBrw))

   oBtn:cToolTip:="Previsualización"

   oDEPDEPRECIA:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRDEPDEPRECIA")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oDEPDEPRECIA:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oDEPDEPRECIA:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oDEPDEPRECIA:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oDEPDEPRECIA:oBrw:GoTop(),oDEPDEPRECIA:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oDEPDEPRECIA:oBrw:PageDown(),oDEPDEPRECIA:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oDEPDEPRECIA:oBrw:PageUp(),oDEPDEPRECIA:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oDEPDEPRECIA:oBrw:GoBottom(),oDEPDEPRECIA:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oDEPDEPRECIA:Close()

  oDEPDEPRECIA:oBrw:SetColor(0,oDEPDEPRECIA:nClrPane1)

  EVAL(oDEPDEPRECIA:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oDEPDEPRECIA:oBar:=oBar

  

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

  oRep:=REPORTE("BRDEPDEPRECIA",cWhere)
  oRep:cSql  :=oDEPDEPRECIA:cSql
  oRep:cTitle:=oDEPDEPRECIA:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oDEPDEPRECIA:oPeriodo:nAt,cWhere

  oDEPDEPRECIA:nPeriodo:=nPeriodo


  IF oDEPDEPRECIA:oPeriodo:nAt=LEN(oDEPDEPRECIA:oPeriodo:aItems)

     oDEPDEPRECIA:oDesde:ForWhen(.T.)
     oDEPDEPRECIA:oHasta:ForWhen(.T.)
     oDEPDEPRECIA:oBtn  :ForWhen(.T.)

     DPFOCUS(oDEPDEPRECIA:oDesde)

  ELSE

     oDEPDEPRECIA:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oDEPDEPRECIA:oDesde:VarPut(oDEPDEPRECIA:aFechas[1] , .T. )
     oDEPDEPRECIA:oHasta:VarPut(oDEPDEPRECIA:aFechas[2] , .T. )

     oDEPDEPRECIA:dDesde:=oDEPDEPRECIA:aFechas[1]
     oDEPDEPRECIA:dHasta:=oDEPDEPRECIA:aFechas[2]

     cWhere:=oDEPDEPRECIA:HACERWHERE(oDEPDEPRECIA:dDesde,oDEPDEPRECIA:dHasta,oDEPDEPRECIA:cWhere,.T.)

     oDEPDEPRECIA:LEERDATA(cWhere,oDEPDEPRECIA:oBrw,oDEPDEPRECIA:cServer)

  ENDIF

  oDEPDEPRECIA:SAVEPERIODO()

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

     IF !Empty(oDEPDEPRECIA:cWhereQry)
       cWhere:=cWhere + oDEPDEPRECIA:cWhereQry
     ENDIF

     oDEPDEPRECIA:LEERDATA(cWhere,oDEPDEPRECIA:oBrw,oDEPDEPRECIA:cServer)

   ENDIF


RETURN cWhere


FUNCTION LEERDATA(cWhere,oBrw,cServer)
   LOCAL aData:={},aTotal:={},oCol,cSql,aLines:={}
   LOCAL cDb:=IF(!Empty(oDp:cDbDepura),oDp:cDbDepura,oDp:cDsnData),oDb,I

   DEFAULT cWhere:=""

   IF !Empty(cServer)

     IF !EJECUTAR("DPSERVERDBOPEN",cServer)
        RETURN .F.
     ENDIF

     oDb:=oDp:oDb

   ENDIF

   cSql:=" SELECT DEP_CODSUC,DEP_CODACT,ATV_DESCRI,MIN(DEP_FECHA),MAX(DEP_FECHA),SUM(DEP_MONTO),SUM(DEP_MONTO/100000) AS DEP_MTODEP ,COUNT(*),0 AS SEL "+;
         " FROM DPDEPRECIAACT "+;
         " INNER JOIN DPACTIVOS ON ATV_CODIGO=DEP_CODACT  "+;
         " WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" DEP_FECHA"+GetWhere(">=",oDp:dFchIniRm)+;
         " GROUP BY DEP_CODSUC,DEP_CODACT"+;
         ""

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.F.

   oDb:=OPENODBC(cDb)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','',CTOD(""),CTOD(""),0,0,0})
   ENDIF

   AEVAL(aData,{|a,n| aData[n,9]:=(a[8]>0)})

   IF ValType(oBrw)="O"

      oDEPDEPRECIA:cSql   :=cSql
      oDEPDEPRECIA:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oDEPDEPRECIA:oBrw:aCols[6]
      oCol:cFooter      :=FDP(aTotal[6],'999,999,999.99')
      oCol:=oDEPDEPRECIA:oBrw:aCols[7]
      oCol:cFooter      :=FDP(aTotal[7],'999,999,999.99')
      oCol:=oDEPDEPRECIA:oBrw:aCols[8]
      oCol:cFooter      :=FDP(aTotal[8],'999,999,999.99')

      oDEPDEPRECIA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oDEPDEPRECIA:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oDEPDEPRECIA:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRDEPDEPRECIA.MEM",V_nPeriodo:=oDEPDEPRECIA:nPeriodo
  LOCAL V_dDesde:=oDEPDEPRECIA:dDesde
  LOCAL V_dHasta:=oDEPDEPRECIA:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oDEPDEPRECIA)
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


    IF Type("oDEPDEPRECIA")="O" .AND. oDEPDEPRECIA:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oDEPDEPRECIA:cWhere_),oDEPDEPRECIA:cWhere_,oDEPDEPRECIA:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")

      oDEPDEPRECIA:LEERDATA(oDEPDEPRECIA:cWhere_,oDEPDEPRECIA:oBrw,oDEPDEPRECIA:cServer)
      oDEPDEPRECIA:oWnd:Show()
      oDEPDEPRECIA:oWnd:Maximize()

    ENDIF

RETURN NIL

/*
// Genera Correspondencia Masiva
*/

FUNCTION DEPCELIMINAR()
   LOCAL cWhere
   LOCAL aTotal:={}
   LOCAL aNew  :={},aData:=oDEPMOCVU:oBrw:aArrayData
   LOCAL oTableD,oTableC,oTableO,oTable,cWhereR,cTipDoc,cNumTra:="",cDocume:="",nSaldo:=0,nMtoIdb:=0
   LOCAL cWhereX,oTableX,oTableY
   LOCAL cDb:=IF(!Empty(oDp:cDbDepura),oDp:cDbDepura,oDp:cDsnData),oDb,I
   LOCAL oAsiento,oCbte,dFecha,cNumCbt,cNumEje,cWhereC
   LOCAL oCbteH,oCbte,oCbteO

   oDb:=OpenOdbc(cDb)

   AEVAL(oDEPDEPRECIA:oBrw:aArrayData,{|a,n| IF(a[9],AADD(aNew,a),NIL) })
//
// ? oDp:cDbDepura,"oDp:cDbDepura",cDb,"cDb",oDp:cCtaMod

   IF Empty(aNew)
      MensajeErr("No hay Registros Seleccionados")
      RETURN .F.
   ENDIF

   IF !MsgNoYes("Desea Depurar "+LSTR(LEN(aNew))+" Depreciación de Activos","BD "+cDb)
      RETURN .F.
   ENDIF

   IF !oDEPDEPRECIA:lChkTable .OR. !EJECUTAR("DBISTABLE",cDb,"DPDEPRECIAACT_HIS") 
 
      MsgRun("Revisando Tabla histórica para Depreciación","Procesanso",{||EJECUTAR("DPTABLEHIS","DPDEPRECIAACT",cDb)})

      oDEPDEPRECIA:lChkTable:=.T.

   ENDIF

   oTableD :=OpenTable("SELECT * FROM DPDEPRECIAACT_HIS",.F.,oDb)
// oAsiento:=OpenTable("SELECT * FROM DPDEPRECIAACT"    ,.F.,oDb)
// oCbte   :=OpenTable("SELECT * FROM DPCBTE"        ,.F.,oDb)
// oCbteH  :=OpenTable("SELECT * FROM DPCBTE_HIS"    ,.F.,oDb) // Cbte Historico

   CursorWait()

   FOR I=1 TO LEN(aNew)

       IF (I%5)=0
          SysRefresh(.T.)
       ENDIF
    

       // Todos los valores divisibles seran llevados a Cero

       cWhere:="DEP_CODSUC"+GetWhere("=",aNew[I,1])+" AND "+;
               "DEP_CODACT"+GetWhere("=",aNew[I,2])+" AND "+;
               "DEP_FECHA" +GetWhere(">=",oDp:dFchIniRm)
               "ROUND(DEP_MONTO"+GetWhere("/",oDp:nDivide)+",2)=0"

//
// Solo removera las depreciaciones entre cien mil
//
       MsgRun("Leyendo "+LSTR(I)+"/"+LSTR(LEN(aNew))+" "+aNew[I,2]+" Año "+CTOO(aNew[I,5],"C"))

       oTableO  :=OpenTable("SELECT * FROM DPDEPRECIAACT  WHERE "+cWhere ,.T.,oDb)
      
       CursorWait()

       WHILE !oTableO:Eof()

          oTableD:AppendBlank()
          oTableD:lSetFieldDef:=.F.
          AEVAL(oTableO:aFields,{|a,n| oTableD:Replace(a[1],oTableO:FieldGet(a[1]))})
          oTableD:Commit()
          oTableO:DbSkip()

       ENDDO

       // Primero elimina y luego agrega los nuevos registros, evitar autoeliminarse
       SQLDELETE("DPDEPRECIAACT",cWhere ,NIL,oDb)

/*

       // Agregamos Comprobante
       oCbte:AppendBlank()
       oCbte:Replace("CBT_CODSUC",aNew[I,1])
       oCbte:Replace("CBT_ACTUAL",aNew[I,4])
       oCbte:Replace("CBT_FECHA" ,aNew[I,7])
       oCbte:Replace("CBT_NUMEJE",cNumEje  )
       oCbte:Replace("CBT_NUMERO",cNumCbt  )
       oCbte:Replace("CBT_USUARI",oDp:cUsuario )
       oCbte:Replace("CBT_COMEN1","Resumen Depuración de Registros Divisibles/"+LSTR(oDp:nDivide))
       oCbte:Commit()

       // Agregamos Asiento Resumido
       oAsiento:AppendBlank()
       oAsiento:Replace("MOC_CODSUC",oCbte:CBT_CODSUC)
       oAsiento:Replace("MOC_CUENTA",aNew[I,2])
       oAsiento:Replace("MOC_ACTUAL",oCbte:CBT_ACTUAL)
       oAsiento:Replace("MOC_FECHA" ,aNew[I,7])
       oAsiento:Replace("MOC_NUMCBT",cNumCbt  )
       oAsiento:Replace("MOC_USUARI",oDp:cUsuario )
       oAsiento:Replace("MOC_MONTO" ,aNew[I,6])
       oAsiento:Replace("MOC_DESCRI","Resumen Depuración de Registros Divisibles/"+LSTR(oDp:nDivide))
       oAsiento:Replace("MOC_ORIGEN","DRU") // Depuracion de Registros Unitarios
       oAsiento:Replace("MOC_ITEM" ,STRZERO(1,5)) // Depuracion de Registros Unitarios
       oAsiento:Commit()

*/

       oTableO:End()
    
   NEXT I

   oTableD:End()

   oDEPDEPRECIA:BRWREFRESCAR()

RETURN .T.




 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oDEPDEPRECIA)
// EOF