// Programa   : DPCONTABEVALCTAINDEF
// Fecha/Hora : 19/09/2020 07:22:38
// Propósito  : Evaluación para de Cuentas Indefinidas
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(aCodInt)
  LOCAL aData:={},I,cCodCta,cDescri
  LOCAL aTipDoc:={}
  LOCAL cWhere :=[ TIP_ACTIVO=1 AND (CTA_CODIGO IS NULL OR CTA_CODIGO="" OR CTA_CODIGO]+GetWhere("=",oDp:cCtaIndef)+[)]
  LOCAL aCtaIva:=ASQL("SELECT TIP_CTACRE FROM DPIVATIP LEFT JOIN dpcta ON TIP_CTACRE=CTA_CODIGO WHERE TIP_ACTIVO=1 AND TIP_CTACRE"+GetWhere("<>",oDp:cCtaIndef))
    
  EJECUTAR("DPCTAMODCREA")

//? oDp:cCtaMod,"oDp:cCtaMod"

  IF !Empty(aCtaIva) // .AND. Empty(SQLGET("DPCODINTEGRA","CIN_CODCTA","CIN_CODIGO"+GetWhere("=","VTAIVA")))
     AADD(aData,{"VTAIVA","DPCODINTEGRA","","DPIVATIP","",""})
  ENDIF

  aCtaIva:=ASQL("SELECT TIP_CTADEB FROM DPIVATIP WHERE TIP_ACTIVO=1 AND TIP_CTADEB"+GetWhere("<>",oDp:cCtaIndef))

  IF !Empty(aCtaIva) // .AND. Empty(SQLGET("DPCODINTEGRA","CIN_CODCTA","CIN_CODIGO"+GetWhere("=","COMIVA")))
     AADD(aData,{"COMIVA","DPCODINTEGRA","","DPIVATIP","",""})
  ENDIF

  AADD(aTipDoc,{"FAV","VTANAC"})
  AADD(aTipDoc,{"CRE","VTACRE"})
  AADD(aTipDoc,{"DEB","VTADEB"})
  AADD(aTipDoc,{"RTI","VTARTI"})
  AADD(aTipDoc,{"RET","VTARET"})

  FOR I=1 TO LEN(aTipDoc)

    cCodCta:=SQLGET("DPTIPDOCCLI_CTA","CIC_CUENTA","CIC_CODIGO"+GetWhere("=",aTipDoc[I,1])+" AND CIC_CTAMOD"+GetWhere("=",oDp:cCtaMod))

    IF Empty(cCodCta) .OR. ALLTRIM(cCodCta)=oDp:cCtaIndef
       AADD(aData,{aTipDoc[I,2],"DPTIPDOCCLI","","DPTIPDOCCLI","",""})
    ENDIF

  NEXT I

  // Documentos del Proveedor
  aTipDoc:={}
  AADD(aTipDoc,{"FAC","COMNAC"})
  AADD(aTipDoc,{"CRE","COMCRE"})
  AADD(aTipDoc,{"DEB","COMDEB"})
  AADD(aTipDoc,{"RTI","COMRTI"})
  AADD(aTipDoc,{"RET","COMRET"})

  FOR I=1 TO LEN(aTipDoc)

    cCodCta:=SQLGET("DPTIPDOCPRO_CTA","CIC_CUENTA","CIC_CODIGO"+GetWhere("=",aTipDoc[I,1])+" AND CIC_CTAMOD"+GetWhere("=",oDp:cCtaMod))

    IF Empty(cCodCta) .OR. ALLTRIM(cCodCta)=oDp:cCtaIndef
       AADD(aData,{aTipDoc[I,2],"DPTIPDOCPRO","","DPTIPDOCPRO","",""})
    ENDIF

  NEXT I


  /*
  // Busca si Tiene Cuentas Indefinidas
  */
  FOR I=1 TO LEN(aData)
     cCodCta:=SQLGET("DPCODINTEGRA","CIN_CODCTA,CIN_DESCRI","CIN_CODIGO"+GetWhere("=",aData[I,1]))
     aData[I,2]:=DPSQLROW(2,"")
     aData[I,3]:=cCodCta
     aData[I,6]:=SQLGET("DPCTA"   ,"CTA_DESCRI","CTA_CODIGO"+GetWhere("=",aData[I,4]))
     aData[I,5]:=SQLGET("DPTABLAS","TAB_DESCRI","TAB_NOMBRE"+GetWhere("=",aData[I,4]))
     aData[I,4]:=SQLGET("DPCTA"   ,"CTA_DESCRI","CTA_CODIGO"+GetWhere("=",aData[I,3]))
  NEXT I

  VERCUENTAS(aData)

// ViewArray(aData)
RETURN NIL

