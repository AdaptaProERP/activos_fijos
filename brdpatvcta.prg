// Programa   : BRDPATVCTA
// Fecha/Hora : 31/12/2018 23:37:46
// Propósito  : "Cuentas Contables por Grupo de Productos"
// Creado Por : Automáticamente por BRWMAKER
// Llamado por: <DPXBASE>
// Aplicación : Gerencia 
// Tabla      : <TABLA>

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle,lView)
   LOCAL aData,aFechas,cFileMem:="USER\BRDPGRUCTA.MEM",V_nPeriodo:=4,cCodPar
   LOCAL V_dDesde:=CTOD(""),V_dHasta:=CTOD("")
   LOCAL cServer:=oDp:cRunServer
   LOCAL lConectar:=.F.

   oDp:cRunServer:=NIL

   IF Type("oDPATVCTA")="O" .AND. oDPATVCTA:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oDPATVCTA,GetScript())
   ENDIF


   IF !Empty(cServer)

     MsgRun("Conectando con Servidor "+cServer+" ["+ALLTRIM(SQLGET("DPSERVERBD","SBD_DOMINI","SBD_CODIGO"+GetWhere("=",cServer)))+"]",;
            "Por Favor Espere",{||lConectar:=EJECUTAR("DPSERVERDBOPEN",cServer)})

     IF !lConectar
        RETURN .F.
     ENDIF

   ENDIF 

   DEFAULT cWhere:="ATV_CTAMOD"+GetWhere("=",oDp:cCtaMod)

   SQLDELETE("DPACTIVOS","ATV_CODIGO"+GetWhere("=","ATV_CODIGO")+" OR ATV_CODIGO"+GetWhere("=",""))

   cTitle:="Cuentas Contables por Propiedades, Plantas y Equipos (ACTIVOS)" +IF(Empty(cTitle),"",cTitle)

   oDp:oFrm:=NIL

   IF FILE(cFileMem) .AND. nPeriodo=NIL
      RESTORE FROM (cFileMem) ADDI
      nPeriodo:=V_nPeriodo
   ENDIF

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=4,;
           dDesde  :=CTOD(""),;
           dHasta  :=CTOD("")


   DEFAULT lView   :=.F.


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

   oDp:oFrm:=oDPATVCTA
            
RETURN .T. 


