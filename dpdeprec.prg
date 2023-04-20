// Programa   : DPDEPREC
// Fecha/Hora : 24/06/2006 15:08:26
// Propósito  : Calcular Depreciación de Activos
// Creado Por : Juan Navas
// Llamado por: DPACTMENU
// Aplicación : Activos
// Tabla      : DPDEPRECIA

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cCodAct,lEdit,cWhereF)
   LOCAL I,aData:={}
   LOCAL oFontG,oGrid,oCol,oFont,oFontB,oTable
   LOCAL cTitle:=GETFROMVAR("{oDp:DPDEPRECIAACT}"),cSql,cWhere
   LOCAL nMonto:=0

   DEFAULT cCodSuc:=oDp:cSucursal,;
           cCodAct:=SQLGET("DPDEPRECIAACT","DEP_CODACT"),;
           lEdit  :=.T.

// cWhere:="DEP_CODACT"+GetWhere("=",cCodAct)+" AND DEP_TIPTRA"+GetWhere("=","D")

   cWhere:="DEP_CODACT"+GetWhere("=",cCodAct)

   IF cCodSuc!=NIL
      cWhere:="DEP_CODSUC"+GetWhere("=",cCodSuc)+" AND "+cWhere
   ENDIF

   IF !Empty(cWhereF)
      cWhere:=cWhere+" AND "+cWhereF
   ENDIF

   cSql:=" SELECT "+;
         " DEP_FECHA ,"+;
         " DEP_MONTO ,"+;
         " DEP_UNIPRO,"+;
         " DEP_COMPRO,"+;
         " DEP_FCHCON,"+;
         " DEP_PORCEN,"+;
         " DEP_ESTADO,"+;
         " DEP_NUMERO,"+;
         " DEP_NUMEJE,"+;
         " DEP_DESDE ,"+;
         " 0 AS MESES "+;
         " FROM DPDEPRECIAACT "+;
         " WHERE "+cWhere+;
         " GROUP BY DEP_FECHA "+;
         " ORDER BY DEP_FECHA "

   oTable:=OpenTable(cSql,.T.)
   oTable:Gotop()
   WHILE !oTable:Eof()
      oTable:Replace("DEP_ESTADO",ALLTRIM(SAYOPTIONS("DPDEPRECIAACT","DEP_ESTADO",oTable:DEP_ESTADO)))
      oTable:Replace("MESES"     ,MESES(oTable:DEP_DESDE,oTable:DEP_FECHA))
      oTable:DbSkip()
   ENDDO

   IF oTable:RecCount()=0
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      oTable:End()
      RETURN .F.
   ENDIF

   oTable:End()

   ViewData(oTable:aDataFill,cCodSuc,cCodAct,cTitle)

RETURN .T.