// ViewArray(aCtaIva)
FUNCTION VERCUENTAS(aData,cTable,cCodigo,cCod2,cDescri,aRef,cTitle,lView)
// PROCE MAIN(cTable,cCodigo,cCod2,cDescri,aRef,cTitle,lView)
  LOCAL cSql,cTableD,I,nAt
  LOCAL oBrw,oCol,oFont,oFontG,oFontB,oSayRef,oTable,oBtn
  LOCAL aCoors:=GetCoors( GetDesktopWindow() )
  
  DEFAULT cTable :="DPCODINTEGRA",;
          cCodigo:=SQLGET("DPACTIVOS","ATV_CODIGO"),;
          cCod2  :="",;
          cDescri:=SQLGET("DPACTIVOS","ATV_DESCRI","ATV_CODIGO"+GetWhere("=",cCodigo)),;
          cTitle :="",;
          lView  :=.F.

  cTableD:="DPCODINTEGRA"

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

  cTitle:=IF(lView,"Consultar","Asignar")+;
          " Cuentas Contables "+;
          IIF(!Empty(cTitle),"("+cTitle+") "," ")+;
          "para ["+GetFromVar("{oDp:x"+cTable+"}")+" ]"

// DPEDIT():New(cTitle,"DPEDITCTAMOD.EDT","oCtaIndef",.T.)

  DpMdi(cTitle,"oCtaIndef","DPCONTABEVALCTAINDEF.EDT")

  oCtaIndef:Windows(0,0,400,MIN(998,aCoors[4]-10),.T.) // Maximizado

  oCtaIndef:cCodigo   :=cCodigo
  oCtaIndef:cCod2     :=cCod2
  oCtaIndef:aData     :=ACLONE(aData)
  oCtaIndef:cNombre   :=cDescri

  oCtaIndef:nClrPane1:=16775408 
  oCtaIndef:nClrPane2:=16771797

  oCtaIndef:nClrText  :=0
  oCtaIndef:nClrText1 :=14511872

  oCtaIndef:lAcction  :=.F.
  oCtaIndef:cCtaDoc   :=""
  oCtaIndef:cCtaCxP   :=""
  oCtaIndef:lView     :=lView  
  oCtaIndef:cTableD   :=cTableD

  oBrw:=TXBrowse():New( oCtaIndef:oWnd )

  oBrw:SetArray( aData, .F. )

  oBrw:lHScroll            := .T.
  oBrw:lFooter             := .F.
  oBrw:oFont               :=oFont
  oBrw:nHeaderLines        := 2

  AEVAL(oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})
  oCtaIndef:oBrw:=oBrw

  oBrw:aCols[1]:cHeader:="Código"+CRLF+"Integración"
  oBrw:aCols[1]:nWidth :=80

  oBrw:aCols[2]:cHeader:="Referencia"
  oBrw:aCols[2]:nWidth :=140

  oBrw:aCols[3]:cHeader   :="Cuenta "
  oBrw:aCols[3]:nWidth    :=180
  oBrw:aCols[3]:nEditType :=IIF( lView, 0, EDIT_GET_BUTTON)
  oBrw:aCols[3]:bEditBlock:={||oCtaIndef:EditCta(3,.F.)}
  oBrw:aCols[3]:bOnPostEdit:={|oCol,uValue,nKey|oCtaIndef:ValCta(oCol,uValue,3,nKey)}
  oBrw:aCols[3]:lButton   :=.F.

  oBrw:aCols[4]:cHeader   :="Nombre de la Cuenta "
  oBrw:aCols[4]:nWidth    :=200

  oBrw:aCols[5]:cHeader   :="Nombre de la Tabla "
  oBrw:aCols[5]:nWidth    :=200


  oBrw:bClrHeader:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
  oBrw:bClrFooter:= {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

  oBrw:bClrStd   :={|oBrw,nClrText,aLine|oBrw    :=oCtaIndef:oBrw,;
                                         aLine   :=oCtaIndef:oBrw:aArrayData[oCtaIndef:oBrw:nArrayAt],;
                                         nClrText:=IF(aLine[3]$oDp:cCtaIndef,oCtaIndef:nClrText,oCtaIndef:nClrText1),;
                                   {nClrText, iif( oBrw:nArrayAt%2=0, oCtaIndef:nClrPane1, oCtaIndef:nClrPane2 ) } }


  oBrw:CreateFromCode()

  oBrw:bChange:={||NIL}

  oBrw:SetFont(oFont)

  oCtaIndef:oWnd:oClient := oCtaIndef:oBrw

  oCtaIndef:bValid   :={|| EJECUTAR("BRWSAVEPAR",oCtaIndef)}
 
  oCtaIndef:Activate({||oCtaIndef:BotBarra()})

  oCtaIndef:BRWRESTOREPAR()
 
RETURN NIL

FUNCTION EditCta(nCol,lSave)
   LOCAL oBrw  :=oCtaIndef:oBrw,oLbx
   LOCAL nAt   :=oBrw:nArrayAt
   LOCAL uValue:=oBrw:aArrayData[oBrw:nArrayAt,nCol]

   oLbx:=DpLbx("DPCTAUTILIZACION.LBX")
   oLbx:GetValue("CTA_CODIGO",oBrw:aCols[nCol],,,uValue)
   oCtaIndef:lAcction  :=.T.
   oBrw:nArrayAt:=nAt

   SysRefresh(.t.)


RETURN uValue

FUNCTION ValCta(oCol,uValue,nCol,nKey)
 LOCAL cTipDoc,oTable,cWhere:="",cCtaOld:="",cDescri,aLine:={},cWhere

 DEFAULT nKey:=0

 DEFAULT oCol:lButton:=.F.

 IF oCol:lButton=.T.
    oCol:lButton:=.F.
    RETURN .T.
 ENDIF

 IF !SQLGET("DPCTA","CTA_CODIGO,CTA_DESCRI","CTA_CODIGO"+GetWhere("=",uValue))==uValue
    MensajeErr("Cuenta Contable no Existe")
    EVAL(oCol:bEditBlock)  
    RETURN .F.
 ENDIF

 cDescri:=oDp:aRow[2]

 IF !EJECUTAR("ISCTADET",uValue,.T.)
    EVAL(oCol:bEditBlock)  
    RETURN .F.
 ENDIF

 oCtaIndef:lAcction  :=.F.

 oCtaIndef:cCodigo:=oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,1]
 oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,3]:=uValue
 oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt,4]:=cDescri

 aLine :=oCol:oBrw:aArrayData[oCol:oBrw:nArrayAt]
 cWhere:="CIN_CODIGO"+GetWhere("=",oCtaIndef:cCodigo)

 oTable:=OpenTable("SELECT * FROM "+oCtaIndef:cTableD+" WHERE "+cWhere,.T.)
