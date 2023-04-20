// Programa   : DPACTIVOSAXI
// Fecha/Hora : 17/10/2014 12:15:23
// Propósito  : Calcular Ajuste por Inflación Fiscal 
// Creado Por : Juan Navas
// Llamado por: DPDEPRECCALC
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo,cCodSuc,dDesde,dhasta)
   LOCAL cSql,oTable,dFchIni
   LOCAL nSumH :=0,nSumE:=0,nSumG:=0
   LOCAL dhasta:=FCHFINMES(oDp:dFchIniReg+360),cWhere

   DEFAULT cCodigo :=SQLGET("DPACTIVOS","ATV_CODIGO"),;
           cCodSuc :=oDp:cSucursal

   // Solo se Aplica a los Activos Adquiridos el Primer Año
   cWhere:=GetWhereAnd("ATV_FCHADQ",oDp:dFchIniReg,dhasta)

   cSql:=" SELECT ATV_CODIGO,YEAR(DEP_FECHA),"+;
         " ATV_DESCRI                AS A,"+;
         " DEP_DESDE                 AS B, "+;
         " DEP_IPCINI                AS C, "+;
         " DEP_IPCFIN                AS D, "+;
         " DEP_IPCINI/DEP_IPCFIN     AS E, "+;
         " ATV_COSADQ                AS F, "+;
         " DEP_MTOFIS+ATV_COSADQ     AS G, "+;
         " SUM(DEP_MONTO)            AS H, "+;
         " SUM(DEP_DEPFIS+DEP_MONTO) AS I, "+;
         " SUM(DEP_MTOFIS) AS J, "+;
         " SUM(DEP_DEPFIS) AS K, "+;
         " SUM(DEP_MONTO-DEP_MTOFIS)    AS L, "+;
         " SUM(DEP_MONTO-DEP_MTOFIS*.3) AS M, "+;
         " DEP_FECHA,DEP_TIPTRA,DEP_DESDE "+;
         " FROM DPDEPRECIAACT "+;
         " INNER JOIN DPACTIVOS ON ATV_CODIGO=DEP_CODACT "+;
         " WHERE DEP_CODACT"+GetWhere("=",cCodigo)+" AND DEP_TIPTRA='D' AND "+cWhere+;
         " GROUP BY ATV_CODIGO,YEAR(DEP_FECHA)"

   oTable:=OpenTable(cSql,.T.)

 ? CLPCOPY(oDp:cSql)
// oTable:Browse()
// RETURN .F.

   dFchIni:=oTable:DEP_DESDE  // ATV_FCHADQEl Ajuste Inicial se Calcula desde la Fecha de Adquisición

   WHILE !oTable:Eof()

      nSumH   :=nSumH+oTable:H

      oTable:Replace("E",EJECUTAR("FACTORIPC",oTable:B,oTable:DEP_FECHA))
      oTable:Replace("C",oDp:aIpcFactor[1] )
      oTable:Replace("D",oDp:aIpcFactor[2] )
      oTable:Replace("G",oTable:E*oTable:F )
      oTable:Replace("H",nSumH             )
      oTable:Replace("I",oTable:H*oTable:E )
      oTable:Replace("J",oTable:G-oTable:F )
      oTable:Replace("K",oTable:I-oTable:H )
      oTable:Replace("L",oTable:J-oTable:K )

      dFchIni :=oTable:DEP_FECHA

      IF oTable:E=0
         oTable:Replace("L",0)
         oTable:Replace("K",0)
         oTable:Replace("G",0)
         oTable:Replace("I",0)        
      ENDIF


      SQLUPDATE("DPDEPRECIAACT",{"DEP_IPCINI","DEP_IPCFIN","DEP_IPCFAC"   ,"DEP_MTOFIS","DEP_DEPFIS","DEP_FCHFIS","DEP_BASFIS"},;
                                {oTable:C    ,oTable:D    ,oTable:E       ,oTable:L    ,oTable:K    ,oTable:B    ,oTable:G-oTable:I},;
                                "DEP_CODSUC"+GetWhere("=",cCodSuc         )+" AND "+;
                                "DEP_CODACT"+GetWhere("=",cCodigo         )+" AND "+;
                                "DEP_FECHA "+GetWhere("=",oTable:DEP_FECHA)+" AND "+;
                                "DEP_TIPTRA"+GetWhere("=",oTable:DEP_TIPTRA))

      
      oTable:DbSkip()

   ENDDO

   oTable:End()

RETURN NIL

