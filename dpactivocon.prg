// Programa   : DPACTIVOCON
// Fecha/Hora : 29/06/2006 05:39:22
// Propósito  : Consultar los Datos del Activo
// Creado Por : Juan Navas
// Llamado por: DPACTIVO
// Aplicación : Activos
// Tabla      : DPACTIVOS

#INCLUDE "DPXBASE.CH"
#include "outlook.ch"
#include "splitter.Ch"

PROCE MAIN(oFrm,cCodigo)
   LOCAL aTipDocV:={},aTipDocC:={},aTipDoc:={},aData,cWhere
   LOCAL oFont,oOut,oSpl,oCursor,oBar,oBtn,oBar,aData:={},oBrw,I,oBmp,oFontBrw,nGroup,bAction,cTitle
   LOCAL cNombre
   LOCAL cCodSuc:=oDp:cSucursal

   DEFAULT cCodigo:=SQLGET("DPACTIVOS","ATV_CODIGO")

   IF ValType(oFrm)="O"
     cCodigo:=oFrm:ATV_CODIGO
     cCodSuc:=oFrm:ATV_CODSUC
   ENDIF

   cNombre:=SQLGET("DPACTIVOS","ATV_DESCRI","ATV_CODIGO"+GetWhere("=",cCodigo))

   DEFINE FONT oFont    NAME GetSysFont() SIZE 0,-14
   DEFINE FONT oFontBrw NAME "MS Sans Serif" SIZE 0,-10 BOLD

   cTitle:="Consulta "+GetFromVar("{oDp:xDPACTIVOS}")

   DpMdi(cTitle,"oMdiAct","TEST.EDT")

   oMdiAct:cCodigo   :=cCodigo
   oMdiAct:cCodSuc   :=cCodSuc
   oMdiAct:cNombre   :=cNombre
   oMdiAct:lSalir    :=.F.
   oMdiAct:nHeightD  :=45
   oMdiAct:cTitle    :=cTitle
   oMdiAct:lMsgBar   :=.F.
   oMdiAct:oFrm      :=oFrm

   SetScript("DPACTIVOSCON")

   oMdiAct:Windows(0,0,400+70,410)

  @ 48, -1 OUTLOOK oMdiAct:oOut ;
     SIZE 150+250, oMdiAct:oWnd:nHeight()-85 ;
     PIXEL ;
     FONT oFont ;
     OF oMdiAct:oWnd;
     COLOR CLR_BLACK,15400703

   oMdiAct:aData:=ACLONE(aData)

   DEFINE GROUP OF OUTLOOK oMdiAct:oOut PROMPT "&Consulta"

   DEFINE BITMAP OF OUTLOOK oMdiAct:oOut ;
          BITMAP "BITMAPS\CONTABILIDAD.BMP";
          PROMPT "Ver Asientos Contables";
          ACTION (oMdiAct:REGAUDITORIA("Asientos Contables"),;
                  EJECUTAR("DPACTVIEWCON",oMdiAct:cCodSuc,oMdiAct:cCodigo))

   DEFINE BITMAP OF OUTLOOK oMdiAct:oOut ;
          BITMAP "BITMAPS\DEPRECIACIONVER.BMP";
          PROMPT "Depreciaciones";
          ACTION (oMdiAct:REGAUDITORIA("Depreciaciones"),;
                  EJECUTAR("DPDEPREC",oMdiAct:cCodSuc,oMdiAct:cCodigo,.F.))

   DEFINE BITMAP OF OUTLOOK oMdiAct:oOut ;
          BITMAP "BITMAPS\AXIFIS.BMP";
          PROMPT "Cédula Ajuste Fiscal";
          ACTION EJECUTAR("BRAXIFISCED",oMdiAct:cCodigo)

   DEFINE BITMAP OF OUTLOOK oMdiAct:oOut ;
         BITMAP "BITMAPS\AUDITORIA.BMP" ;
         PROMPT "Auditoria del Registro" ;
         ACTION EJECUTAR("VIEWAUDITOR","DPACTIVOS",oMdiAct:cCodigo,oMdiAct:cNombre)

IF oDp:nVersion>=6

   DEFINE BITMAP OF OUTLOOK oMdiAct:oOut ;
          BITMAP "BITMAPS\AUDITORIA.BMP" ;
          PROMPT "Auditoria por Campo" ;
          ACTION  EJECUTAR("DPAUDITAEMC",oMdiAct:oFrm,"DPACTIVOS","DPACTIVOS.SCG",oMdiAct:cCodigo,oMdiAct:cNombre,"ATV_CODIGO"+;
                                         GetWhere("=",oMdiAct:cCodigo))

ENDIF


   DEFINE BITMAP OF OUTLOOK oMdiAct:oOut ;
          BITMAP "BITMAPS\XSALIR.BMP";
          PROMPT "Salida";
          ACTION oMdiAct:End()


   DEFINE DIALOG oMdiAct:oDlg FROM 0,oMdiAct:oOut:nWidth() TO oMdiAct:nHeightD,700;
          TITLE "" STYLE WS_CHILD OF oMdiAct:oWnd;
          PIXEL COLOR NIL,oDp:nGris

   @ .1,.2 GROUP oMdiAct:oGrp TO 10,10 PROMPT "Código ["+oMdiAct:cCodigo+"]"

   @ .5,.5 SAY oMdiAct:cNombre SIZE 190,10;
           COLOR CLR_WHITE,12615680;
           FONT oFontBrw

   ACTIVATE DIALOG oMdiAct:oDlg NOWAIT VALID .F.

   oMdiAct:Activate("oMdiAct:FRMINIT()")

 
RETURN

FUNCTION FRMINIT()


   oMdiAct:oWnd:bResized:={||oMdiAct:oDlg:Move(0,0,oMdiAct:oWnd:nWidth(),50,.T.),;
                             oMdiAct:oGrp:Move(0,0,oMdiAct:oWnd:nWidth()-15,oMdiAct:nHeightD,.T.)}

   EVal(oMdiAct:oWnd:bResized)


RETURN .T.

FUNCTION REGAUDITORIA(cConsulta)
RETURN EJECUTAR("AUDITORIA","DCON",.F.,"DPACTIVO",oMdiAct:cCodigo,NIL,NIL,NIL,NIL,cConsulta)


// EOF