FUNCTION ViewData(aData,cTitle,cWhere_)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   DpMdi(cTitle,"oDPATVCTA","BRDPATVCTA.EDT")

   oDPATVCTA:Windows(0,0,aCoors[3]-160,aCoors[4]-10,.T.) // Maximizado

   oDPATVCTA:cCodSuc  :=cCodSuc
   oDPATVCTA:lMsgBar  :=.F.
   oDPATVCTA:cPeriodo :=aPeriodos[nPeriodo]
   oDPATVCTA:cCodSuc  :=cCodSuc
   oDPATVCTA:nPeriodo :=nPeriodo
   oDPATVCTA:cNombre  :=""
   oDPATVCTA:dDesde   :=dDesde
   oDPATVCTA:cServer  :=cServer
   oDPATVCTA:dHasta   :=dHasta
   oDPATVCTA:cWhere   :=cWhere
   oDPATVCTA:cWhere_  :=cWhere_
   oDPATVCTA:cWhereQry:=""
   oDPATVCTA:cSql     :=oDp:cSql
   oDPATVCTA:oWhere   :=TWHERE():New(oDPATVCTA)
   oDPATVCTA:cCodPar  :=cCodPar // Código del Parámetro
   oDPATVCTA:lWhen    :=.T.
   oDPATVCTA:cTextTit :="" // Texto del Titulo Heredado
   oDPATVCTA:oDb       :=oDp:oDb
   oDPATVCTA:cBrwCod  :="DPGRUCTA"
   oDPATVCTA:lTmdi    :=.T.
   oDPATVCTA:cCod2    :=""
   oDPATVCTA:aRef     :=EJECUTAR("DPATV_CTAREFCREAR",.F.)
   oDPATVCTA:cTableD  :="DPGRU_CTA"
   oDPATVCTA:cCtaDescri:=""
   oDPATVCTA:oCtaDescri:=NIL
   oDPATVCTA:nClrPane1 :=oDp:nClrPane1
   oDPATVCTA:nClrPane2 :=oDp:nClrPane2

   oDPATVCTA:oBrw:=TXBrowse():New( IF(oDPATVCTA:lTmdi,oDPATVCTA:oWnd,oDPATVCTA:oDlg ))
   oDPATVCTA:oBrw:SetArray( aData, .F. )
   oDPATVCTA:oBrw:SetFont(oFont)

   oDPATVCTA:oBrw:lFooter     := .T.
   oDPATVCTA:oBrw:lHScroll    := .T.
   oDPATVCTA:oBrw:nHeaderLines:= 2
   oDPATVCTA:oBrw:nDataLines  := 1
   oDPATVCTA:oBrw:nFooterLines:= 1

   oDPATVCTA:aData            :=ACLONE(aData)
  oDPATVCTA:nClrText :=0
  oDPATVCTA:nClrPane1:=oDp:nClrPane1
  oDPATVCTA:nClrPane2:=oDp:nClrPane2	

   AEVAL(oDPATVCTA:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

  oCol:=oDPATVCTA:oBrw:aCols[1]
  oCol:cHeader      :='Código'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDPATVCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 80

  oCol:=oDPATVCTA:oBrw:aCols[2]
  oCol:cHeader      :='Descripción'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDPATVCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 320

  oCol:=oDPATVCTA:oBrw:aCols[3]
  oCol:cHeader      :='Activo'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDPATVCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 160
  oCol:nEditType    :=IIF( lView, 0, EDIT_GET_BUTTON)
  oCol:bEditBlock   :={||oDPATVCTA:EditCta(3,.F.)}
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oDPATVCTA:ValCta(oCol,uValue,3,nKey)}
  oCol:lButton      :=.F.

  oCol:=oDPATVCTA:oBrw:aCols[4]
  oCol:cHeader      :='Depreciación'+CRLF+'Acumulada	'
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oDPATVCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 160
  oCol:nEditType    :=IIF( lView, 0, EDIT_GET_BUTTON)
  oCol:bEditBlock   :={||oDPATVCTA:EditCta(4,.F.)}
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oDPATVCTA:ValCta(oCol,uValue,4,nKey)}
  oCol:lButton      :=.F.

  oCol:=oDPATVCTA:oBrw:aCols[5]
  oCol:cHeader      :='Depreciación'+CRLF+"Gasto"
  oCol:bLClickHeader:= {|r,c,f,o| SortArray( o, oDPATVCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 160
  oCol:nEditType    :=IIF( lView, 0, EDIT_GET_BUTTON)
  oCol:bEditBlock   :={||oDPATVCTA:EditCta(5,.F.)}
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oDPATVCTA:ValCta(oCol,uValue,5,nKey)}
  oCol:lButton      :=.F.

  oCol:=oDPATVCTA:oBrw:aCols[6]
  oCol:cHeader      :='Revalorización'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDPATVCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 160
  oCol:nEditType    :=IIF( lView, 0, EDIT_GET_BUTTON)
  oCol:bEditBlock   :={||oDPATVCTA:EditCta(6,.F.)}
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oDPATVCTA:ValCta(oCol,uValue,6,nKey)}
  oCol:lButton      :=.F.
