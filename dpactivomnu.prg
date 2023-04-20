// Programa   : DPACTIVOMNU
// Fecha/Hora : 07/06/2005 15:43:33
// Prop¢sito  : Menú Finalización de Giros
// Creado Por : JN
// Llamado por: DPACTIVOS
// Aplicación : Ventas  
// Tabla      : DPACTIVOS


#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cCodAct,oForm)
   LOCAL oBtn,oFontB,nAlto:=24-4,nAncho:=120+20,aBtn:={},I,nLin:=0,nHeight,nOption:=0,lContab:=.F.
   LOCAL cNomDeb :=""
   LOCAL cFilBmp :="DOCCXC.BMP"
   LOCAL cNomDoc :="Activo"
   LOCAL cTipoAct:=""
   LOCAL nContab :=0
   LOCAL nDesinc :=0

   DEFAULT cCodSuc:=oDp:cSucursal,;
           cCodAct:=STRZERO(1,5)

   cTipoAct:=MYSQLGET("DPACTIVOS","ATV_DEPRE","ATV_CODIGO"+GetWhere("=",cCodAct))

   nContab:=MYCOUNT("DPDEPRECIAACT","DEP_CODACT"+GetWhere("=",cCodAct)+" AND "+;
                                    "DEP_ESTADO='C'")

   nDesinc:=MYCOUNT("DPDEPRECIAACT","DEP_CODACT"+GetWhere("=",cCodAct)+" AND "+;
                                    "DEP_ESTADO='D'")

   SysRefresh(.T.)

   IF ValType(oForm)="O"
     nOption:=oForm:nOption
     cCodSuc:=oForm:ATV_CODSUC
   ENDIF

   IF cTipoAct="D"

     IF nContab=0 .AND. nDesinc=0
       AADD(aBtn,{"Calcular Depreciación   " ,"depreciacion.BMP" ,"CALC"  }) 
     ENDIF

     AADD(aBtn,{"Visualizar Depreciación " ,"depreciacionver.bmp" ,"DEPREC"})
     AADD(aBtn,{"Contabilizar "            ,"contabilizar.BMP" ,"CONTAB"})

     IF nContab>0
       AADD(aBtn,{"DesContabilizar "         ,"descontabilizar.BMP","DESCONTAB"})
     ENDIF

     AADD(aBtn,{"Desincorporación "         ,"desincorporacion.BMP","DESINC"})

   ENDIF

   AADD(aBtn,{"Imprimir "                ,"XPRINT.BMP"      ,"PRINT" })
   AADD(aBtn,{"Salir "                   ,"XSALIR.BMP"      ,"EXIT"  })

   DEFINE FONT oFontB  NAME "MS Sans Serif" SIZE 0, -10 BOLD

   oDpActMnu:=DPEDIT():New(cNomDoc,NIL,"oDpActMnu",.F.)
   oDpActMnu:cCodSuc :=cCodSuc
   oDpActMnu:cCodAct :=cCodAct
   oDpActMnu:oForm   :=oForm
   oDpActMnu:cNomDoc :=cNomDoc
   oDpActMnu:nOption :=nOption
   oDpActMnu:lMsgBar :=.F.
   oDpActMnu:aBtn    :=ACLONE(aBtn)
   oDpActMnu:nCrlPane:=16772810
   oDpActMnu:lContab :=lContab
   oDpActMnu:cNomDoc:=cNomDoc

   nHeight:=35+((Len(aBtn)+1)*(nAlto*2))
   oDpActMnu:CreateWindow(nil,70,1,nHeight,(nAncho*2)+12)
   oDpActMnu:oDlg:SetColor(NIL,oDpActMnu:nCrlPane)

   nLin   :=nAlto

   FOR I=1 TO LEN(aBtn)
 
     @nLin, 01 SBUTTON oBtn OF oDpActMnu:oDlg;
               SIZE nAncho,nAlto-1.5;
               FONT oFontB;	
               FILE "BITMAPS\"+aBtn[I,2] ;
               PROMPT PADR(aBtn[I,1],26);
               NOBORDER;
               ACTION 1=1;
               PIXEL;
               COLORS CLR_BLUE, {CLR_WHITE, oDpActMnu:nCrlPane, 1 }

      oBtn:bAction:=BloqueCod("oDpActMnu:DOCPRORUN(["+aBtn[I,3]+"])")

      nLin:=nLin+nAlto

   NEXT I

   @ .0,1 GROUP oDpActMnu:oGrupo1 TO nAlto-2, nAncho PROMPT "" PIXEL;
          COLOR NIL,oDpActMnu:nCrlPane

   @ .4,1 SAY "Código:" SIZE 50,10;
          COLOR CLR_BLUE,oDpActMnu:nCrlPane

   @ .4,6 SAY oDpActMnu:cCodAct SIZE 60,10;
          COLOR CLR_HRED,oDpActMnu:nCrlPane
  
   oDpActMnu:Activate({||DOCPROMNUINI()})

