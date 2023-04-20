// Programa   : DPACTIVOSMNU
// Fecha/Hora : 14/11/2014 05:39:22
// Propósito  : Menú de Activo
// Creado Por : Juan Navas
// Llamado por: DPACTIVO
// Aplicación : Activos
// Tabla      : DPACTIVOS

#INCLUDE "DPXBASE.CH"
#include "outlook.ch"
#include "splitter.Ch"

PROCE MAIN(oFrm,cCodigo)
   LOCAL aData,cWhere
   LOCAL oFont,oOut,oSpl,oCursor,oBar,oBtn,oBar,aData:={},oBrw,I,oBmp,oFontBrw,nGroup,bAction,cTitle
   LOCAL cNombre
   LOCAL cCodSuc:=oDp:cSucursal

   DEFAULT cCodigo:=SQLGET("DPACTIVOS","ATV_CODIGO")

   IF ValType(oFrm)="O"
     cCodigo:=oFrm:ATV_CODIGO
     cCodSuc:=oFrm:ATV_CODSUC
   ENDIF

   cTipoAct:=SQLGET("DPACTIVOS","ATV_DEPRE","ATV_CODIGO"+GetWhere("=",cCodAct))

   nContab:=COUNT("DPDEPRECIAACT","DEP_CODACT"+GetWhere("=",cCodAct)+" AND "+;
                                  "DEP_ESTADO='C'")

   nDesinc:=COUNT("DPDEPRECIAACT","DEP_CODACT"+GetWhere("=",cCodAct)+" AND "+;
                                  "DEP_ESTADO='D'")

   cNombre:=SQLGET("DPACTIVOS","ATV_DESCRI","ATV_CODIGO"+GetWhere("=",cCodigo))

   DEFINE FONT oFont    NAME GetSysFont() SIZE 0,-14
   DEFINE FONT oFontBrw NAME "MS Sans Serif" SIZE 0,-10 BOLD

   cTitle:="Consulta "+GetFromVar("{oDp:xDPACTIVOS}")

   DpMdi(cTitle,"oMnuAct","TEST.EDT")

   oMnuAct:cCodigo :=cCodigo
   oMnuAct:cCodSuc :=cCodSuc
   oMnuAct:cNombre :=cNombre
   oMnuAct:lSalir  :=.F.
   oMnuAct:nHeightD:=45
   oMnuAct:cTitle  :=cTitle
   oMnuAct:lMsgBar :=.F.
   oMnuAct:oFrm    :=oFrm
   oMnuAct:cTipoAct:=cTipoAct
   oMnuAct:nContab :=nContab
   oMnuAct:nDesinc :=nDesinc

   SetScript("DPACTIVOSMNU")

   oMnuAct:Windows(0,0,400+90,410)

  @ 48, -1 OUTLOOK oMnuAct:oOut ;
     SIZE 150+250, oMnuAct:oWnd:nHeight()-85 ;
     PIXEL ;
     FONT oFont ;
     OF oMnuAct:oWnd;
     COLOR CLR_BLACK,15794145

   DEFINE GROUP OF OUTLOOK oMnuAct:oOut PROMPT "&Consulta"

   DEFINE BITMAP OF OUTLOOK oMnuAct:oOut ;
          BITMAP "BITMAPS\VIEW.BMP";
          PROMPT "Menu de Consulta";
          ACTION  EJECUTAR("DPACTIVOCON",NIL,oMnuAct:cCodigo)

IF ISTABMOD("DPDEPRECIAACT")

   DEFINE BITMAP OF OUTLOOK oMnuAct:oOut ;
          BITMAP "BITMAPS\DEPRECIACIONVER.BMP";
          PROMPT "Editar Depreciaciones";
          ACTION  EJECUTAR("DPDEPREC",oMnuAct:cCodSuc,oMnuAct:cCodigo,.T.)
ENDIF

   DEFINE BITMAP OF OUTLOOK oMnuAct:oOut ;
          BITMAP "BITMAPS\contabilizar.BMP";
          PROMPT "Contabilizar";
          ACTION EJECUTAR("BRDEPCONTAB",oMnuAct:cCodSuc,oMnuAct:cCodigo)

   DEFINE BITMAP OF OUTLOOK oMnuAct:oOut ;
          BITMAP "BITMAPS\XPRINT.BMP";
          PROMPT "Imprimir";
          ACTION EJECUTAR("DPFICHAACTIVOS",oMnuAct:cCodigo,NIL,NIL," WHERE ATV_CODSUC"+GetWhere("=",oMnuAct:cCodSuc)+;
                                                                   "   AND ATV_CODIGO"+GetWhere("=",oMnuAct:cCodigo),,,,,,,oMnuAct:cCodSuc)

   DEFINE BITMAP OF OUTLOOK oMnuAct:oOut ;
          BITMAP "BITMAPS\CONTABILIDAD.BMP";
          PROMPT "Cuentas Contables";
          ACTION EJECUTAR("DPACTIVOS_CTA",oMnuAct:cCodigo)

IF oDp:nVersion>=6

   DEFINE BITMAP OF OUTLOOK oMnuAct:oOut ;
          BITMAP "BITMAPS\RECURSOS.BMP";
          PROMPT "Recursor";
          ACTION EJECUTAR("DPESTRUCTORDOCREQM","ATV"+oMnuAct:cCodigo,NIL,oMnuAct:cCodigo,oDp:xDPACTIVOS+" "+ALLTRIM(oMnuAct:cNombre),"ATV",oDp:xDPACTIVOS)

ENDIF

   DEFINE BITMAP OF OUTLOOK oMnuAct:oOut ;
          BITMAP "BITMAPS\XSALIR.BMP";
          PROMPT "Salida";
          ACTION oMnuAct:End()

   DEFINE DIALOG oMnuAct:oDlg FROM 0,oMnuAct:oOut:nWidth() TO oMnuAct:nHeightD,700;
          TITLE "" STYLE WS_CHILD OF oMnuAct:oWnd;
          PIXEL COLOR NIL,oDp:nGris

   @ .1,.2 GROUP oMnuAct:oGrp TO 10,10 PROMPT "Código ["+oMnuAct:cCodigo+"]"

   @ .5,.5 SAY oMnuAct:cNombre SIZE 190,10;
           COLOR CLR_WHITE,12615680;
           FONT oFontBrw

   ACTIVATE DIALOG oMnuAct:oDlg NOWAIT VALID .F.

   oMnuAct:Activate("oMnuAct:FRMINIT()")
 
RETURN

FUNCTION FRMINIT()


   oMnuAct:oWnd:bResized:={||oMnuAct:oDlg:Move(0,0,oMnuAct:oWnd:nWidth(),50,.T.),;
                             oMnuAct:oGrp:Move(0,0,oMnuAct:oWnd:nWidth()-15,oMnuAct:nHeightD,.T.)}

   EVal(oMnuAct:oWnd:bResized)


RETURN .T.

FUNCTION REGAUDITORIA(cConsulta)
RETURN EJECUTAR("AUDITORIA","DCON",.F.,"DPACTIVO",oMnuAct:cCodSuc,NIL,NIL,NIL,NIL,cConsulta)


// EOF


