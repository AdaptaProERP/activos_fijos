// Programa   : DPACTCONTAB
// Fecha/Hora : 20/12/2005 19:24:52
// Propósito  : Contabilizar de Depreciación de Activos
// Creado Por : Juan Navas
// Llamado por: DPACTIVOS 
// Aplicación : Ventas
// Tabla      : DPACTIVOS
// 06-08-2008  Inclusion de Asignacion de Numero Cbte desde DPNUMCBTE
// 08-08-2008  Llamado Programa DPDELCBTEV a fin de Borrar DPCBTE si queda sin Detalle en DPASIENTOS
// 12-08-2008  Inclusion de variable oDp:lNumcom a fin de agrupar o no asientos por modulo
#INCLUDE "DPXBASE.CH"

PROCE MAIN(cNumCom,cCodSuc,cCodigo,dDesde,dHasta,lAsk)
 
  LOCAL oFontG,cTableTip:="DPTIPDOCCLI",lView:=.T.,lClose:=.F.,oData
  LOCAL cNumero:="NUMERO",lVenta
  LOCAL cNumPag:=""
  LOCAL cTipTra:="D"

  DEFAULT cCodSuc:=oDp:cSucursal,;
          dDesde :=FCHFINMES(oDp:dFecha),;
          dHasta :=FCHFINMES(oDp:dFecha),;
          cNumCom:=oDp:cNumCom,;
          lAsk   :=.T.          ,;
          lVenta :=.T.          ,;
          cCodigo:=SQLGETMAX("DPACTIVOS","ATV_CODIGO"),;
          oDp:lNumCom:= .F.

  IF oDp:lNumCom 
     cNumCom :=EJECUTAR("DPNUMCBTE","ACTFIJ")
  ENDIF

  IF !lAsk

    RUNASIENTO(cNumCom,cCodSuc,cCodigo,dDesde,dHasta)

  ELSE

    oData:=DATASET("DEPACTCONTAB","ALL")

    lClose:=oData:Get("CLOSE",.T.)
    lView :=oData:Get("VIEW" ,.T.)

    oData:End()

    dDesde:=SQLGETMIN("DPDEPRECIAACT","DEP_FECHA","DEP_CODACT"+GetWhere("=",cCodigo)+" AND DEP_ESTADO='A'")

    // Busca la Fecha de las Desincorporaciones
    IF Empty(dDesde)
      dDesde:=SQLGETMAX("DPDESINCORPACT","DAC_FECHA","DAC_CODIGO"+GetWhere("=",cCodigo)+" AND DAC_TIPO='T'")
    ENDIF

    dDesde:=IIF( Empty(dDesde) , oDp:dFecha , dDesde )
    dDesde:=FCHINIMES(dDesde)
    dHasta:=FCHFINMES(dDesde)

    DPEDIT():New("Contabilizar Depreciación y Desincorporaciones","DPACTCBTE.EDT","oRunCbte",.T.)

    oRunCbte:cTableTip:="DPDEPRECIAACT"
    oRunCbte:cNumCom  :=cNumCom
    oRunCbte:cCodSuc  :=cCodSuc
    oRunCbte:cNumero  :=cNumero
    oRunCbte:cCodigo  :=cCodigo
    oRunCbte:cTipDoc  :="GIR"
    oRunCbte:lVenta   :=lVenta
    oRunCbte:lView    :=lView
    oRunCbte:lClose   :=lClose
    oRunCbte:cResp    :="Activo sin Contabilizar"
    oRunCbte:cTipTra  :=cTipTra
    oRunCbte:lMsgBar  :=.F.
    oRunCbte:dDesde   :=dDesde 
    oRunCbte:dHasta   :=dHasta 
    oRunCbte:lOk      :=.T.

    @ 1, 1.0 GROUP oRunCbte:oGroup TO 11.4,6 PROMPT " Activo ";
             FONT oFontG

    @ 1, 1.0 GROUP oRunCbte:oGroup TO 11.4,6 PROMPT " Comprobante ";
             FONT oFontG

    @ 1, 1.0 GROUP oRunCbte:oGroup TO 11.4,6 PROMPT " Proceso ";
             FONT oFontG

    @ 06, 1.0 GROUP oRunCbte:oGroup TO 09.4,6 PROMPT " Periodo ";
             FONT oFontG

    @ 0,0 SAY "Número:" RIGHT

    @ 1,1 SAY "Nombre:"   RIGHT
    @ 2,1 SAY "Código:" RIGHT
    @ 3,1 SAY "Desde :" RIGHT

    @ 1,10 SAY MYSQLGET("DPACTIVOS","ATV_DESCRI","ATV_CODIGO"+GetWhere("=",oRunCbte:cCodigo)) 
    @ 2,10 SAY oRunCbte:cCodigo RIGHT
    @ 3,10 SAY "Hasta:" RIGHT

    @ 4,10 SAY oRunCbte:oResp;
               PROMPT oRunCbte:cResp

    @ 1,1 GET oRunCbte:oNumero VAR oRunCbte:cNumCom;
          RIGHT;
          VALID CERO(oRunCbte:cNumCom)

   @ 6,1 BMPGET oRunCbte:oDesde VAR oRunCbte:dDesde;
                PICTURE "99/99/9999";
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oRunCbte:oDesde ,oRunCbte:dDesde);
                SIZE 41,10

   @ 6,8 BMPGET oRunCbte:oHasta VAR oRunCbte:dHasta;
                PICTURE "99/99/9999";
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oRunCbte:oHasta ,oRunCbte:dHasta);
                SIZE 41,10

    @ 6.4, 1.0 CHECKBOX oRunCbte:oView;
                      VAR oRunCbte:lView;
                      PROMPT ANSITOOEM("Visualizar")

    @ 6.4, 1.0 CHECKBOX oRunCbte:oClose;
                      VAR oRunCbte:lClose;
                      PROMPT ANSITOOEM("Cerrar al Finalizar")

    @05, 13  SBUTTON oRunCbte:oRun ;
             SIZE 42, 23 FONT oFontG;
             FILE "BITMAPS\RUN.BMP" ;
             LEFT PROMPT "Ejecutar";
             NOBORDER;
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oRunCbte:RUNASIENTO(oRunCbte:cNumCom,oRunCbte:cCodSuc,oRunCbte:cCodigo,oRunCbte:dDesde,;
                                         oRunCbte:dHasta,oRunCbte),;
                     IIF(oRunCbte:lOk ,  oRunCbte:RUNSAVE() , NIL ))

    @05, 13  SBUTTON oRunCbte:oClose ;
             SIZE 42, 23 FONT oFontG;
             FILE "BITMAPS\XSALIR.BMP" ;
             LEFT PROMPT "Cerrar";
             NOBORDER;
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION oRunCbte:Close() CANCEL

    oRunCbte:Activate(NIL)

  ENDIF