RETURN .T.

/*
// Iniciaci¢n
*/
FUNCTION DOCPROMNUINI()

    oBtn:=oDpActMnu:oDlg:aControls[1]
    oDpActMnu:oWnd:Move(0,0)
    DPFOCUS(oBtn)
    SysRefresh(.T.)

RETURN .T.

/*
// Ejecutar
*/
FUNCTION DOCPRORUN(cAction)
  LOCAL oForm :=oDpActMnu:oForm,cWhere,lEdit:=.T.,oRep
  LOCAL nMonto:=0,lResp:=.F.

  IF ValType(oForm)="O" .AND. oForm:oWnd:hWnd=0
     oForm:=NIL
     lEdit:=.F.
  ENDIF

  IF cAction="EXIT"

     oDpActMnu:Close()

     IF ValType(oForm)="O" .AND. ValType(oForm:oDlg)="O" .AND. oForm:oDlg:hWnd>0
        DpFocus(oForm:oDlg)
     ENDIF

     RETURN .T.

  ENDIF


  IF cAction="CALC"

     nMonto:=MYSQLGET("DPDEPRECIAACT","SUM(DEP_MONTO)","DEP_CODACT"+GetWhere("=",oDpActMnu:cCodAct))

     IF nMonto>0 .AND. !MsgYesNo("Desea Recalcular Depreciación","Seleccione una Opción")
        RETURN .F.
     ENDIF

     MsgRun("Calculando Depreciación","Por Favor Espere",;
            {||lResp:=EJECUTAR("DPDEPRECCALC",oDpActMnu:cCodSuc,oDpActMnu:cCodAct,.T.)})

    cAction:="DEPREC"

  ENDIF


  IF cAction="DEPREC"


     nMonto:=MYSQLGET("DPDEPRECIAACT","SUM(DEP_MONTO)","DEP_CODACT"+GetWhere("=",oDpActMnu:cCodAct))

     IF nMonto=0 

        MsgRun("Calculando Depreciación","Por Favor Espere",;
               {||lResp:=EJECUTAR("DPDEPRECCALC",oDpActMnu:cCodSuc,oDpActMnu:cCodAct)})

       IF !lResp
          MensajeErr(oDp:cMsgAct,GetFromVar("{oDp:xDPACTIVOS}")+" "+oDpActMnu:cCodAct)
          RETURN .F.
       ENDIF

     ENDIF

     EJECUTAR("DPDEPREC",oDpActMnu:cCodSuc, oDpActMnu:cCodAct)

  ENDIF

  IF cAction="PRINT"

    EJECUTAR("DPFICHAACTIVOS",oDpActMnu:cCodAct,NIL,NIL," WHERE ATV_CODSUC"+GetWhere("=",oDpActMnu:cCodSuc)+;
                                                        "   AND ATV_CODIGO"+GetWhere("=",oDpActMnu:cCodAct),,,,,,,oDpActMnu:cCodSuc)

  ENDIF

  IF cAction="CONTAB"

     EJECUTAR("DPACTCONTAB", NIL,oDpActMnu:cCodSuc,;
                                 oDpActMnu:cCodAct,;
                                 NIL,NIL,.T.)
  ENDIF


  IF cAction="DESCONTAB"

     EJECUTAR("DPDESCONTAB", NIL,oDpActMnu:cCodSuc,;
                                 oDpActMnu:cCodAct,;
                                 NIL,NIL,.T.)
  ENDIF

  IF cAction="DESINC"

     EJECUTAR("DPDESINCORPACT", 0, oDpActMnu:cCodAct)

  ENDIF


RETURN .T.

FUNCTION MNUCERRAR()
   LOCAL oForm:=oDpActMnu:oForm

   oDpActMnu:Close()

   IF ValType(oForm)="O" .AND. ValType(oForm:oDlg)="O" .AND. oForm:oDlg:hWnd>0
      DpFocus(oForm:oDlg)
   ENDIF

RETURN .T.

// EOF