PROCE ANTERIOR()
  LOCAL oActivo,oTable,cSql,cCodSuc
  LOCAL dFchAjs:=CTOD(""),nBase:=0
  LOCAL nInpIni:=0,nInpFin:=0,nInpFac:=0,nMtoFis:=0,nTotFis:=0,nBasFis:=0,nDepFis:=0,nDepFisT:=0,dFchFisD:=CTOD(""),dFchFisH:=CTOD("")
  LOCAL nIpcIni:=0,nIpcFin:=0,nIpcFac:=0,nMtoFin:=0,nTotFin:=0,nBasFin:=0,nDepFin:=0,nDepFinT:=0,dFchFinD:=CTOD(""),dFchFinH:=CTOD("")
  

  DEFAULT cCodSuc :=oDp:cSucursal,;
          cCodigo :=SQLGET("DPACTIVOS","ATV_CODIGO")

  oActivo:=OpenTable("SELECT * FROM DPACTIVOS WHERE ATV_CODIGO"+GetWhere("=",cCodigo),.T.)
  oActivo:End()

  cSql:=" SELECT DEP_FECHA,DEP_MONTO,DEP_SIGNO,DEP_TIPTRA FROM DPDEPRECIAACT "+;
        " WHERE DEP_CODACT"+GetWhere("=",oActivo:ATV_CODIGO)+;
        "   AND DEP_MONTO<>0 "+;
        " ORDER BY DEP_FECHA"

  oTable:=OpenTable(cSql,.T.)

  // Para Todos los Casos sera Revaluado el Activo y la depreciacion de manera separa

  dFchFinD:=oActivo:ATV_FCHADQ  // Fecha de Adquisición, la primera rexpresion de utiliza desde esta fecha

  WHILE !oTable:Eof()

     /*
     // Ajuste Financiero
     */

IF .F.
     nBasFin :=nBasFin+(oTable:DEP_MONTO*oTable:DEP_SIGNO)
     dFchFinH:=oTable:DEP_FECHA
     nIpcFin :=EJECUTAR("FACTORINPC",dFchFinD,dFchFinH)
     nIpcFinA:=oDp:aInpcFactor[1]


     IF oTable:DEP_TIPTRA="D"
        nDepFin :=MAX((oTable:DEP_MONTO*nIpcFin)-oTable:DEP_MONTO,0)
     ENDIF

     nMtoFin :=MAX((nBasFin*nIpcFin)-nBasFin,0)

//? nBasFin,"nBasFin",dFchFinD,dFchFinH,nIpcFin,nMtoFin

     SQLUPDATE("DPDEPRECIAACT",{"DEP_IPCFNA","DEP_IPCFIN","DEP_MTOFIN","DEP_MTOFIS"},;
                               {nIpcFinA    ,nIpcFin     ,nMtoFin     ,nMtoFis     },;
                               "DEP_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                               "DEP_CODACT"+GetWhere("=",cCodigo)+" AND "+;
                               "DEP_FECHA "+GetWhere("=",oTable:DEP_FECHA)+" AND "+;
                               "DEP_TIPTRA"+GetWhere("=",oTable:DEP_TIPTRA))
//     dFchFinD:=dFchFinH

ENDIF

     /*
     // Ajuste Fiscal
     */

     nBasFis :=nBasFis+(oTable:DEP_MONTO*oTable:DEP_SIGNO)
     dFchFisH:=oTable:DEP_FECHA
     nIpcFac :=EJECUTAR("FACTORIPC",dFchFisD,dFchFisH)
     nIpcIni :=oDp:aIpcFactor[1]
     nIpcFin :=oDp:aIpcFactor[2]

//   nMtoFis :=MAX((nBasFis*nInpIni)-nBasFis,0)

     IF oTable:DEP_TIPTRA="D"
        nDepFis :=MAX((oTable:DEP_MONTO*nInpIni)-oTable:DEP_MONTO,0)
     ENDIF

//? nBasFis,"nBasFis",dFchFisD,dFchFisH,nInpIni,nMtoFis

     SQLUPDATE("DPDEPRECIAACT",{"DEP_IPCINI","DEP_IPCFIN","DEP_IPCFAC","DEP_MTOFIS","DEP_DEPFIS"},;
                               {nIpcIni     ,nIpcFin     ,nIpcFac     ,nMtoFis     ,nDepFis},;
                               "DEP_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                               "DEP_CODACT"+GetWhere("=",cCodigo)+" AND "+;
                               "DEP_FECHA "+GetWhere("=",oTable:DEP_FECHA)+" AND "+;
                               "DEP_TIPTRA"+GetWhere("=",oTable:DEP_TIPTRA))

     dFchFisD:=dFchFisH
     oTable:DbSkip()

  ENDDO

//  oTable:Browse()

oTable:End()

RETURN
// EOF
