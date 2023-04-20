// Programa   : DPDEPRECCALC
// Fecha/Hora : 24/06/2006 15:08:26
// Propósito  : Calcular Depreciación de Activos
// Creado Por : Juan Navas
// Llamado por: DPACTMENU
// Aplicación : Activos
// Tabla      : DPDEPRECIA

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cCodAct,lRebuild)
  LOCAL oTable,cSql,oActivo,lResp:=.T.,I,cEstado:="A",dFchAnt:=CTOD("")
  LOCAL nMeses:=0,dFecha,nMonto:=0,nTotal:=0,nTotDep:=0,nUniPro:=0
  LOCAL nContab:=0,nDesinc:=0,cMsg:="",aMonto:={},nMontoH:=0,nTotalH:=0,nDesde,nCuantos
  LOCAL aFechas:={},nPeriod:=0,nDepMes:=0,nMtoDif:=0,dFchIni:=CTOD("")

  DEFAULT cCodSuc :=oDp:cSucursal,;
          cCodAct :=SQLGET("DPACTIVOS","ATV_CODIGO"),;
          lRebuild:=.T.

  DEFAULT oDp:lActMensual:=.T.

  // QUITAR
  // oDp:lActMensual:=.F.

  nContab:=COUNT("DPDEPRECIAACT","DEP_CODACT"+GetWhere("=",cCodAct)+" AND "+;
                                 "DEP_ESTADO='C'")

  IF nContab>0
     cMsg:=LSTR(nContab)+" Depreciacion(es) Contabilizada(s)"
  ENDIF

  nDesinc:=MYCOUNT("DPDEPRECIAACT","DEP_CODACT"+GetWhere("=",cCodAct)+" AND "+;
                                   "DEP_ESTADO='D'")

  IF nDesinc>0

     cMsg:=cMsg+IIF(Empty(cMsg),"",CRLF)+;
           LSTR(nDesinc)+" Depreciacion(es) Desincorporada(s)"

  ENDIF

  IF !Empty(cMsg)
     MensajeErr("Activo "+ALLTRIM(cCodAct)+" Posee "+CRLF+cMsg)
     RETURN .F.
  ENDIF

  // Puede Rehacer la Depreciación si no está Contabilizada

  oActivo:=OpenTable(" SELECT * FROM DPACTIVOS "+;
                     " INNER JOIN DPGRUACTIVOS ON ATV_CODGRU=GAC_CODIGO "+;
                     "  WHERE ATV_CODSUC"+GetWhere("=",cCodSuc)+" AND ATV_CODIGO"+GetWhere("=",cCodAct),.T.)
// oActivo:Browse()
/*
ELDS]
 C001=GAC_CODIGO,'C',008,0,'PRIMARY KEY NOT NULL','Código',1,''
 C002=GAC_DESCRI,'C',035,0,'','Descripci¾n',0,''
 C003=GAC_MEMO  ,'M',010,0,'','Comentario',0,''
 C004=GAC_VUTILA,'N',002,0,'','Vida Util en A±os',0,''
 C005=GAC_VUTILM,'N',002,0,'','Vida Util en Meses',0,''
 C006=GAC_PORVLS,'N',006,2,'','% Valor de Salvamento',0,''
 C007=GAC_CTAFIJ,'L',001,0,'','Cuentas Contables Fijas',0,'.T.'
[END_FIELDS]
*/

// ? oActivo:ATV_VIDA_A,oActivo:ATV_VIDA_M

  IF Empty(oActivo:ATV_VIDA_A+oActivo:ATV_VIDA_M)
     oActivo:ATV_VIDA_A:=oActivo:GAC_VUTILA
     oActivo:ATV_VIDA_M:=oActivo:GAC_VUTILM
     SQLUPDATE("DPACTIVOS",{"ATV_VIDA_A","ATV_VIDA_M"},{oActivo:ATV_VIDA_A,oActivo:ATV_VIDA_M},oActivo:cWhere)
  ENDIF

  // % Valor de Salvamento
  IF Empty(oActivo:ATV_PORVAL) 
     oActivo:ATV_PORVAL:=oActivo:GAC_PORVLS
     SQLUPDATE("DPACTIVOS","ATV_PORVAL",oActivo:ATV_PORVAL,oActivo:cWhere)
  ENDIF

  // Sin Valor de Salvamento
  IF Empty(oActivo:ATV_VALSAL) .AND. oActivo:ATV_PORVAL>0 
     oActivo:ATV_VALSAL:=PORCEN(oActivo:ATV_COSADQ,oActivo:ATV_PORVAL)
     SQLUPDATE("DPACTIVOS","ATV_VALSAL",oActivo:ATV_VALSAL,oActivo:cWhere)
  ENDIF

  IF Empty(oActivo:ATV_FCHMAX) 
      ATVFCHMAX()
      SQLUPDATE("DPACTIVOS","ATV_FCHMAX",oActivo:ATV_FCHMAX,oActivo:cWhere)
  ENDIF

  oActivo:End()

  dFchIni:=oActivo:ATV_FCHADQ
  aFechas:=EJECUTAR("DEPAXIFECHAS",oActivo:ATV_FCHADQ,oActivo:ATV_FCHMAX)

  IF Empty(aFechas)
     MensajeErr("No hay Fechas para la Depreciación "+DTOC(oActivo:ATV_FCHADQ)+" - "+DTOC(oActivo:ATV_FCHMAX))
  ENDIF

  //? LEN(aFechas),oActivo:ATV_FCHADQ,oActivo:ATV_FCHMAX

  nMeses :=0
  nPeriod:=LEN(aFechas)
  AEVAL(aFechas,{|a,n| nMeses:=nMeses+a[4]})

  oDp:cMsgAct:=""

  IF nMeses=0
     oDp:cMsgAct:="No posee Tiempo de Vida Util"
  ENDIF

  dFecha :=oActivo:ATV_FCHDEP
  nMonto :=oActivo:ATV_DEPMEN
  nTotDep:=oActivo:ATV_COSADQ - (oActivo:ATV_VALSAL + oACTIVO:ATV_DEPACU)
  nDepMes:=nTotDep/nMeses

  nMontoH:=DIV(oACTIVO:ATV_DEPACU,oACTIVO:ATV_MESDEP) // Depreciación Histórica
  nUniPro:=0

  // nMonto:=DIV(nTotDep,nMeses)
  nDepMes:=DPTRUNCATE(nDepMes,2)

  IF !Empty(oDp:cMsgAct)
     RETURN .F.
  ENDIF

  SQLDELETE("DPDEPRECIAACT","DEP_CODACT"+GetWhere("=",cCodAct)+" AND DEP_TIPTRA"+GetWhere("=","D"))

  cSql  :=" SELECT * FROM DPDEPRECIAACT "
  cWhere:=""

  oTable:=OpenTable(cSql,.F.)
  aMonto:=ARRAY(LEN(aFechas)) // nMeses)
  AFILL(aMonto,0) 

  // Meses Históricos
  nTotal:=0

  FOR I=1 TO LEN(aMonto)
     aMonto[I]:=DPTRUNCATE(nDepMes*aFechas[I,4],2)
     nTotal:=nTotal+aMonto[I]
  NEXT I