RETURN .T.

FUNCTION RUNASIENTO(cNumCom , cCodSuc , cCodigo , dDesde , dHasta ,oRunCbte)
  LOCAL cWhere,oTable,cSql,cDescri,nCuantos:=0,oActivo
  LOCAL cTipDoc  :="ACT"
  LOCAL nMonto   :=0
  LOCAL cOrg     :="ACT"
  LOCAL cNumPag  :=""
  LOCAL cTipTra  :="D"
  LOCAL cTipDoc  :="DEP"
  LOCAL cCtaAct  :="" // Depreciación Activo
  LOCAL cCtaDep  :="" // Depreciación Gasto
  LOCAL cWhereA 

  CursorWait()

  IF ValType(oRunCbte)="O"
     oRunCbte:lOk:=.T.
  ENDIF

/*
  cWhere:="ATV_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
          "ATV_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
          "DEP_ESTADO='A' AND "+;
          GetWhereAnd("DEP_FECHA",dDesde,dHasta)
*/

  cWhere:="ATV_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
          "ATV_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
          GetWhereAnd("DEP_FECHA",dDesde,dHasta)

  cWhereA:=cWhere

  oTable:=OpenTable(" SELECT * FROM DPACTIVOS "+;
                    " INNER JOIN DPDEPRECIAACT ON ATV_CODIGO=DEP_CODACT "+;
                    " WHERE "+cWhere,.T.)