FUNCTION ViewData(aData,cCodSuc,cCodAct,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData),oTable
   LOCAL I,nMonto:=0
   LOCAL cSql,oTable
   LOCAL oFont,oFontB
   LOCAL nDebe:=0,nHaber:=0

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -14 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   oTable:=OpenTable("SELECT * FROM DPACTIVOS WHERE ATV_CODIGO"+GetWhere("=",cCodAct))
   oTable:End()

   oDepAct:=DPEDIT():New(cTitle,"DPDEPRECIAACT.EDT","oDepAct",.T.)
   oDepAct:cCodAct :=cCodAct
   oDepAct:cNombre :=MYSQLGET("DPACTIVOS","ATV_DESCRI","ATV_CODIGO"+GetWhere("=",cCodAct))
   oDepAct:cField  :=cField
   oDepAct:cPicture:="99,999,999,999,999.99"
   oDepAct:lMsgBar :=.F.
   oDepAct:SetTable(oTable)
   oDepAct:lEdit     :=lEdit
   oDepAct:nMtoDep   :=aTotal[2] // Monto que debe ser Depreciado
   oDepAct:aData     :=ACLONE(aData)
   oDepAct:ATV_COSUND:=DIV(oDepAct:ATV_COSADQ-oDepAct:ATV_VALSAL)/oDepAct:ATV_UNIPRO

   @ 2,1 SAY "Vida Util:" RIGHT

   @ 2,20 SAY TRAN((oDepAct:ATV_VIDA_A*12)+oDepAct:ATV_VIDA_M,"999")+" Meses" RIGHT

   @ 3,1 SAY "Costo Adquisición:" RIGHT

   @ 3,20 SAY TRAN(oDepAct:ATV_COSADQ,"999,999,999,999.99") RIGHT

   @ 3,1 SAY "Monto a Depreciar:" RIGHT

   @ 3,20 SAY TRAN(oDepAct:nMtoDep,"999,999,999,999.99") RIGHT


   oDepAct:oBrw:=TXBrowse():New( oDepAct:oDlg )
   oDepAct:oBrw:SetArray( aData, .F. )
   oDepAct:oBrw:SetFont(oFont)
   oDepAct:oBrw:lFooter     := .T.
   oDepAct:oBrw:lHScroll    := .F.
   oDepAct:oBrw:nHeaderLines:= 2
   oDepAct:oBrw:lFooter     :=.T.

   oDepAct:cCodAct  :=cCodAct
   oDepAct:cNombre  :=cNombre
   oDepAct:aData    :=ACLONE(aData)

   AEVAL(oDepAct:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oDepAct:oBrw:aCols[1]   
   oCol:cHeader      :="Fecha"
   oCol:nWidth       :=95
   oCol:bOnPostEdit  :={|oCol,uValue|oDepAct:VALFECHA(uValue)}
   oCol:nEditType    :=EDIT_GET_BUTTON
   oCol:bEditBlock   :={|dFecha|dFecha:=oDepAct:oBrw:aArrayData[oDepAct:oBrw:nArrayAt,1],;
                                dFecha:=CalendarioDlg(NIL,dFecha),;
                                oDepAct:VALFECHA(dFecha)}

   oCol:cFooter      :=TRAN(LEN(aData),"9999")


   IF !lEdit  
      oCol:nEditType    :=0
   ENDIF

   oCol:=oDepAct:oBrw:aCols[2]  
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="Monto"
   oCol:nWidth       :=150
   oCol:bStrData     :={|nMonto|nMonto:=oDepAct:oBrw:aArrayData[oDepAct:oBrw:nArrayAt,2],;
                                TRAN(nMonto,"999,999,999,999.99")}
   oCol:cEditPicture :="999,999,999,999.99"
   oCol:bOnPostEdit  :={|oCol,uValue|oDepAct:VALMONTO(uValue)}
   oCol:nEditType    :=1

   IF oDepAct:ATV_UNIPRO>0 .OR. !lEdit  
      oCol:nEditType    :=0
   ENDIF

   oCol:cFooter      :=TRAN(aTotal[2],"999,999,999,999.99")


   oCol:=oDepAct:oBrw:aCols[3]   
   oCol:cHeader      :="Unid/Prod"
   oCol:nWidth       :=110
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oDepAct:oBrw:aArrayData[oDepAct:oBrw:nArrayAt,3],;
                                TRAN(nMonto,"99,999,999.99")}

   oCol:bOnPostEdit  :={|oCol,uValue|oDepAct:VALCANUND(uValue)}
   oCol:cEditPicture :="999,999,999,999.99"

   IF oDepAct:ATV_UNIPRO>0 .AND. lEdit
     oCol:nEditType    :=1
   ENDIF

   oCol:cFooter      :=TRAN(aTotal[3],"999,999,999,999.99")

   oCol:=oDepAct:oBrw:aCols[4]   
   oCol:cHeader      :="Comprobante"
   oCol:nWidth       :=80

   oCol:=oDepAct:oBrw:aCols[5]   
   oCol:cHeader      :="Fecha"+CRLF+"Contb"
   oCol:nWidth       :=78

   oCol:=oDepAct:oBrw:aCols[6]   
   oCol:cHeader      :="%"
   oCol:nWidth       :=45
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oDepAct:oBrw:aArrayData[oDepAct:oBrw:nArrayAt,6],;
                                TRAN(nMonto,"999.99")}


   oCol:cFooter      :=TRAN(aTotal[6],"999.99")


   oCol:=oDepAct:oBrw:aCols[7]   
   oCol:cHeader      :="Estado"
   oCol:nWidth       :=110


   oCol:=oDepAct:oBrw:aCols[8]   
   oCol:cHeader      :="#Reg."
   oCol:nWidth       :=40

   oCol:=oDepAct:oBrw:aCols[9]   
   oCol:cHeader      :="Num"+CRLF+"Eje"
   oCol:nWidth       :=60

   oCol:=oDepAct:oBrw:aCols[10]   
   oCol:cHeader      :="Fecha"+CRLF+"Desde"
   oCol:nWidth       :=78

   oCol:=oDepAct:oBrw:aCols[11]   
   oCol:cHeader      :="Cant"+CRLF+"Mes"
   oCol:nWidth       :=40
   oCol:cFooter      :=TRAN(aTotal[11],"9999")
   oCol:bStrData     :={|nMonto|nMonto:=oDepAct:oBrw:aArrayData[oDepAct:oBrw:nArrayAt,11],;
                                TRAN(nMonto,"9999")}
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT




   oDepAct:oBrw:bClrStd               := {|oBrw,nClrText,aData,cChar|oBrw:=oDepAct:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           cChar   :=LEFT(aData[7],1),;
                                           nClrText:=0,;
                                           nClrText:=IIF(cChar="H",CLR_HRED ,nClrText),;
                                           nClrText:=IIF(cChar="C",CLR_HBLUE,nClrText),;
                                           nClrText:=IIF(cChar="D",CLR_GRAY ,nClrText),;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 16773862, 16771538 ) } }

   oDepAct:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oDepAct:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


