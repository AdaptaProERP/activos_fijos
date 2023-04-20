// Programa   : DPGRUACTMNU
// Fecha/Hora : 12/01/2011 17:22:34
// Propósito  : Menú Grupo de Activos
// Creado Por : Juan Navas
// Llamado por: DPGRUACTIVOS         Finalizar solo cuando se Modifica
// Aplicación : Tipos de Documentos del Cliente
// Tabla      : DPGRUACTIVOS        

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cCodGru)
   LOCAL cDescri:="",cSql,I,nGroup
   LOCAL oFont,oFontB,oOut,oCursor,oBtn,oBar,oBmp
   LOCAL oBtn,nGroup,bAction,aBtn:={},lReqSca:=.F.

   DEFAULT cCodSuc:=oDp:cSucursal,;
           cCodGru:=SQLGET("DPGRUACTIVOS","GAC_CODIGO")

   cDescri:=SQLGET("DPGRUACTIVOS","GAC_DESCRI","GAC_CODIGO"+GetWhere("=",cCodGru))

   DEFINE FONT oFont    NAME GetSysFont() SIZE 0,-14
   DEFINE FONT oFontB   NAME GetSysFont() SIZE 0,-14 BOLD

   DpMdi(GetFromVar("{oDp:DPGRUACTIVOS        }"),"oGruCtaAct","TEST.EDT")

   oGruCtaAct:cCodGru   :=cCodGru
   oGruCtaAct:cDescri   :=cDescri
   oGruCtaAct:lSalir    :=.F.
   oGruCtaAct:nHeightD  :=45
   oGruCtaAct:lMsgBar   :=.F.
   oGruCtaAct:oGrp      :=NIL

   SetScript("DPGRUACTMNU")

   AADD(aBtn,{"Cuentas Contables"             ,"CONTABILIDAD.BMP"   ,"CUENTAS" }) 
   AADD(aBtn,{"Contabilizar"                  ,"CONTABILIZAR.BMP"   ,"CONTAB"  }) 
   AADD(aBtn,{"Activos"                       ,"ACTIVOS.BMP"        ,"ACTIVOS" }) 


   oGruCtaAct:Windows(0,0,400+150,410+5)

  @ 48, -1 OUTLOOK oGruCtaAct:oOut ;
     SIZE 150+250, oGruCtaAct:oWnd:nHeight()-90;
     PIXEL ;
     FONT oFont ;
     OF oGruCtaAct:oWnd;
     COLOR CLR_BLACK,14085099

   DEFINE GROUP OF OUTLOOK oGruCtaAct:oOut PROMPT "&Procesos  "

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oGruCtaAct:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oGruCtaAct:oOut:aGroup)
      oBtn:=ATAIL(oGruCtaAct:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oGruCtaAct:RUNMNUACTION(["+aBtn[I,3]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oGruCtaAct:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction


   NEXT I

   @ 0, 100 SPLITTER oGruCtaAct:oSpl ;
            VERTICAL ;
            PREVIOUS CONTROLS oGruCtaAct:oOut ;
            LEFT MARGIN 70 ;
            RIGHT MARGIN 200 ;
            SIZE 40, 10  PIXEL ;
            OF oGruCtaAct:oWnd ;
             _3DLOOK ;
            UPDATE

   DEFINE DIALOG oGruCtaAct:oDlg FROM 0,oGruCtaAct:oOut:nWidth() TO oGruCtaAct:nHeightD,700;
          TITLE "Cliente Contado" STYLE WS_CHILD OF oGruCtaAct:oWnd;
          PIXEL COLOR NIL,oDp:nGris

   @ .1,.2 GROUP oGruCtaAct:oGrp TO 10,10 PROMPT "Código ["+oGruCtaAct:cCodGru+"]"

   @ .5,.5 SAY oGruCtaAct:cDescri SIZE 190,10;
           COLOR CLR_WHITE,12615680;
           FONT oFontB

   ACTIVATE DIALOG oGruCtaAct:oDlg NOWAIT VALID .F.

   oGruCtaAct:Activate("oGruCtaAct:FRMINIT()",,"oGruCtaAct:oSpl:AdjRight()")
 
RETURN

FUNCTION FRMINIT()

   oGruCtaAct:oWnd:bResized:={||oGruCtaAct:oDlg:Move(0,0,oGruCtaAct:oWnd:nWidth(),50,.T.),;
                             oGruCtaAct:oGrp:Move(0,0,oGruCtaAct:oWnd:nWidth()-15,oGruCtaAct:nHeightD,.T.)}

   EVal(oGruCtaAct:oWnd:bResized)

RETURN .T.

FUNCTION RUNMNUACTION(cAction)
   LOCAL cWhere:=""

   CursorWait()

   IF cAction="SCANNER"
   ENDIF

   IF cAction="CUENTAS"
      EJECUTAR("DPACTGRU_CTA",oGruCtaAct:cCodGru)
   ENDIF

   IF cAction="ACTIVOS"
      EJECUTAR("BRACTXGRU","ATV_CODGRU"+GetWhere("=",oGruCtaAct:cCodGru))
   ENDIF

   IF cAction="CONTAB"
      EJECUTAR("BRDEPXCONTAB","ATV_CODGRU"+GetWhere("=",oGruCtaAct:cCodGru))
   ENDIF


RETURN .T.
// EOF
