// Programa   : DPCONTABDEPREC
// Fecha/Hora : 03/11/2014 17:51:00
// Propósito  : Contabilizar Depreciaciones
// Creado Por : Juan Navas
// Llamado por: BRDEPCONTAB    
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

FUNCTION MAIN(cCodSuc,cCodigo,cNumDep,cNumCom,cActual)
  LOCAL cWhere,oTable,cSql,cDescri,nCuantos:=0,oActivo
  LOCAL cTipDoc  :="ACT"
  LOCAL nMonto   :=0
  LOCAL cOrg     :="ACT"
  LOCAL cNumPag  :=""
  LOCAL cTipTra  :="D"
  LOCAL cTipDoc  :="DEP"
  LOCAL cCtaAct  :="" // Depreciación Activo
  LOCAL cCtaDep  :="" // Depreciación Gasto
  LOCAL cWhereDel:=""  
  LOCAL cCtaUtil :=""

  CursorWait()

  // ? cNumDep,"cNumDep",LEN(cNumDep),cCodigo,"cCodigo",cNumCom

  DEFAULT cCodSuc:=oDp:cSucursal,;
          cCodigo:=SQLGET("DPDEPRECIAACT","DEP_CODACT,DEP_NUMERO","DEP_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
                                                                  "DEP_TIPTRA"+GetWhere("=","D")                                                       ),;
          cNumDep:=DPSQLROW(2),;
          cNumCom:=STRZERO(1,8),;
          cActual:="N"

  cWhere:="ATV_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
          "ATV_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
          "DEP_TIPTRA"+GetWhere("=","D"    )+" AND "+;
          IIF(ValType(cNumDep)="A",GetWhereOr("DEP_NUMERO",cNumDep),"DEP_NUMERO"+GetWhere("=",cNumDep))

  oTable:=OpenTable(" SELECT ATV_CODIGO,ATV_DESCRI,DEP_MONTO,DEP_MTOFIS,DEP_MTOFIN,ATV_CENCOS,"+;
                    " DEP_NUMERO,DEP_DESDE,DEP_FECHA,DEP_CODSUC,DEP_COMPRO,DEP_MTOFIS,DEP_MTOFIN,DEP_DESDE, "+;
                    " DEP_IPCFAC,DEP_BASFIS,DEP_BASFIN,DEP_NUMPAR FROM DPDEPRECIAACT "+;
                    " INNER JOIN DPACTIVOS ON ATV_CODSUC=DEP_CODSUC AND ATV_CODIGO=DEP_CODACT "+;
                    " WHERE "+cWhere,.T.)

  IF oTable:RecCount()=0
     MensajeErr("No hay Depreciaciones para el Activo "+cCodigo)
     oTable:End()
     RETURN .T.
  ENDIF

  cWhere:=""
  oTable:Gotop()

  IF !EJECUTAR("ISCTAINDEF","UTILIDAD")
     RETURN .F.
  ENDIF

  cCtaUtil:=EJECUTAR("GETCODINT","UTILIDAD")

  oTable:ATV_CTAACT:=EJECUTAR("DPGETCTAMOD","DPACTIVOS",oTable:ATV_CODIGO,NIL,"CTAACT")
  oTable:ATV_CTAACU:=EJECUTAR("DPGETCTAMOD","DPACTIVOS",oTable:ATV_CODIGO,NIL,"CTAACU")
  oTable:ATV_CTADEP:=EJECUTAR("DPGETCTAMOD","DPACTIVOS",oTable:ATV_CODIGO,NIL,"CTADEP")
  oTable:ATV_CTAREV:=EJECUTAR("DPGETCTAMOD","DPACTIVOS",oTable:ATV_CODIGO,NIL,"CTAREV")

  WHILE !oTable:Eof()

      cDescri:=oTable:ATV_DESCRI
      cCtaAct:=oTable:ATV_CTAACU
      cCtaDep:=oTable:ATV_CTADEP
      cCodigo:=oTable:ATV_CODIGO
      nMonto :=oTable:DEP_MONTO
      cNumPag:=oTable:DEP_NUMERO

      oDp:nMtoBase  :=0
      oDp:nIpc      :=0
      oDp:dDesde    :=CTOD("")
      oDp:cActualCbt:=cActual
  

      IF !Empty(oTable:DEP_COMPRO) // Elimina el Asiento

        // Elimina Todos los Asientos
        cWhereDel:="MOC_CODSUC"+getWhere("=",oTable:DEP_CODSUC)+" AND "+;
                   "MOC_NUMCBT"+GetWhere("=",oTable:DEP_COMPRO)+" AND "+;
                   "MOC_FECHA" +GetWhere("=",oTable:DEP_FECHA )+" AND "+;
                   "MOC_NUMPAR"+GetWhere("=",oTable:DEP_NUMPAR)

        SQLDELETE("DPASIENTOS",cWhereDel)
