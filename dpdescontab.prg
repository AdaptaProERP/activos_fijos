// Programa   : DPDESCONTAB
// Fecha/Hora : 20/12/2005 19:24:52
// Propósito  : Contabilizar de Depreciación de Activos
// Creado Por : Juan Navas
// Llamado por: DPACTIVOS 
// Aplicación : Ventas
// Tabla      : DPACTIVOS

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cNumCom,cCodSuc,cCodigo,dDesde,dHasta,lAsk)
 
  LOCAL oFontG,cTableTip:="DPTIPDOCCLI",lView:=.T.,lClose:=.F.,oData
  LOCAL cNumero:="NUMERO",lVenta
  LOCAL cNumPag:=""
  LOCAL cTipTra:="D"

  DEFAULT cCodSuc:=oDp:cSucursal,;
          dDesde :=FCHFINMES(oDp:dFecha),;
          dHasta :=FCHFINMES(oDp:dFecha),;
          cNumCom:=STRZERO(1,08),;
          lAsk   :=.T.          ,;
          lVenta :=.T.          ,;
          cCodigo:=SQLGET("DPACTIVOS","ATV_CODIGO")

  IF !lAsk

    RUNASIENTO(cNumCom,cCodSuc,cCodigo,dDesde,dHasta)

  ELSE

    oData:=DATASET("DEPACTCONTAB","ALL")

    lClose:=oData:Get("CLOSE",.T.)
    lView :=oData:Get("VIEW" ,.T.)

    oData:End()

    DPEDIT():New("Des-Contabilizar Depreciación de Activos","DPDESCBTE.EDT","oDesAct",.T.)

    oDesAct:cTableTip:="DPDEPRECIAACT"
    oDesAct:cNumCom  :=oDp:cNumCom
    oDesAct:cCodSuc  :=cCodSuc
    oDesAct:cNumero  :=cNumero
    oDesAct:cCodigo  :=cCodigo
    oDesAct:cTipDoc  :="GIR"
    oDesAct:lVenta   :=lVenta
    oDesAct:lView    :=lView
    oDesAct:lClose   :=lClose
    oDesAct:cResp    :="Activo sin Contabilizar"
    oDesAct:cTipTra  :=cTipTra
    oDesAct:lMsgBar  :=.F.
    oDesAct:dDesde   :=dDesde 
    oDesAct:dHasta   :=dHasta 
    oDesAct:lOk      :=.T.
    oDesAct:nCuantos :=0

    @ 1, 1.0 GROUP oDesAct:oGroup TO 11.4,6 PROMPT " Activo ";
             FONT oFontG

    @ 06, 1.0 GROUP oDesAct:oGroup TO 09.4,6 PROMPT " Periodo ";
             FONT oFontG

    @ 1, 1.0 GROUP oDesAct:oGroup TO 11.4,6 PROMPT " Proceso ";
             FONT oFontG

    @ 1,1 SAY "Nombre:" RIGHT
    @ 2,1 SAY "Código:" RIGHT
    @ 3,1 SAY "Desde :" RIGHT

    @ 1,10 SAY MYSQLGET("DPACTIVOS","ATV_DESCRI","ATV_CODIGO"+GetWhere("=",oDesAct:cCodigo)) 
    @ 2,10 SAY oDesAct:cCodigo 
    @ 3,10 SAY "Hasta:" RIGHT

    @ 4,10 SAY oDesAct:oResp;
               PROMPT oDesAct:cResp

   @ 6,1 BMPGET oDesAct:oDesde VAR oDesAct:dDesde;
                PICTURE "99/99/9999";
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDesAct:oDesde ,oDesAct:dDesde);
                SIZE 41,10

   @ 6,8 BMPGET oDesAct:oHasta VAR oDesAct:dHasta;
                PICTURE "99/99/9999";
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDesAct:oHasta ,oDesAct:dHasta);
                SIZE 41,10

    @ 6.4, 1.0 CHECKBOX oDesAct:oClose;
                      VAR oDesAct:lClose;
                      PROMPT ANSITOOEM("Cerrar al Finalizar")

    @05, 13  SBUTTON oDesAct:oRun ;
             SIZE 42, 23 FONT oFontG;
             FILE "BITMAPS\RUN.BMP" ;
             LEFT PROMPT "Ejecutar";
             NOBORDER;
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oDesAct:RUNASIENTO(oDesAct:cNumCom,oDesAct:cCodSuc,oDesAct:cCodigo,oDesAct:dDesde,;
                                         oDesAct:dHasta,oDesAct),;
                     IIF(oDesAct:lOk ,  oDesAct:RUNSAVE() , NIL ))

    @05, 13  SBUTTON oDesAct:oClose ;
             SIZE 42, 23 FONT oFontG;
             FILE "BITMAPS\XSALIR.BMP" ;
             LEFT PROMPT "Cerrar";
             NOBORDER;
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION oDesAct:Close() CANCEL


    @ 2,2 METER oDesAct:oMeter VAR oDesAct:nCuantos

    oDesAct:Activate(NIL)

  ENDIF

RETURN .T.

