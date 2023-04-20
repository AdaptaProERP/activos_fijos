// Programa   : BRGRUACTSINCTA
// Fecha/Hora : 11/03/2017 10:35:48
// Propósito  : "Grupo de Activos sin Cuentas Contables"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)
   LOCAL aData,aFechas,cFileMem:="USER\BRGRUACTSINCTA.MEM",V_nPeriodo:=4,cCodPar
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


   cTitle:="Grupo de Activos sin Cuentas Contables" +IF(Empty(cTitle),"",cTitle)

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

   oDp:oFrm:=oGRUACTSINCTA
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oGRUACTSINCTA","BRGRUACTSINCTA.EDT")
   oGRUACTSINCTA:Windows(0,0,aCoors[3]-160,MIN(700,aCoors[4]-10),.T.) // Maximizado

/*
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DPEDIT():New(cTitle,"BRGRUACTSINCTA.EDT","oGRUACTSINCTA",.F.)
   oGRUACTSINCTA:CreateWindow(NIL,NIL,NIL,550,504+58)
*/
   oGRUACTSINCTA:cCodSuc  :=cCodSuc
   oGRUACTSINCTA:lMsgBar  :=.F.
   oGRUACTSINCTA:cPeriodo :=aPeriodos[nPeriodo]
   oGRUACTSINCTA:cCodSuc  :=cCodSuc
   oGRUACTSINCTA:nPeriodo :=nPeriodo
   oGRUACTSINCTA:cNombre  :=""
   oGRUACTSINCTA:dDesde   :=dDesde
   oGRUACTSINCTA:cServer  :=cServer
   oGRUACTSINCTA:dHasta   :=dHasta
   oGRUACTSINCTA:cWhere   :=cWhere
   oGRUACTSINCTA:cWhere_  :=cWhere_
   oGRUACTSINCTA:cWhereQry:=""
   oGRUACTSINCTA:cSql     :=oDp:cSql
   oGRUACTSINCTA:oWhere   :=TWHERE():New(oGRUACTSINCTA)
   oGRUACTSINCTA:cCodPar  :=cCodPar // Código del Parámetro
   oGRUACTSINCTA:lWhen    :=.T.
   oGRUACTSINCTA:cTextTit :="" // Texto del Titulo Heredado
    oGRUACTSINCTA:oDb     :=oDp:oDb
   oGRUACTSINCTA:cBrwCod  :="GRUACTSINCTA"
   oGRUACTSINCTA:lTmdi    :=.F.

   oGRUACTSINCTA:oBrw:=TXBrowse():New( IF(oGRUACTSINCTA:lTmdi,oGRUACTSINCTA:oWnd,oGRUACTSINCTA:oDlg ))
   oGRUACTSINCTA:oBrw:SetArray( aData, .F. )
   oGRUACTSINCTA:oBrw:SetFont(oFont)

   oGRUACTSINCTA:oBrw:lFooter     := .T.
   oGRUACTSINCTA:oBrw:lHScroll    := .F.
   oGRUACTSINCTA:oBrw:nHeaderLines:= 2
   oGRUACTSINCTA:oBrw:nDataLines  := 1
   oGRUACTSINCTA:oBrw:nFooterLines:= 1


   oGRUACTSINCTA:aData            :=ACLONE(aData)
  oGRUACTSINCTA:nClrText :=0
  oGRUACTSINCTA:nClrPane1:=16773345
  oGRUACTSINCTA:nClrPane2:=16769217

   AEVAL(oGRUACTSINCTA:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})
   

  oCol:=oGRUACTSINCTA:oBrw:aCols[1]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oGRUACTSINCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 64

  oCol:=oGRUACTSINCTA:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oGRUACTSINCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 280

  oCol:=oGRUACTSINCTA:oBrw:aCols[3]
  oCol:cHeader      :='V/Util'+CRLF+'Años'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oGRUACTSINCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oGRUACTSINCTA:oBrw:aArrayData[oGRUACTSINCTA:oBrw:nArrayAt,3],FDP(nMonto,'99')}
   oCol:cFooter      :=FDP(aTotal[3],'99')


  oCol:=oGRUACTSINCTA:oBrw:aCols[4]
  oCol:cHeader      :='V/Util'+CRLF+'Meses'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oGRUACTSINCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oGRUACTSINCTA:oBrw:aArrayData[oGRUACTSINCTA:oBrw:nArrayAt,4],FDP(nMonto,'99')}
   oCol:cFooter      :=FDP(aTotal[4],'99')


  oCol:=oGRUACTSINCTA:oBrw:aCols[5]
  oCol:cHeader      :='Cta.'+CRLF+'Fija'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oGRUACTSINCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:AddBmpFile("BITMAPS\ledverde.bmp") 
  oCol:AddBmpFile("BITMAPS\ledrojo.bmp") 
  oCol:bBmpData    := { ||oBrw:=oGRUACTSINCTA:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,5],1,2) }
  oCol:bStrData    :={||""}

  oCol:=oGRUACTSINCTA:oBrw:aCols[6]
  oCol:cHeader      :='Cant.'+CRLF+'Activos'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oGRUACTSINCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 40
  oCol:nDataStrAlign:= AL_RIGHT 
  oCol:nHeadStrAlign:= AL_RIGHT 
  oCol:nFootStrAlign:= AL_RIGHT 
  oCol:bStrData:={|nMonto|nMonto:= oGRUACTSINCTA:oBrw:aArrayData[oGRUACTSINCTA:oBrw:nArrayAt,6],FDP(nMonto,'9999')}
   oCol:cFooter      :=FDP(aTotal[6],'9999')


   oGRUACTSINCTA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oGRUACTSINCTA:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oGRUACTSINCTA:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oGRUACTSINCTA:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0,oMdi:nClrPane1,oMdi:nClrPane2 ) } }

   oGRUACTSINCTA:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oGRUACTSINCTA:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oGRUACTSINCTA:oBrw:bLDblClick:={|oBrw|oGRUACTSINCTA:RUNCLICK() }

   oGRUACTSINCTA:oBrw:bChange:={||oGRUACTSINCTA:BRWCHANGE()}
   oGRUACTSINCTA:oBrw:CreateFromCode()
    oGRUACTSINCTA:bValid   :={|| EJECUTAR("BRWSAVEPAR",oGRUACTSINCTA)}
    oGRUACTSINCTA:BRWRESTOREPAR()
    oGRUACTSINCTA:bValid   :={|| EJECUTAR("BRWSAVEPAR",oGRUACTSINCTA)}
    oGRUACTSINCTA:BRWRESTOREPAR()
    oGRUACTSINCTA:bValid   :={|| EJECUTAR("BRWSAVEPAR",oGRUACTSINCTA)}
    oGRUACTSINCTA:BRWRESTOREPAR()
    oGRUACTSINCTA:bValid   :={|| EJECUTAR("BRWSAVEPAR",oGRUACTSINCTA)}
    oGRUACTSINCTA:BRWRESTOREPAR()
    oGRUACTSINCTA:bValid   :={|| EJECUTAR("BRWSAVEPAR",oGRUACTSINCTA)}
    oGRUACTSINCTA:BRWRESTOREPAR()
    oGRUACTSINCTA:bValid   :={|| EJECUTAR("BRWSAVEPAR",oGRUACTSINCTA)}
    oGRUACTSINCTA:BRWRESTOREPAR()
    oGRUACTSINCTA:bValid   :={|| EJECUTAR("BRWSAVEPAR",oGRUACTSINCTA)}
    oGRUACTSINCTABRWRESTOREPAR()

   oGRUACTSINCTA:oWnd:oClient := oGRUACTSINCTA:oBrw


   oGRUACTSINCTA:Activate({||oGRUACTSINCTA:ViewDatBar()})


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oGRUACTSINCTA:lTmdi,oGRUACTSINCTA:oWnd,oGRUACTSINCTA:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oGRUACTSINCTA:oBrw:nWidth()

   oGRUACTSINCTA:oBrw:GoBottom(.T.)
   oGRUACTSINCTA:oBrw:Refresh(.T.)

   IF !File("FORMS\BRGRUACTSINCTA.EDT")
     oGRUACTSINCTA:oBrw:Move(44,0,504+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD

   // Emanager no Incluye consulta de Vinculos

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\XEDIT.BMP",NIL,"BITMAPS\XEDITG.BMP";
         ACTION EJECUTAR("DPGRUACTIVOS",3,oGRUACTSINCTA:oBrw:aArrayData[oGRUACTSINCTA:oBrw:nArrayAt,1]);
         WHEN ISTABMOD("DPGRUACTIVOS_CTA") .AND. !Empty(oGRUACTSINCTA:oBrw:aArrayData[1,1])

  oBtn:cToolTip:="Modificar Registro"

  
/*
   IF Empty(oGRUACTSINCTA:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","GRUACTSINCTA")))
*/


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XBROWSE.BMP";
          ACTION oGRUACTSINCTA:VERACTIVOS()

   oBtn:cToolTip:="Visualizar Activos"
   oGRUACTSINCTA:oBtnRun:=oBtn

   oGRUACTSINCTA:oBrw:bLDblClick:={||EVAL(oGRUACTSINCTA:oBtnRun:bAction) }
 

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oGRUACTSINCTA:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oGRUACTSINCTA:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oGRUACTSINCTA:oBrw);
          WHEN LEN(oGRUACTSINCTA:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"



IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\REFRESH.BMP";
          ACTION oGRUACTSINCTA:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oGRUACTSINCTA)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"