//ViewArray(aMonto)

  // Determina la Cantidad Diferencial
  nMtoDif:=(nTotDep-nTotal)/LEN(aMonto)

  // Bucle Infinto de Redondeo
  WHILE nMtoDif>0
    nTotal:=0
    aMonto[LEN(aMonto)]:=aMonto[LEN(aMonto)]+nMtoDif // Todas las Diferencias se suman en el ultimo Elemento, no se puede hacer proporcional, no todos los peridos son simetricos
    AEVAL(aMonto,{|a,I| nTotal:=nTotal+aMonto[I]})
    nMtoDif:=(nTotDep-nTotal)
  ENDDO

  // Fecha en que Empieza a Depreciar el Activo
  // dFchIni:=IIF(Len(aFechas)>0,aFechas[1,2],dFchIni)
  // dFchIni:=IIF(LEN(aFechas)>0,aFechas[1,1],dFchIni)

  FOR I=1 TO LEN(aMonto)

     nMonto :=aMonto[I]
     dFchIni:=aFechas[I,1]
     dFecha :=aFechas[I,2]

     cEstado:="A"

     IF !Empty(oActivo:ATV_FCHINC) .AND. dFecha<oActivo:ATV_FCHINC 
        cEstado:="H" // Información Histórica (YA CONTABILIZADA)
     ENDIF

     oTable:Append()
     oTable:Replace("DEP_NUMERO",STRZERO(I,4)        )
     oTable:Replace("DEP_CODACT",oActivo:ATV_CODIGO  )
     oTable:Replace("DEP_DESDE" ,dFchIni             )
     oTable:Replace("DEP_FECHA" ,dFecha              )
     oTable:Replace("DEP_ESTADO",cEstado             )
     oTable:Replace("DEP_MONTO" ,nMonto              )
     oTable:Replace("DEP_MTOORG",nMonto              )
     oTable:Replace("DEP_CODSUC",oActivo:ATV_CODSUC  )
     oTable:Replace("DEP_FCHCON",CTOD("")            )
     oTable:Replace("DEP_UNIPRO",nUniPro             )
     oTable:Replace("DEP_COMPRO",""                  )
     oTable:Replace("DEP_PORCEN",RATA(nMonto,nTotDep))
     oTable:Replace("DEP_SIGNO" ,-1                  )
     oTable:Replace("DEP_TIPTRA","D"                 )
     oTable:Replace("DEP_NUMDES",""                  )
     oTable:Replace("DEP_NUMEJE",EJECUTAR("GETNUMEJE",dFecha))

     oTable:Commit()

     nTotal:=nTotal+nMonto

  NEXT I

  oTable:End()

  EJECUTAR("DPACTIVOSAXI",cCodAct,oDp:cSucursal)

RETURN lResp

FUNCTION ATVFCHMAX()
   LOCAL nMeses:=((oActivo:ATV_VIDA_A*12)+oActivo:ATV_VIDA_M)-oActivo:ATV_MESDEP

   oActivo:nMeses:=nMeses
   oActivo:dFechaMax:=FCHFINMES(oACTIVO:ATV_FCHDEP) // Fecha depreciacion

   // Calcula la Fecha de Conclusion del Activo
   AEVAL(ARRAY(MAX(nMeses-1,0)),{|a,n| oACTIVO:dFechaMax:=FCHFINMES(oActivo:dFechaMax)+1 })

   oActivo:ATV_FCHMAX:=FCHFINMES(oActivo:dFechaMax)

RETURN NIL

// EOF