//   oDepAct:oBrw:DelCol(8)
//   oDepAct:oBrw:DelCol(8)

   oCol:bLClickFooter:={|oBrw|oBrw:=oDepAct:oBrw,;
                              EJECUTAR("DPDOCCLIVIEW",;
                              oDepAct:cCodAct,;
                              NIL,;
                              NIL,;
                              oDepAct:aData[oBrw:nArrayAt,2],,,,,"Estado de Cuenta")}

  
   FOR I=1 TO LEN(oDepAct:oBrw:aCols)
       oDepAct:oBrw:aCols[I]:bLClickFooter:=oCol:bLClickFooter
   NEXT I


   oDepAct:oBrw:bLDblClick:={|oBrw|oBrw:=oDepAct:oBrw,;
                                   EJECUTAR("DPDOCCLIVIEW",;
                                   oDepAct:cCodAct,;
                                   oDepAct:aData[oBrw:nArrayAt,1],;
                                   oDepAct:aData[oBrw:nArrayAt,2],;
                                   oDepAct:aData[oBrw:nArrayAt,2],,,,,"Estado de Cuenta")}


   oDepAct:oBrw:CreateFromCode()

   oDepAct:Activate({||oDepAct:ViewDatBar(oDepAct)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oDepAct)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oDepAct:oDlg

   oDepAct:oBrw:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
          ACTION oDepAct:GrabarDep();
          WHEN oDepAct:lEdit 

   oBtn:cToolTip:="Grabar"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION (oDepAct:oRep:=REPORTE("DPDEPREACT"),;
                  oDepAct:oRep:SetRango(1,oDepAct:cCodAct,oDepAct:cCodAct))

   oBtn:cToolTip:="Listar Depreciaciones"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oDepAct:oBrw,oDepAct:cTitle,oDepAct:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oDepAct:oBrw:GoTop(),oDepAct:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oDepAct:oBrw:PageDown(),oDepAct:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oDepAct:oBrw:PageUp(),oDepAct:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oDepAct:oBrw:GoBottom(),oDepAct:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oDepAct:Close()

  oDepAct:oBrw:SetColor(0,16773862)

  @ 0.1,55 SAY "Código: "+oDepAct:cCodAct OF oBar BORDER SIZE 345,18
  @ 1.4,55 SAY "Descripción: "+oDepAct:cNombre OF oBar BORDER SIZE 345,18

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

RETURN .T.

/*
// Imprimir
*/
FUNCTION IMPRIMIR(cCodAct)
  LOCAL oRep

  oRep:=REPORTE("INVCOSULT")
  oRep:SetRango(1,oDepAct:cCodAct,oDepAct:cCodAct)

RETURN .T.


/*
// Grabar Departamento
*/
FUNCTION GrabarDep()

    LOCAL aTotal:=ATOTALES(oDepAct:oBrw:aArrayData),I,aData
    
    oDepAct:nMtoDep:=int(oDepAct:nMtoDep*100)/100
    aTotal[2]      :=int(aTotal[2]*100)/100 

    IF oDepAct:ATV_COSUND=0 .AND. !(oDepAct:nMtoDep == aTotal[2])
       MensajeErr("Monto Total Depreciaciones Debe ser Igual que "+;
                  ALLTRIM(TRAN(oDepAct:nMtoDep,"999,999,999,999.99")),"Intente Nuevamente")

       DPFOCUS(oDepAct:oBrw)

       RETURN .F.

    ENDIF

    CursorWait()

    DpSqlBegin()

    FOR I=1 TO LEN(oDepAct:oBrw:aArrayData)

       aData:=oDepAct:oBrw:aArrayData[I]

       aData[4]:=IF(Empty(aData[4]),aData[2],CTOO(aData[4],"N"))

//ViewArray(aData)
   
       SQLUPDATE("DPDEPRECIAACT",{"DEP_FECHA","DEP_MONTO","DEP_UNIPRO","DEP_MTOORG"},;
                                 {aData[1]   ,aData[2]   ,aData[3], aData[4]},;
                                 "DEP_CODACT"+GetWhere("=",oDepAct:cCodAct)+" AND "+;
                                 "DEP_NUMERO"+GetWhere("=",oDepAct:aData[I,8]))

    NEXT I

    DpSqlCommit()

    oDepAct:Close()
    
RETURN NIL

/*
// Valida Fecha
*/
FUNCTION VALFECHA(dFecha)

   LOCAL nAt:=0

   nAt:=ASCAN(oDepAct:oBrw:aArrayData,{|a,n| a[1]=dFecha })

   IF nAt>0 .AND. oDepAct:oBrw:nArrayAt<>nAt
      IF MsgNoYes("Fecha ya Existe en Posición "+LSTR(nAt),"Acepta Fecha "+DTOC(dFecha))
         RETURN oDepAct:oBrw:aArrayData[oDepAct:oBrw:nArrayAt,1]
      ENDIF
   ENDIF

   oDepAct:oBrw:aArrayData[oDepAct:oBrw:nArrayAt,1]:=dFecha
   oDepAct:oBrw:DrawLine(.T.)

RETURN dFecha

FUNCTION VALMONTO(nMonto)

   LOCAL aTotal :={}
   LOCAL nAt    :=oDepAct:oBrw:nArrayAt
   LOCAL nRowSel:=oDepAct:oBrw:nRowSel

   IF nMonto<0
      MensajeErr("Monto debe ser Positivo")
      nMonto:=oDepAct:oBrw:aArrayData[oDepAct:oBrw:nArrayAt,2]
   ENDIF

   oDepAct:oBrw:aArrayData[oDepAct:oBrw:nArrayAt,2]:=nMonto
   oDepAct:oBrw:DrawLine(.T.)

   aTotal:=ATOTALES(oDepAct:oBrw:aArrayData)

   oDepAct:oBrw:aCols[2]:cFooter      :=TRAN(aTotal[2],"999,999,999,999.99")

   oDepAct:oBrw:Refresh(.F.)
   oDepAct:oBrw:nArrayAt:=nAt
   oDepAct:oBrw:nRowSel :=nRowSel

RETURN nMonto

/*
// Valida Cantidad de Unidades
*/
FUNCTION VALCANUND(nMonto)

   LOCAL aTotal :={}
   LOCAL nAt    :=oDepAct:oBrw:nArrayAt
   LOCAL nRowSel:=oDepAct:oBrw:nRowSel

   IF nMonto<0
      MensajeErr("Monto debe ser Positivo")
      nMonto:=oDepAct:oBrw:aArrayData[oDepAct:oBrw:nArrayAt,3]
   ENDIF

   oDepAct:oBrw:aArrayData[oDepAct:oBrw:nArrayAt,3]:=nMonto
   oDepAct:oBrw:aArrayData[oDepAct:oBrw:nArrayAt,2]:=nMonto*oDepAct:ATV_COSUND

   oDepAct:oBrw:DrawLine(.T.)

   aTotal:=ATOTALES(oDepAct:oBrw:aArrayData)

   oDepAct:oBrw:aCols[3]:cFooter      :=TRAN(aTotal[3],"999,999,999,999.99")

   oDepAct:oBrw:Refresh(.F.)
   oDepAct:oBrw:nArrayAt:=nAt
   oDepAct:oBrw:nRowSel :=nRowSel

RETURN nMonto

// EOF