/*
  oCol:=oDPATVCTA:oBrw:aCols[7]
  oCol:cHeader      :='Compra'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDPATVCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 160
  oCol:nEditType    :=IIF( lView, 0, EDIT_GET_BUTTON)
  oCol:bEditBlock   :={||oDPATVCTA:EditCta(7,.F.)}
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oDPATVCTA:ValCta(oCol,uValue,7,nKey)}
  oCol:lButton      :=.F.
*/
/*
  oCol:=oDPATVCTA:oBrw:aCols[8]
  oCol:cHeader      :='Devolución'+CRLF+'Compra'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDPATVCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 160
  oCol:nEditType    :=IIF( lView, 0, EDIT_GET_BUTTON)
  oCol:bEditBlock   :={||oDPATVCTA:EditCta(8,.F.)}
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oDPATVCTA:ValCta(oCol,uValue,8,nKey)}
  oCol:lButton      :=.F.



  oCol:=oDPATVCTA:oBrw:aCols[9]
  oCol:cHeader      :='Inventario'+CRLF+'Inicial'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDPATVCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 160
  oCol:nEditType    :=IIF( lView, 0, EDIT_GET_BUTTON)
  oCol:bEditBlock   :={||oDPATVCTA:EditCta(9,.F.)}
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oDPATVCTA:ValCta(oCol,uValue,9,nKey)}
  oCol:lButton      :=.F.



  oCol:=oDPATVCTA:oBrw:aCols[10]
  oCol:cHeader      :='Inventario'+CRLF+'Final'
  oCol:bLClickHeader := {|r,c,f,o| SortArray( o, oDPATVCTA:oBrw:aArrayData ) } 
  oCol:nWidth       := 160
  oCol:nEditType    :=IIF( lView, 0, EDIT_GET_BUTTON)
  oCol:bEditBlock   :={||oDPATVCTA:EditCta(10,.F.)}
  oCol:bOnPostEdit  :={|oCol,uValue,nKey|oDPATVCTA:ValCta(oCol,uValue,10,nKey)}
  oCol:lButton      :=.F.
*/


   oDPATVCTA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))

   oDPATVCTA:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oDPATVCTA:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oDPATVCTA:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oDPATVCTA:nClrPane1, oDPATVCTA:nClrPane2 ) } }

   oDPATVCTA:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oDPATVCTA:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oDPATVCTA:oBrw:bLDblClick:={|oBrw|oDPATVCTA:RUNCLICK() }

   oDPATVCTA:oBrw:bChange:={||oDPATVCTA:BRWCHANGE()}
   oDPATVCTA:oBrw:CreateFromCode()
   oDPATVCTA:bValid   :={|| EJECUTAR("BRWSAVEPAR",oDPATVCTA)}
   oDPATVCTA:BRWRESTOREPAR()

   oDPATVCTA:oWnd:oClient := oDPATVCTA:oBrw

   oDPATVCTA:Activate({||oDPATVCTA:ViewDatBar()})


RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=IF(oDPATVCTA:lTmdi,oDPATVCTA:oWnd,oDPATVCTA:oDlg)
   LOCAL nLin:=0
   LOCAL nWidth:=oDPATVCTA:oBrw:nWidth()

   oDPATVCTA:oBrw:GoBottom(.T.)
   oDPATVCTA:oBrw:Refresh(.T.)

   IF !File("FORMS\BRDPGRUCTA.EDT")
     oDPATVCTA:oBrw:Move(44,0,850+50,460)
   ENDIF

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -14 BOLD

 // Emanager no Incluye consulta de Vinculos

  DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\contabilidad.BMP";
         ACTION oDPATVCTA:VERCUENTA()

   oBtn:cToolTip:="Consultar Vinculos"


 DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\ACTIVOS.BMP";
         ACTION EJECUTAR("DPACTIVOS",3,oDPATVCTA:oBrw:aArrayData[oDPATVCTA:oBrw:nArrayAt,1])

   oBtn:cToolTip:="Modificar Grupo"



   DEFINE BUTTON oBtn;
         OF oBar;
         NOBORDER;
         FONT oFont;
         FILENAME "BITMAPS\UPLOAD.BMP";
         ACTION oDPATVCTA:CTA_UPLOAD()

   oBtn:cToolTip:="Subir Hacia AdaptaPro Server"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\DOWNLOAD.BMP";
          ACTION oDPATVCTA:CTA_DOWNLOAD()

  oBtn:cToolTip:="Descargar desde AdaptaPro Server"

  
