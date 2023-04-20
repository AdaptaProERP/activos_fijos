// Programa   : DPACTVIEWCON
// Fecha/Hora : 19/09/2005 13:45:04
// Propósito  : Visualizar Cuentas Contables del Activo
// Creado Por : Juan Navas
// Llamado por: DPCLIENTES (Consulta)
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cCodAct)
  LOCAL cWhere,cSql,oTable,cTitle

  DEFAULT cCodSuc:=oDp:cSucursal,;
          cCodAct:=STRZERO(1,5)

  CursorWait()
/*
  cSql:=" SELECT MOC_CUENTA,CTA_DESCRI,MOC_DOCUME,MOC_FECHA,MOC_NUMCBT,MOC_MONTO,MOC_ACTUAL "+;
        " FROM DPASIENTOS "+;
        " INNER JOIN DPCTA ON MOC_CUENTA=CTA_CODIGO "+;
        " WHERE "+;
        " MOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
        " MOC_TIPTRA='D' AND "+;
        " MOC_CODAUX"+GetWhere("=" ,cCodAct)+" AND "+;
        " MOC_ORIGEN='ACT' "
*/
  cSql:=" SELECT MOC_CUENTA,CTA_DESCRI,MOC_DOCUME,MOC_FECHA,MOC_NUMCBT,MOC_MONTO,MOC_ACTUAL "+;
        " FROM DPASIENTOS "+;
        " INNER JOIN DPCTA ON MOC_CUENTA=CTA_CODIGO "+;
        " WHERE "+;
        " MOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
        " MOC_ORIGEN='ACT' AND "+;
        " MOC_TIPO  ='ACT' AND "+;
        " MOC_CODAUX"+GetWhere("=" ,cCodAct)+" AND "+;
        " MOC_TIPTRA='D' "

// INDICE MOC_CODSUC,MOC_ORIGEN,MOC_TIPO,MOC_CODAUX                                       


  oTable:=OpenTable(cSql,.T.)
//oTable:Browse()
  oTable:Gotop()

//  WHILE !oTable:Eof()
//    oTable:DbSkip()
//  ENDDO

  oTable:End()

  IF Empty(oTable:aDataFill)
     MensajeErr("Activo "+cCodAct+" no posee Asientos Contables")
     RETURN .F.
  ENDIF

  cTitle:="Asientos Contables del Activo "+cCodAct

  ViewData(oTable:aDataFill,cCodSuc,cCodAct,cTitle)

RETURN .T.
 
FUNCTION ViewData(aData,cCodSuc,cCodAct,cTitle)
   LOCAL oBrw
   LOCAL I,nMonto:=0
   LOCAL cSql,oTable,cNombre:="",aTotal:=ATOTALES(aData)
   LOCAL oFont,oFontB
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   cNombre:=MYSQLGET("DPACTIVOS","ATV_DESCRI","ATV_CODIGO"+GetWhere("=",cCodAct))

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

//   oActCont:=DPEDIT():New(cTitle,"DPACTVIEWCON.EDT","oActCont",.T.)
   DpMdi(cTitle,"oActCont","DPACTVIEWCON.EDT")

   oActCont:Windows(0,0,aCoors[3]-160,MIN(820,aCoors[4]-10),.T.) // Maximizado

   oActCont:cCodAct:=cCodAct
   oActCont:cCodSuc:=cCodSuc
   oActCont:cNombre:=cNombre
   oActCont:lMsgBar:=.F.

   oActCont:oBrw:=TXBrowse():New( oActCont:oDlg )
   oActCont:oBrw:SetArray( aData, .F. )
   oActCont:oBrw:SetFont(oFont)
   oActCont:oBrw:lFooter := .T.
   oActCont:oBrw:lHScroll:= .F.

   oActCont:cCodTra  :=cCodAct
   oActCont:cNombre  :=cNombre

   AEVAL(oActCont:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oActCont:oBrw:aCols[1]:cHeader      :="Cuenta"
   oActCont:oBrw:aCols[1]:nWidth       :=150

   oActCont:oBrw:aCols[2]:cHeader      :="Descripción"
   oActCont:oBrw:aCols[2]:nWidth       :=200

   oActCont:oBrw:aCols[3]:cHeader      :="Número"
   oActCont:oBrw:aCols[3]:nWidth       :=080

   oActCont:oBrw:aCols[4]:cHeader      :="Fecha"
   oActCont:oBrw:aCols[4]:nWidth       :=70

   oActCont:oBrw:aCols[5]:cHeader      :="Cbte."
   oActCont:oBrw:aCols[5]:nWidth       :=70

   oActCont:oBrw:aCols[6]:cHeader      :="Debe"
   oActCont:oBrw:aCols[6]:nWidth       :=140
   oActCont:oBrw:aCols[6]:nDataStrAlign:= AL_RIGHT
   oActCont:oBrw:aCols[6]:nHeadStrAlign:= AL_RIGHT
   oActCont:oBrw:aCols[6]:nFootStrAlign:= AL_RIGHT
   oActCont:oBrw:aCols[6]:bStrData     :={|nMonto|nMonto:=oActCont:oBrw:aArrayData[oActCont:oBrw:nArrayAt,6],;
                                                  TRAN(nMonto,"99,999,999,999.99")}

   oActCont:oBrw:aCols[6]:cFooter      :=TRAN(aTotal[6],"99,999,999,999.99")



   oActCont:oBrw:aCols[7]:cHeader      :="A"
   oActCont:oBrw:aCols[7]:nWidth       :=40

   oActCont:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oActCont:oBrw,;
                                            oActCont:nClrText,;
                                           {nClrText,iif( oBrw:nArrayAt%2=0, 9690879, 14217982 ) } }

   oActCont:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oActCont:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oActCont:oBrw:CreateFromCode()
    oActCont:bValid   :={|| EJECUTAR("BRWSAVEPAR",oActCont)}
    oActCont:BRWRESTOREPAR()

   oActCont:oWnd:oClient := oActCont:oBrw


   oActCont:Activate({||oActCont:ViewDatBar(oActCont)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oActCont)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oActCont:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION (oDp:oRep:=REPORTE("DPACTASIEN"),;
                  oDp:oRep:SetRango(1,oActCont:cCodAct,oActCont:cCodAct))

   oBtn:cToolTip:="Listar Asientos Contables"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oActCont:oBrw,oActCont:cTitle,oActCont:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oActCont:oBrw:GoTop(),oActCont:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oActCont:oBrw:PageDown(),oActCont:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oActCont:oBrw:PageUp(),oActCont:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oActCont:oBrw:GoBottom(),oActCont:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oActCont:Close()

  oActCont:oBrw:SetColor(0,14217982)

  @ 0.1,50 SAY oActCont:cCodAct OF oBar BORDER SIZE 365,18
  @ 1.4,50 SAY oActCont:cNombre OF oBar BORDER SIZE 365,18

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

RETURN .T.






 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oActCont)
// EOF