/*

        cWhereDel:="MOC_FECHA "+GetWhere("=",oTable:DEP_FECHA )+" AND "+;
                   "MOC_NUMCBT"+GetWhere("=",oTable:DEP_COMPRO)+" AND "+;
                   "MOC_TIPO  "+GetWhere("=",cTipDoc          )+" AND "+;
                   "MOC_CODAUX"+GetWhere("=",oTable:ATV_CODIGO)+" AND "+;
                   "MOC_DOCPAG"+GetWhere("=",oTable:DEP_NUMERO)+" AND "+;
                   "MOC_CODSUC"+GetWhere("=",cCodSuc          )+" AND "+;
                   "MOC_TIPTRA"+GetWhere("=",cTipTra          )+" AND "+;
                   "MOC_ORIGEN"+GetWhere("=",cOrg             )
         

        // Asientos Histórico
        SQLDELETE("DPASIENTOS","MOC_CODSUC"+GetWhere("=",oTable:DEP_CODSUC)+" AND "+;
                               "MOC_ACTUAL"+GetWhere("=",cActual          )+" AND "+;
                               cWhereDel)

        // Asientos Fiscales
        SQLDELETE("DPASIENTOS","MOC_CODSUC"+GetWhere("=",oTable:DEP_CODSUC)+" AND "+;
                               "MOC_ACTUAL"+GetWhere("=","X"              )+" AND "+;
                               cWhereDel)
      
        // Asientos Fiscales
        SQLDELETE("DPASIENTOS","MOC_CODSUC"+GetWhere("=",oTable:DEP_CODSUC)+" AND "+;
                               "MOC_ACTUAL"+GetWhere("=","F"              )+" AND "+;
                               cWhereDel)

*/
      ENDIF

      // Calcula el Numero de la Partida
      EJECUTAR("DPMOCNUMPAR",oDp:cActualCbt,oTable:DEP_FECHA,cNumCom)

      EJECUTAR("DPDELCBTEV")
      // Gasto
      EJECUTAR("ASIENTOCREA",cCodSuc,cNumCom,oTable:DEP_FECHA,cOrg,cCtaDep,cTipDoc,oTable:ATV_CODIGO,cDescri,nMonto ,cCodigo,cTipTra,cNumPag,oTable:ATV_CENCOS)

      // Depreciación Activo
      nMonto :=oTable:DEP_MONTO*-1

      EJECUTAR("ASIENTOCREA",cCodSuc,cNumCom,oTable:DEP_FECHA,cOrg,cCtaAct,cTipDoc,oTable:ATV_CODIGO,cDescri,nMonto ,cCodigo,cTipTra,cNumPag,oTable:ATV_CENCOS)


      // Asientos del Ajuste Fiscal
      IF oTable:DEP_MTOFIS<>0

        oDp:cActualCbt:="X"
        oDp:nMtoBase  :=oTable:DEP_BASFIS
        oDp:nIpc      :=oTable:DEP_IPCFAC
        oDp:dDesde    :=oTable:DEP_DESDE

        EJECUTAR("ASIENTOCREA",cCodSuc,cNumCom,oTable:DEP_FECHA,cOrg,oTable:ATV_CTAREV,cTipDoc,oTable:ATV_CODIGO,cDescri,oTable:DEP_MTOFIS    ,cCodigo,cTipTra,cNumPag,oTable:ATV_CENCOS)

        oDp:nMtoBase  :=0
        oDp:nIpc      :=0

        EJECUTAR("ASIENTOCREA",cCodSuc,cNumCom,oTable:DEP_FECHA,cOrg,cCtaUtil         ,cTipDoc,oTable:ATV_CODIGO,cDescri,oTable:DEP_MTOFIS*-1 ,cCodigo,cTipTra,cNumPag,oTable:ATV_CENCOS)

      ENDIF

      cWhere:="DEP_CODSUC"+GetWhere("=",otable:DEP_CODSUC)+" AND "+;
              "DEP_CODACT"+GetWhere("=",oTable:ATV_CODIGO)+" AND "+;
              "DEP_NUMERO"+GetWhere("=",oTable:DEP_NUMERO)+" AND "+;
              "DEP_TIPTRA"+GetWhere("=","D")

// ? cWhere
//    SQLUPDATE("DPDEPRECIAACT",{"DEP_COMPRO","DEP_FCHCON","DEP_ESTADO"},{cNumCom,oDp:dFecha,"C"},cWhere)
      SQLUPDATE("DPDEPRECIAACT",{"DEP_COMPRO","DEP_FCHCON","DEP_NUMPAR"},{cNumCom,oDp:dFecha,oDp:cPartida},cWhere)
      
// ? CLPCOPY(oDp:cSql)

      nCuantos++

//	IF ValType(oRunCbte)="O"
//         oRunCbte:cResp:="Contabilizado Depreciación Periodo "+DTOC(oTable:DEP_FECHA)
//         oRunCbte:oResp:Refresh(.T.)
//     ENDIF

     oTable:DbSkip()

   ENDDO

   oTable:End()

RETURN .T.

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


RETURN