/*
   IF Empty(oDPATVCTA:cServer) .AND. !Empty(SQLGET("DPBRWLNK","EBR_CODIGO","EBR_CODIGO"+GetWhere("=","DPGRUCTA")))
*/

   IF ISSQLFIND("DPBRWLNKCONCAT","BRC_CODIGO"+GetWhere("=","DPGRUCTA"))

       DEFINE BUTTON oBtn;
       OF oBar;
       NOBORDER;
       FONT oFont;
       FILENAME "BITMAPS\XBROWSE.BMP";
       ACTION EJECUTAR("BRWRUNBRWLINK",oDPATVCTA:oBrw,"DPGRUCTA",oDPATVCTA:cSql,oDPATVCTA:nPeriodo,oDPATVCTA:dDesde,oDPATVCTA:dHasta,oDPATVCTA)

       oBtn:cToolTip:="Ejecutar Browse Vinculado(s)"
       oDPATVCTA:oBtnRun:=oBtn



       oDPATVCTA:oBrw:bLDblClick:={||EVAL(oDPATVCTA:oBtnRun:bAction) }


   ENDIF



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XFIND.BMP";
          ACTION EJECUTAR("BRWSETFIND",oDPATVCTA:oBrw)

   oBtn:cToolTip:="Buscar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oDPATVCTA:oBrw,oDPATVCTA);
          ACTION EJECUTAR("BRWSETFILTER",oDPATVCTA:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oDPATVCTA:oBrw);
          WHEN LEN(oDPATVCTA:oBrw:aArrayData)>1

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
          ACTION oDPATVCTA:BRWREFRESCAR()

   oBtn:cToolTip:="Refrescar"

ENDIF

/*

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\CRYSTAL.BMP";
          ACTION EJECUTAR("BRWTODBF",oDPATVCTA)

   oBtn:cToolTip:="Visualizar Mediante Crystal Report"
*/

// IF nWidth>400

 
     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\EXCEL.BMP";
            ACTION (EJECUTAR("BRWTOEXCEL",oDPATVCTA:oBrw,oDPATVCTA:cTitle,oDPATVCTA:cNombre))

     oBtn:cToolTip:="Exportar hacia Excel"

     oDPATVCTA:oBtnXls:=oBtn

// ENDIF

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oDPATVCTA:HTMLHEAD(),EJECUTAR("BRWTOHTML",oDPATVCTA:oBrw,NIL,oDPATVCTA:cTitle,oDPATVCTA:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oDPATVCTA:oBtnHtml:=oBtn

IF nWidth>300

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PREVIEW.BMP";
          ACTION (EJECUTAR("BRWPREVIEW",oDPATVCTA:oBrw))

   oBtn:cToolTip:="Previsualización"

   oDPATVCTA:oBtnPreview:=oBtn

ENDIF

   IF ISSQLGET("DPREPORTES","REP_CODIGO","BRDPGRUCTA")

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XPRINT.BMP";
            ACTION oDPATVCTA:IMPRIMIR()

      oBtn:cToolTip:="Imprimir"

     oDPATVCTA:oBtnPrint:=oBtn

   ENDIF

IF nWidth>700


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\QUERY.BMP";
          ACTION oDPATVCTA:BRWQUERY()

   oBtn:cToolTip:="Imprimir"

ENDIF




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oDPATVCTA:oBrw:GoTop(),oDPATVCTA:oBrw:Setfocus())

IF nWidth>800 .OR. nWidth=0

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oDPATVCTA:oBrw:PageDown(),oDPATVCTA:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oDPATVCTA:oBrw:PageUp(),oDPATVCTA:oBrw:Setfocus())

