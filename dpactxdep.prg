// Programa   : DPACTXDEP
// Fecha/Hora : 04/08/2011 08:12:09
// Propósito  : Activos sin Depreciación
// Creado Por : Juan Navas
// Llamado por: DPMENU
// Aplicación : Gerencia 
// Tabla      : DPDEPRECIAACT

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,dFecha,lData,lMsg)
   LOCAL cSql
   LOCAL aData,cTitle

   DEFAULT cCodSuc:=oDp:cSucursal,;
           dFecha :=oDp:dFecha   ,;
           lData  :=.F.          ,;
           lMsg   :=.T.

   cTitle:="Activos sin Depreciación "

   aData :=LEERACTIVO(NIL,NIL,cCodSuc,dFecha)

   IF lData
     RETURN aData
   ENDIF

   IF Empty(aData) 

      IF lMsg
        MensajeErr("no hay "+cTitle,"Información no Encontrada")
      ENDIF

      RETURN .F.

   ENDIF

   ViewData(aData,cTitle)
            
RETURN .T.


FUNCTION VIEWDATA(aData,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL I,nMonto:=0
   LOCAL cSql,oTable
   LOCAL oFont,oFontB
   LOCAL nDebe:=0,nHaber:=0

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   DPEDIT():New(cTitle,"DPACTXDEP.EDT","oActxDep",.T.)

   oActxDep:cCodSuc :=oDp:cSucursal
   oActxDep:lMsgBar :=.F.
   oActxDep:cCodSuc :=cCodSuc
   oActxDep:cTipDoc :=cTipDoc
   oActxDep:dFecha  :=oDp:dFecha
   oActxDep:cNombre :="Hasta el "+DTOC(oDp:dFecha)

   oActxDep:dDesde  :=dDesde
   oActxDep:dHasta  :=dHasta

   oActxDep:oBrw:=TXBrowse():New( oActxDep:oDlg )
   oActxDep:oBrw:SetArray( aData, .T. )
   oActxDep:oBrw:SetFont(oFont)

   oActxDep:oBrw:lFooter     := .T.
   oActxDep:oBrw:lHScroll    := .F.
   oActxDep:oBrw:nHeaderLines:= 2
   oActxDep:oBrw:lFooter     :=.T.

   oActxDep:aData            :=ACLONE(aData)

   AEVAL(oActxDep:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oActxDep:oBrw:aCols[1]   
   oCol:cHeader      :="Código"+CRLF+oDp:xDPACTIVOS
   oCol:nWidth       :=140

   oCol:=oActxDep:oBrw:aCols[2]
   oCol:cHeader      :="Nombre del "+CRLF+oDp:xDPACTIVOS
   oCol:nWidth       :=260

   oCol:=oActxDep:oBrw:aCols[3]   
   oCol:cHeader      :="Fecha"
   oCol:nWidth       :=070


   oCol:=oActxDep:oBrw:aCols[4]   
   oCol:cHeader      :="Costo"+CRLF+"Adquisición"
   oCol:nWidth       :=130
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oActxDep:oBrw:aArrayData[oActxDep:oBrw:nArrayAt,4],;
                                TRAN(nMonto,"999,999,999,999.99")}
   oCol:cFooter      :=TRAN( aTotal[4],"999,999,999,999.99")



   oActxDep:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oActxDep:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 15856100, 15198159 ) } }


   oActxDep:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oActxDep:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oActxDep:oBrw:bLDblClick:={||oActxDep:MODACTIVOS() }

   oActxDep:oBrw:CreateFromCode()

   oActxDep:Activate({||oActxDep:ViewDatBar()})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oActxDep:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oActxDep:oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XEDIT.BMP",NIL,"BITMAPS\XEDITG.BMP";
          ACTION oActxDep:MODACTIVOS()

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oActxDep:oBrw,oActxDep:cTitle,oActxDep:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oActxDep:oBrw:GoTop(),oActxDep:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oActxDep:oBrw:PageDown(),oActxDep:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oActxDep:oBrw:PageUp(),oActxDep:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oActxDep:oBrw:GoBottom(),oActxDep:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oActxDep:Close()

  oActxDep:oBrw:SetColor(0,15856100)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  //
  // Campo : Periodo
  //

  @ 1.0, 062 GET oActxDep:oFecha  VAR oActxDep:dFecha;
               SIZE 80,22;
               COLOR CLR_BLACK,CLR_WHITE;
               VALID (oActxDep:LEERACTIVO(NIL,oActxDep:oBrw,NIL,oActxDep:dFecha),.T.);
               OF oBar;
               SPINNER;
               ON CHANGE EVAL(oActxDep:oFecha:bValid);
               FONT oFont

  @ oActxDep:oFecha:nTop,070 SAY "Fecha:" OF oBar BORDER SIZE 34,24

  @ 0.75, 101 BUTTON oActxDep:oBtn PROMPT " > " SIZE 27,24-2;
              FONT oFont;
              OF oBar;
              ACTION EVAL(oActxDep:oFecha:bValid)

   oActxDep:oBar:=oBar

   oActxDep:oBrw:aCols[3]:cOrder := "A"
   EVAL(oActxDep:oBrw:aCols[3]:bLClickHeader,NIL,NIL,NIL,oActxDep:oBrw:aCols[3])