// oTable:Browse()
// ? CLPCOPY(oTable:cSql)

  WHILE !oTable:Eof()

      cDescri:=oTable:ATV_DESCRI
      cCtaAct:=oTable:ATV_CTAACU
      cCtaDep:=oTable:ATV_CTADEP
      cCodigo:=oTable:ATV_CODIGO
      nMonto :=oTable:DEP_MONTO
      cNumPag:=oTable:DEP_NUMERO

      IF !Empty(oTable:DEP_COMPRO) // Borra el Asiento Anterior

// ? "AQUI DEBE BORRAR"
        SQLDELETE("DPASIENTOS","MOC_NUMCBT"+GetWhere("=",oTable:DEP_COMPRO)+" AND "+;
                               "MOC_FECHA "+GetWhere("=",oTable:DEP_FECHA )+" AND "+;
                               "MOC_TIPO  "+GetWhere("=",cTipDoc          )+" AND "+;
                               "MOC_DOCUME"+GetWhere("=",oTable:DEP_CODACT)+" AND "+;
                               "MOC_DOCPAG"+GetWhere("=",oTable:DEP_NUMERO)+" AND "+;
                               "MOC_CODSUC"+GetWhere("=",cCodSuc          )+" AND "+;
                               "MOC_ACTUAL"+GetWhere("=","N"              )+" AND "+;       
                               "MOC_TIPTRA"+GetWhere("=",cTipTra          )+" AND "+;
                               "MOC_ORIGEN"+GetWhere("=",cOrg             ))    

//? CLPCOPY(oDp:cSql)        

      ENDIF

      EJECUTAR("DPMOCNUMPAR","N",oTable:DEP_FECHA,cNumCom,cCodSuc)

      EJECUTAR("DPDELCBTEV")

      // Gasto
      EJECUTAR("ASIENTOCREA",cCodSuc,cNumCom,oTable:DEP_FECHA,cOrg,cCtaDep,cTipDoc,oTable:ATV_CODIGO,cDescri,nMonto ,cCodigo,cTipTra,cNumPag,oTable:ATV_CENCOS)

      // Depreciación Activo
      nMonto :=oTable:DEP_MONTO*-1

      EJECUTAR("ASIENTOCREA",cCodSuc,cNumCom,oTable:DEP_FECHA,cOrg,cCtaAct,cTipDoc,oTable:ATV_CODIGO,cDescri,nMonto ,cCodigo,cTipTra,cNumPag,oTable:ATV_CENCOS)

      cWhere:="DEP_CODACT"+GetWhere("=",oTable:DEP_CODACT)+" AND "+;
              "DEP_FECHA" +GetWhere("=",oTable:DEP_FECHA )+" AND "+;
              "DEP_NUMERO"+GetWhere("=",oTable:DEP_NUMERO)

     SQLUPDATE("DPDEPRECIAACT",{"DEP_COMPRO","DEP_FCHCON","DEP_ESTADO","DEP_NUMPAR"},{cNumCom,oDp:dFecha,"C",oDp:cPartida},cWhere)

    