ENDIF


  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oDPATVCTA:oBrw:GoBottom(),oDPATVCTA:oBrw:Setfocus())



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oDPATVCTA:Close()

  oDPATVCTA:oBrw:SetColor(0,oDPATVCTA:nClrPane1)

 
   
  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oDPATVCTA:oBar:=oBar

  nLin:=32
  AEVAL(oBar:aControls,{|o,n|nLin:=nLin+o:nWidth() })

  @ 0,nLin+032 SAY "Cuenta "                                        OF oBar;
               BORDER SIZE 100,20 PIXEL BORDER COLOR oDp:nClrLabelText,oDp:nClrLabelPane FONT oFont RIGHT

  @ 0,nLin+132 SAY oDPATVCTA:oCtaDescri PROMPT oDPATVCTA:cCtaDescri OF oBar;
               BORDER SIZE 300,20 PIXEL BORDER COLOR oDp:nClrYellowText,oDp:nClrYellow   FONT oFont

  oDPATVCTA:oBrw:nColSel:=3
  EVAL(oDPATVCTA:oBrw:bChange)

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

  oRep:=REPORTE("BRDPGRUCTA",cWhere)
  oRep:cSql  :=oDPATVCTA:cSql
  oRep:cTitle:=oDPATVCTA:cTitle

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oDPATVCTA:oPeriodo:nAt,cWhere

  oDPATVCTA:nPeriodo:=nPeriodo


  IF oDPATVCTA:oPeriodo:nAt=LEN(oDPATVCTA:oPeriodo:aItems)

     oDPATVCTA:oDesde:ForWhen(.T.)
     oDPATVCTA:oHasta:ForWhen(.T.)
     oDPATVCTA:oBtn  :ForWhen(.T.)

     DPFOCUS(oDPATVCTA:oDesde)

  ELSE

     oDPATVCTA:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oDPATVCTA:oDesde:VarPut(oDPATVCTA:aFechas[1] , .T. )
     oDPATVCTA:oHasta:VarPut(oDPATVCTA:aFechas[2] , .T. )

     oDPATVCTA:dDesde:=oDPATVCTA:aFechas[1]
     oDPATVCTA:dHasta:=oDPATVCTA:aFechas[2]

     cWhere:=oDPATVCTA:HACERWHERE(oDPATVCTA:dDesde,oDPATVCTA:dHasta,oDPATVCTA:cWhere,.T.)

     oDPATVCTA:LEERDATA(cWhere,oDPATVCTA:oBrw,oDPATVCTA:cServer)

  ENDIF

  oDPATVCTA:SAVEPERIODO()

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

     IF !Empty(oDPATVCTA:cWhereQry)
       cWhere:=cWhere + oDPATVCTA:cWhereQry
     ENDIF

     oDPATVCTA:LEERDATA(cWhere,oDPATVCTA:oBrw,oDPATVCTA:cServer)

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
          " ATV_CODIGO,"+;
          " ATV_DESCRI,"+;
          " ATV_CTAACT,"+;
          " ATV_CTAACU,"+;
          " ATV_CTADEP,"+;
          " ATV_CTAREV "+;
          " FROM VIEW_DPACTIVOSCTA "+;
          " WHERE "+cWhere+IIF(Empty(cWhere),""," AND ")+" 1=1"+;
          " GROUP BY ATV_CODIGO "+;
          " ORDER BY ATV_CODIGO "+;
          ""

   IF Empty(cWhere)
     cSql:=STRTRAN(cSql,"<WHERE>","")
   ELSE
     cSql:=STRTRAN(cSql,"<WHERE>"," WHERE "+cWhere)
   ENDIF

   cSql:=EJECUTAR("WHERE_VAR",cSql)

   oDp:lExcluye:=.T.

   DPWRITE("TEMP\BRDPGRUCTA.SQL",cSql)

   aData:=ASQL(cSql,oDb)

   oDp:cWhere:=cWhere


   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
//    AADD(aData,{'','','','','','','','','',''})
   ENDIF

   IF ValType(oBrw)="O"

      oDPATVCTA:cSql   :=cSql
      oDPATVCTA:cWhere_:=cWhere

      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      

      oDPATVCTA:oBrw:aCols[1]:cFooter:=" #"+LSTR(LEN(aData))
   
      oBrw:Refresh(.T.)
      AEVAL(oDPATVCTA:oBar:aControls,{|o,n| o:ForWhen(.T.)})

      oDPATVCTA:SAVEPERIODO()

   ENDIF

RETURN aData


FUNCTION SAVEPERIODO()
  LOCAL cFileMem:="USER\BRDPGRUCTA.MEM",V_nPeriodo:=oDPATVCTA:nPeriodo
  LOCAL V_dDesde:=oDPATVCTA:dDesde
  LOCAL V_dHasta:=oDPATVCTA:dHasta

  SAVE TO (cFileMem) ALL LIKE "V_*"

RETURN .T.

/*
// Permite Crear Filtros para las Búquedas
*/
FUNCTION BRWQUERY()
     EJECUTAR("BRWQUERY",oDPATVCTA)
RETURN .T.