RETURN .T.

/*
// Imprimir
*/
FUNCTION IMPRIMIR(cCodInv)
  LOCAL oRep

//  oRep:=REPORTE("INVCOSULT")
//  oRep:SetRango(1,oActxDep:cCodInv,oActxDep:cCodInv)

RETURN .T.

FUNCTION LEERACTIVO(cWhere,oBrw,cCodSuc,dFecha)
   LOCAL aData:={},aTotal:={}
   LOCAL cSql,cCodSuc:=oDp:cSucursal

   DEFAULT cCodSuc:=oDp:cSucursal,;
           dFecha :=oDp:dFecha

   cSql  :=" SELECT ATV_CODIGO,ATV_DESCRI,ATV_FCHADQ,ATV_COSADQ "+;
           " FROM DPACTIVOS "+;
           " LEFT JOIN DPDEPRECIAACT ON DEP_CODACT=ATV_CODIGO  "+;
           " WHERE ATV_CODSUC"+GetWhere("=",cCodSuc )+;
           "   AND ATV_FCHADQ"+GetWhere("<=",dFecha )+;
           "   AND ATV_ESTADO"+GetWhere("=" ,"A"    )+;
           "   AND ATV_DEPRE "+GetWhere("=" ,"D"    )+;
           "    AND DEP_CODACT IS NULL "

   aData:=ASQL(cSql)
? CLPCOPY(cSql)

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql)
   ENDIF
 
   IF ValType(oBrw)="O"

      aTotal:=ATOTALES(aData)
  
      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      oBrw:aCols[3]:cFooter      :=TRAN( aTotal[3],"999,999,999,999.99")
      oBrw:aCols[4]:cFooter      :=TRAN( aTotal[4],"999,999,999,999.99")
      oBrw:aCols[5]:cFooter      :=TRAN( aTotal[5],"999,999,999,999.99")

      oActxDep:oBrw:aCols[3]:cOrder:=IIF( oActxDep:oBrw:aCols[3]:cOrder="A","D","A")

      EVAL(oActxDep:oBrw:aCols[3]:bLClickHeader,NIL,NIL,NIL,oActxDep:oBrw:aCols[3])

      oBrw:Refresh(.T.)

   ENDIF

RETURN aData

FUNCTION VERPROVEEDOR()
   LOCAL cCodigo :=oActxDep:oBrw:aArrayData[oActxDep:oBrw:nArrayAt,1]

   EJECUTAR("DPPROVEEDORCON",NIL,cCodigo)

RETURN .T.

FUNCTION VERDOCUMENTO()
   LOCAL cCodigo :=oActxDep:oBrw:aArrayData[oActxDep:oBrw:nArrayAt,3]
   LOCAL cNumero :=oActxDep:oBrw:aArrayData[oActxDep:oBrw:nArrayAt,1]

   EJECUTAR("DPDOCCLIFAVCON",NIL,oActxDep:cCodSuc,oActxDep:cTipDoc,cNumero,cCodigo)

RETURN .T.

FUNCTION MODACTIVOS()
  LOCAL cCodigo :=oActxDep:oBrw:aArrayData[oActxDep:oBrw:nArrayAt,1]

  EJECUTAR("DPACTIVOS",3,cCodigo)

RETURN .F.

// EOF