IF nWidth>400

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oGRUACTSINCTA:oBrw,oGRUACTSINCTA:cTitle,oGRUACTSINCTA:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oGRUACTSINCTA:oBtnXls:=oBtn

ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oGRUACTSINCTA:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oGRUACTSINCTA:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oGRUACTSINCTA:oBrw))

   oBtn:cToolTip:="Previsualización"

   oGRUACTSINCTA:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRGRUACTSINCTA")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oGRUACTSINCTA:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oGRUACTSINCTA:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oGRUACTSINCTA:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oGRUACTSINCTA:oBrw:GoTop(),oGRUACTSINCTA:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oGRUACTSINCTA:oBrw:PageDown(),oGRUACTSINCTA:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oGRUACTSINCTA:oBrw:PageUp(),oGRUACTSINCTA:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oGRUACTSINCTA:oBrw:GoBottom(),oGRUACTSINCTA:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oGRUACTSINCTA:Close()

  oGRUACTSINCTA:oBrw:SetColor(0,15790320)

  EVAL(oGRUACTSINCTA:oBrw:bChange)
 
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oGRUACTSINCTA:oBar:=oBar

  

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

  oRep:=REPORTE("BRGRUACTSINCTA",cWhere)
  oRep:cSql  :=oGRUACTSINCTA:cSql
  oRep:cTitle:=oGRUACTSINCTA:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oGRUACTSINCTA:oPeriodo:nAt,cWhere

  oGRUACTSINCTA:nPeriodo:=nPeriodo


  IF oGRUACTSINCTA:oPeriodo:nAt=LEN(oGRUACTSINCTA:oPeriodo:aItems)

     oGRUACTSINCTA:oDesde:ForWhen(.T.)
     oGRUACTSINCTA:oHasta:ForWhen(.T.)
     oGRUACTSINCTA:oBtn  :ForWhen(.T.)

     DPFOCUS(oGRUACTSINCTA:oDesde)

  ELSE

     oGRUACTSINCTA:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oGRUACTSINCTA:oDesde:VarPut(oGRUACTSINCTA:aFechas[1] , .T. )
     oGRUACTSINCTA:oHasta:VarPut(oGRUACTSINCTA:aFechas[2] , .T. )

     oGRUACTSINCTA:dDesde:=oGRUACTSINCTA:aFechas[1]
     oGRUACTSINCTA:dHasta:=oGRUACTSINCTA:aFechas[2]

     cWhere:=oGRUACTSINCTA:HACERWHERE(oGRUACTSINCTA:dDesde,oGRUACTSINCTA:dHasta,oGRUACTSINCTA:cWhere,.T.)

     oGRUACTSINCTA:LEERDATA(cWhere,oGRUACTSINCTA:oBrw,oGRUACTSINCTA:cServer)

  ENDIF

  oGRUACTSINCTA:SAVEPERIODO()

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

     IF !Empty(oGRUACTSINCTA:cWhereQry)
       cWhere:=cWhere + oGRUACTSINCTA:cWhereQry
     ENDIF

     oGRUACTSINCTA:LEERDATA(cWhere,oGRUACTSINCTA:oBrw,oGRUACTSINCTA:cServer)

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
          "  GAC_CODIGO, "+;
          "  GAC_DESCRI,"+;
          "  GAC_VUTILA,"+;
          "  GAC_VUTILM,"+;
          "  GAC_CTAFIJ,"+;
          "  IF(ATV_CODGRU<>'',COUNT(*),0) AS GAC_CANTID"+;
          "  FROM VIEW_GRUACTIVOS_CTA                   "+;
          "  INNER JOIN DPGRUACTIVOS ON GAC_CODIGO=GSC_CODIGO "+;
          "  LEFT  JOIN DPACTIVOS    ON GAC_CODIGO=ATV_CODGRU OR ATV_CODGRU IS NULL"+;
          "  WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" GAC_ACTIVO=1"+;
          "  ORDER BY GAC_CODIGO"+;
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
//    AADD(aData,{'','',0,0,0,0})
   ENDIF

   IF ValType(oBrw)="O"

      oGRUACTSINCTA:cSql   :=cSql
      oGRUACTSINCTA:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      
      oCol:=oGRUACTSINCTA:oBrw:aCols[3]
         oCol:cFooter      :=FDP(aTotal[3],'99')
      oCol:=oGRUACTSINCTA:oBrw:aCols[4]
         oCol:cFooter      :=FDP(aTotal[4],'99')
      oCol:=oGRUACTSINCTA:oBrw:aCols[6]
         oCol:cFooter      :=FDP(aTotal[6],'9999')

      oGRUACTSINCTA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oGRUACTSINCTA:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oGRUACTSINCTA:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRGRUACTSINCTA.MEM",V_nPeriodo:=oGRUACTSINCTA:nPeriodo
  LOCAL V_dDesde:=oGRUACTSINCTA:dDesde
  LOCAL V_dHasta:=oGRUACTSINCTA:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oGRUACTSINCTA)
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


    IF Type("oGRUACTSINCTA")="O" .AND. oGRUACTSINCTA:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty("oGRUACTSINCTA":cWhere_),"oGRUACTSINCTA":cWhere_,"oGRUACTSINCTA":cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oGRUACTSINCTA:LEERDATA(oGRUACTSINCTA:cWhere_,oGRUACTSINCTA:oBrw,oGRUACTSINCTA:cServer)
      oGRUACTSINCTA:oWnd:Show()
      oGRUACTSINCTA:oWnd:Maximize()

    ENDIF

RETURN NIL

FUNCTION VERACTIVOS()
    LOCAL cWhere:="ATV_CODGRU"+GetWhere("=",oGRUACTSINCTA:oBrw:aArrayData[oGRUACTSINCTA:oBrw:nArrayAt,1])
    LOCAL cCodSuc,nPeriodo,dDesde,dHasta
    LOCAL cTitle:=" [ Grupo "+ALLTRIM(oGRUACTSINCTA:oBrw:aArrayData[oGRUACTSINCTA:oBrw:nArrayAt,1])+"/"+;
                   ALLTRIM(oGRUACTSINCTA:oBrw:aArrayData[oGRUACTSINCTA:oBrw:nArrayAt,1])+" ]"

    EJECUTAR("BRACTIVOSSINCTA",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)

RETURN .T.

/*
// Genera Correspondencia Masiva
*/




 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oGRUACTSINCTA)
// EOF