/*
// Ejecución Cambio de Linea 
*/
FUNCTION BRWCHANGE()
   LOCAL cCodCta:=oDPATVCTA:oBrw:aArrayData[oDPATVCTA:oBrw:nArrayAt,oDPATVCTA:oBrw:nColSel]

   IF !oDPATVCTA:oCtaDescri=NIL .AND. oDPATVCTA:oBrw:nColSel>2
      cCodCta:=ALLTRIM(cCodCta)+" "+ALLTRIM(SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",cCodCta)))
      oDPATVCTA:oCtaDescri:SetText(cCodCta)
   ENDIF
 
RETURN NIL

/*
// Refrescar Browse
*/
FUNCTION BRWREFRESCAR()
    LOCAL cWhere


    IF Type("oDPATVCTA")="O" .AND. oDPATVCTA:oWnd:hWnd>0

      cWhere:=" "+IIF(!Empty(oDPATVCTA:cWhere_),oDPATVCTA:cWhere_,oDPATVCTA:cWhere)
      cWhere:=STRTRAN(cWhere," WHERE ","")


      oDPATVCTA:LEERDATA(oDPATVCTA:cWhere_,oDPATVCTA:oBrw,oDPATVCTA:cServer)
      oDPATVCTA:oWnd:Show()
      oDPATVCTA:oWnd:Restore()

    ENDIF

RETURN NIL


FUNCTION BTNMENU(nOption,cOption)

   IF nOption=1
   ENDIF

RETURN .T.

FUNCTION HTMLHEAD()

   oDPATVCTA:aHead:=EJECUTAR("HTMLHEAD",oDPATVCTA)

// Ejemplo para Agregar mas Parámetros
//   AADD(oDOCPROISLR:aHead,{"Consulta",oDOCPROISLR:oWnd:cTitle})

RETURN

FUNCTION EditCta(nCol,lSave)
   LOCAL oBrw  :=oDPATVCTA:oBrw,oLbx
   LOCAL nAt   :=oBrw:nArrayAt
   LOCAL uValue:=oBrw:aArrayData[oBrw:nArrayAt,nCol]

   oLbx:=DpLbx("DPCTAUTILIZACION.LBX")
   oLbx:GetValue("CTA_CODIGO",oBrw:aCols[nCol],,,uValue)
   oDPATVCTA:lAcction  :=.T.
   oBrw:nArrayAt:=nAt

   SysRefresh(.t.)


RETURN uValue

FUNCTION ValCta(oCol,uValue,nCol,nKey)
 LOCAL cTipDoc,oTable,cWhere:="",cCtaOld:="",cDescri,aLine:={},cWhere
 LOCAL cCodInt:=oDPATVCTA:aRef[nCol-2,1]

 aLine:=oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt]

 oDPATVCTA:cCodigo:=aLine[1]

//? oDPATVCTA:cCodigo,"oDPATVCTA:cCodigo"

 DEFAULT nKey:=0

 DEFAULT oCol:lButton:=.F.

 IF oCol:lButton=.T.
    oCol:lButton:=.F.
    RETURN .T.
 ENDIF

 IF !SQLGET("DPCTA","CTA_CODIGO,CTA_DESCRI","CTA_CODIGO"+GetWhere("=",uValue))==uValue
//    MensajeErr("Cuenta Contable no Existe")
    EJECUTAR("XSCGMSGERR",oCol:oBrw,"Cuenta ["+uValue+"]Contable no Existe")
    EVAL(oCol:bEditBlock)  
    RETURN .F.
 ENDIF

 cDescri:=oDp:aRow[2]

 IF !EJECUTAR("ISCTADET",uValue,.T.,oCol:oBrw)
    EVAL(oCol:bEditBlock)  
    RETURN .F.
 ENDIF

 oDPATVCTA:lAcction  :=.F.

 oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,nCol]:=uValue
// oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,4]:=cDescri
// oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,5]:=DPFECHA()
// oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,6]:=DPHORA()
// oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,7]:=oDp:cUsuario

 aLine:=oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt]

 cWhere:="CIC_CODIGO"+GetWhere("=",oDPATVCTA:cCodigo)+" AND "+;
         "CIC_COD2"  +GetWhere("=",oDPATVCTA:cCod2  )+" AND "+;
         "CIC_CODINT"+GetWhere("=",aLine[1])

 oTable:=OpenTable("SELECT * FROM "+oDPATVCTA:cTableD+" WHERE "+cWhere,.T.)

 IF oTable:RecCount()=0
    oTable:Append()
    cWhere:=""
 ELSE
    cWhere:=oTable:cWhere
 ENDIF

 oTable:cPrimary:="CIC_CTAMOD,CIC_CODIGO,CIC_COD2,CIC_CODINT"
 oTable:SetAuditar()
 oTable:Replace("CIC_COD2"  ,oDPATVCTA:cCod2  )
 oTable:Replace("CIC_CODIGO",oDPATVCTA:cCodigo)
 oTable:Replace("CIC_CODINT",cCodInt      )
 oTable:Replace("CIC_CUENTA",uValue       ) // aLine[3])
 oTable:Replace("CIC_FECHA" ,oDp:dFecha   )
 oTable:Replace("CIC_HORA"  ,oDp:cHora    )
 oTable:Replace("CIC_USUARI",oDp:cUsuari  )
 otable:Replace("CIC_CTAMOD",oDp:cCtaMod  )
 otable:Replace("CIC_CODSUC",oDp:cSucursal)

 oTable:Commit(cWhere)
 oTable:End()

 SysRefresh(.t.)

 oCol:oBrw:DrawLine(.T.)

 EVAL(oDPATVCTA:oBrw:bChange)

RETURN .T.

FUNCTION VERCUENTA() 
    LOCAL aLine:=oDPATVCTA:oBrw:aArrayData[oDPATVCTA:oBrw:nArrayAt]
    LOCAL cCodCta:=aLine[oDPATVCTA:oBrw:nColSel]

    IF Empty(cCodCta)
       EJECUTAR("XSCGMSGERR",oDPATVCTA:oBrw,"Cuenta Contable Vacia","Mensaje")
       RETURN NIL
    ENDIF

    IF oDPATVCTA:oBrw:nColSel>2 .AND. !Empty(cCodCta)
       EJECUTAR("DPCTACON",NIL,cCodCta)
       RETURN NIL   
    ENDIF
  
RETURN 

FUNCTION CTA_UPLOAD()
  LOCAL aFiles:={},aTablas:={},lOk
  LOCAL cSql  :="SELECT * FROM DPGRU_CTA"
  IF !MsgYesNo("Desea Subir Definición Contable de "+oDp:DPGRU+" en AdaptaPro Server")
     RETURN .F.
  ENDIF

  lMkDir("UPLOAD\EJEMPLO\")

  OpenTable(cSql,.T.):CTODBF("UPLOAD\EJEMPLO\DPGRU_CTA.DBF")

  AADD(aTablas,{"UPLOAD\EJEMPLO\DPGRU_CTA.DBF"})

  MsgRun("Subiendo Tabla ","Procesando",{|| CursorWait(),lOk:= UP_PERSONALIZA(aTablas)})

  IF lOk
     MsgMemo("Proceso Concluido "+oDp:cMemoUp)
  ENDIF

  
RETURN .T.

FUNCTION CTA_DOWNLOAD()
  LOCAL aFiles:={},aTablas:={},lOk:=.F.
  LOCAL cWhere,cFile:="UPLOAD\EJEMPLO\DPGRU_CTA.DBF"

  FERASE(cFile)
  LMKDIR("UPLOAD\EJEMPLO")

  IF !MsgYesNo("Desea Descargar Definición Contable de "+oDp:DPGRU+" desde AdaptaPro Server")
     RETURN .F.
  ENDIF

  cWhere:="DIR_FILE"+GetWhere("=","DPGRU_CTA.DBF")
  MsgRun("Definición Contable de "+oDp:DPGRU+" desde AdaptaPro Server","Descargando",{||lOk:=DPAPTGETPERSONALIZA(cWhere,.F.)})

  IF FILE(cFile)
     MsgRun("Actualizando",NIL,{|| EJECUTAR("UPDATECONTABDOWN")})
     oDPATVCTA:BRWREFRESCAR()
  ENDIF
  
RETURN .T.


 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oDPATVCTA)
// EOF