//oTable:Browse()

 IF oTable:RecCount()=0
    oTable:Append()
    oTable:cWhere:=""
 ELSE
    cWhere:=oTable:cWhere
 ENDIF

// ? oTable:cSql
//  oTable:Browse()
 oTable:cPrimary:="CIN_CODIGO"
 oTable:SetAuditar()
 oTable:Replace("CIN_CODIGO",oCtaIndef:cCodigo)
 oTable:Replace("CIN_CODCTA",aLine[3])
 oTable:Commit(cWhere)

 oTable:End()

 SysRefresh(.t.)

 oCol:oBrw:DrawLine(.T.)

RETURN .T.

/*
// Consultar la Cuenta
*/

FUNCTION VERCUENTA()
RETURN .T.

FUNCTION QUITAR()
RETURN .T.

/*
// Barra de Botones
*/
FUNCTION BotBarra()
   LOCAL oCursor,oBar,oBtn,oFont

   oCtaIndef:oBrw:SetColor(0,oCtaIndef:nClrPane1)
   oCtaIndef:oBrw:nColSel:=3

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oCtaIndef:oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILE DPBMP("CONTABILIDAD.BMP"),NIL,DPBMP("CONTABILIDADG.BMP");
          WHEN !Empty(oCtaIndef:oBrw:aArrayData[oCtaIndef:oBrw:nArrayAt,3]);
          ACTION oCtaIndef:VERCUENTA()

   oBtn:lCancel :=.T.
   oBtn:cToolTip:="Consultar Cuenta Contable"
   oBtn:cMsg    :=oBtn:cToolTip

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          ACTION EJECUTAR("BRWSETFILTER",oCtaIndef:oBrw)

   oBtn:cToolTip:="Filtrar Registros"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oCtaIndef::oBrw);
          WHEN LEN(oCtaIndef:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (EJECUTAR("BRWTOHTML",oCtaIndef:oBrw))

   oBtn:cToolTip:="Generar Archivo html"

   oCtaIndef:oBtnHtml:=oBtn


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILE "BITMAPS\XPRINT.BMP";
          ACTION oCtaIndef:IMPRIMIRCTAS()

   oBtn:lCancel :=.T.
   oBtn:cToolTip:="Imprimir Cuentas Contables"
   oBtn:cMsg    :=oBtn:cToolTip


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION  oCtaIndef:Close()

   oBtn:cToolTip:="Cerrar"

//   @ 0.1,40 SAY " "+oCtaIndef:cCodigo OF oBar BORDER SIZE 395,18
//   @ 1.4,40 SAY " "+oCtaIndef:cNombre OF oBar BORDER SIZE 395,18

   oBar:SetColor(CLR_BLACK,oDp:nGris)
   AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

   oCtaIndef:oBar:=oBar

RETURN .T.

FUNCTION VERCUENTA()
  LOCAL cCodCta:=oCtaIndef:oBrw:aArrayData[oCtaIndef:oBrw:nArrayAt,3]

  EJECUTAR("DPCTACON",NIL,cCodCta)

RETURN NIL

FUNCTION IMPRIMIRCTAS()
  LOCAL oRep:=REPORTE(oCtaIndef:cTableD)

  IF ValType(oRep)="O"
     oRep:SetRango(1,oCtaIndef:cCodigo,oCtaIndef:cCodigo)
  ENDIF

RETURN NIL

FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR",oCtaIndef)
// EOF