//   ? CLPCOPY(oDp:cSql)

      nCuantos++

	IF ValType(oRunCbte)="O"
         oRunCbte:cResp:="Contabilizado Depreciación Periodo "+DTOC(oTable:DEP_FECHA)
         oRunCbte:oResp:Refresh(.T.)
     ENDIF

     oTable:DbSkip()

   ENDDO

   oTable:End()

   // Ahora Busca las Desincorporaciones
   oTable:=OpenTable("SELECT * FROM DPDESINCORPACT WHERE DAC_CODIGO"+GetWhere("=",cCodigo )+ " AND "+;
                     GetWhereAnd("DAC_FECHA", dDesde , dHasta ),.T.)

   cTipDoc  :="DES"

   WHILE !oTable:Eof()


      IF !Empty(oTable:DAC_NUMCBT) // Borra el Asiento Anterior

        SQLDELETE("DPASIENTOS","MOC_NUMCBT"+GetWhere("=",oTable:DAC_NUMCBT)+" AND "+;
                               "MOC_FECHA "+GetWhere("=",oTable:DAC_FECHA )+" AND "+;
                               "MOC_TIPO  "+GetWhere("=",cTipDoc          )+" AND "+;
                               "MOC_DOCUME"+GetWhere("=",oTable:DAC_CODIGO)+" AND "+;
                               "MOC_DOCPAG"+GetWhere("=",oTable:DAC_NUMERO)+" AND "+;
                               "MOC_CODSUC"+GetWhere("=",cCodSuc          )+" AND "+;
                               "MOC_ACTUAL"+GetWhere("=","N"              )+" AND "+;       
                               "MOC_TIPTRA"+GetWhere("=",cTipTra          )+" AND "+;
                               "MOC_ORIGEN"+GetWhere("=",cOrg             ))            

      ENDIF


      oActivo:=OpenTable(" SELECT * FROM DPACTIVOS WHERE ATV_CODIGO "+GetWhere("=",cCodigo),.T.)

      cDescri:="Desincorporación "+ALLTRIM(oActivo:ATV_DESCRI)
      cCtaAct:=oActivo:ATV_CTAACU
      cCtaDep:=oActivo:ATV_CTADEP
      cCodSuc:=oActivo:ATV_CODSUC

      cNumPag:=oTable:DAC_NUMERO

      nMonto:=MYSQLGET("DPDEPRECIAACT","SUM(DEP_MTOORG)","DEP_CODACT"+GetWhere("=",cCodigo          )+" AND "+;
                                                         "DEP_NUMDES"+GetWhere("=",oTable:DAC_NUMERO)+" AND "+;
                                                         "DEP_ESTADO='D'")
      // Asiento del Gasto
      EJECUTAR("ASIENTOCREA",cCodSuc,cNumCom,otable:DAC_FECHA,cOrg,cCtaDep,cTipDoc,oActivo:ATV_CODIGO,cDescri,nMonto ,cCodigo,cTipTra,cNumPag,oActivo:ATV_CENCOS)

      nMonto:=nMonto*-1

      // Asiento del Activo
      EJECUTAR("ASIENTOCREA",cCodSuc,cNumCom,oTable:DAC_FECHA,cOrg,cCtaAct,cTipDoc,oActivo:ATV_CODIGO,cDescri,nMonto ,cCodigo,cTipTra,cNumPag,oActivo:ATV_CENCOS)

      SQLUPDATE("DPDESINCORPACT",{"DAC_NUMCBT","DAC_CONTAB"},{cNumCom,"S"},"DAC_NUMERO"+GetWhere("=",cNumPag))

      oActivo:End()
      oTable:DbSkip()

      nCuantos++

   ENDDO
// oTable:Browse()
   oTable:End()
//   nDesinc:=OJO

   IF nCuantos=0 .AND. ValType(oRunCbte)="O"
     oRunCbte:cResp:="Depreciación no Contabilizada"
     oRunCbte:oResp:Refresh(.T.)
     oRunCbte:lOk:=.F.
   ENDIF

RETURN nCuantos>0

FUNCTION RUNSAVE()
  LOCAL oData

  oRunCbte:cResp:="Activo Contabilizado Exitosamente"
  oRunCbte:oResp:Refresh(.T.)

  oData:=DATASET("DEPACTCONTAB","ALL")

  oData:Set("CLOSE",oRunCbte:lClose)
  oData:Set("VIEW" ,oRunCbte:lView )

  oData:Save()
  oData:End()

  IF oRunCbte:lView

     EJECUTAR("DPACTVIEWCON", oRunCbte:cCodSuc,oRunCbte:cCodigo)

  ENDIF

  IF oRunCbte:lClose   
     oRunCbte:Close()
  ENDIF

RETURN .T.