FUNCTION RUNASIENTO(cNumCom , cCodSuc , cCodigo , dDesde , dHasta , oDesAct)
  LOCAL cWhere,oTable,cSql,cDescri,nCuantos:=0
  LOCAL cTipDoc  :="ACT"
  LOCAL nMonto   :=0
  LOCAL cOrg     :="ACT"
  LOCAL cNumPag  :=""
  LOCAL cTipTra  :="D"
  LOCAL cTipDoc  :="DEP"
  LOCAL cCtaAct  :="" // Depreciación Activo
  LOCAL cCtaDep  :="" // Depreciación Gasto

  CursorWait()

  IF ValType(oDesAct)="O"
     oDesAct:lOk:=.T.
  ENDIF

  cWhere:="ATV_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
          "ATV_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
          "DEP_ESTADO='C' AND "+;
          GetWhereAnd("DEP_FECHA",dDesde,dHasta)


  oTable:=OpenTable(" SELECT * FROM DPACTIVOS "+;
                    " INNER JOIN DPDEPRECIAACT ON ATV_CODIGO=DEP_CODACT "+;
                    " WHERE "+cWhere,.T.)

  oDesAct:oMeter:SetTotal(oTable:RecCount())

  WHILE !oTable:Eof()

      cDescri:=oTable:ATV_DESCRI
      cCtaAct:=oTable:ATV_CTAACU
      cCtaDep:=oTable:ATV_CTAACU
      cCodigo:=oTable:ATV_CODIGO
      nMonto :=oTable:DEP_MONTO
      cNumPag:=oTable:DEP_NUMERO

      oDesAct:oMeter:Set(oTable:RecNo())

      IF !Empty(oTable:DEP_COMPRO) // Borra el Asiento Anterior

        SQLDELETE("DPASIENTOS","MOC_NUMCBT"+GetWhere("=",oTable:DEP_COMPRO)+" AND "+;
                               "MOC_FECHA "+GetWhere("=",oTable:DEP_FECHA )+" AND "+;
                               "MOC_TIPO  "+GetWhere("=",cTipDoc          )+" AND "+;
                               "MOC_DOCUME"+GetWhere("=",oTable:DEP_CODACT)+" AND "+;
                               "MOC_DOCPAG"+GetWhere("=",oTable:DEP_NUMERO)+" AND "+;
                               "MOC_CODSUC"+GetWhere("=",cCodSuc          )+" AND "+;
                               "MOC_ACTUAL"+GetWhere("=","N"              )+" AND "+;       
                               "MOC_TIPTRA"+GetWhere("=",cTipTra          )+" AND "+;
                               "MOC_ORIGEN"+GetWhere("=",cOrg             ))            

        // Ahora lo Busca

        IF MYCOUNT("DPASIENTOS","MOC_NUMCBT"+GetWhere("=",oTable:DEP_COMPRO)+" AND "+;
                                "MOC_FECHA "+GetWhere("=",oTable:DEP_FECHA )+" AND "+;
                                "MOC_TIPO  "+GetWhere("=",cTipDoc          )+" AND "+;
                                "MOC_DOCUME"+GetWhere("=",oTable:DEP_CODACT)+" AND "+;
                                "MOC_DOCPAG"+GetWhere("=",oTable:DEP_NUMERO)+" AND "+;
                                "MOC_CODSUC"+GetWhere("=",cCodSuc          )+" AND "+;
                                "MOC_ACTUAL"+GetWhere("=","N"              )+" AND "+;       
                                "MOC_TIPTRA"+GetWhere("=",cTipTra          )+" AND "+;
                                "MOC_ORIGEN"+GetWhere("=",cOrg             ))>0
           nCuantos++

        ENDIF

      ENDIF

      cWhere:="DEP_CODACT"+GetWhere("=",oTable:DEP_CODACT)+" AND "+;
              "DEP_FECHA" +GetWhere("=",oTable:DEP_FECHA )+" AND "+;
              "DEP_NUMERO"+GetWhere("=",oTable:DEP_NUMERO)

      SQLUPDATE("DPDEPRECIAACT",{"DEP_ESTADO","DEP_COMPRO","DEP_FCHCON"},{"A",cNumCom,oDp:dFecha},cWhere)

      nCuantos++

	IF ValType(oDesAct)="O"
         oDesAct:cResp:="Des-Contabilizado Depreciación Periodo "+DTOC(oTable:DEP_FECHA)
         oDesAct:oResp:Refresh(.T.)
      ENDIF

      oTable:DbSkip()

   ENDDO

   IF oTable:RecCount()=0
       MensajeErr("No hay Depreciaciones Contabilizadas")
   ENDIF

   oTable:End()

   IF nCuantos=0 .AND. ValType(oDesAct)="O"
     oDesAct:cResp:="Depreciación no Des-Contabilizada"
     oDesAct:oResp:Refresh(.T.)
     oDesAct:lOk:=.F.
   ENDIF

RETURN nCuantos>0

FUNCTION RUNSAVE()
  LOCAL oData

  oDesAct:cResp:="Activo Contabilizado Exitosamente"
  oDesAct:oResp:Refresh(.T.)

  oData:=DATASET("DEPACTCONTAB","ALL")

  oData:Set("CLOSE",oDesAct:lClose)
  oData:Set("VIEW" ,oDesAct:lView )

  oData:Save()
  oData:End()

  IF oDesAct:lView

     EJECUTAR("DPDEPREC", NIL ,oDesAct:cCodigo,.F.)

  ENDIF

  IF oDesAct:lClose   
     oDesAct:Close()
  ENDIF

RETURN .T.



