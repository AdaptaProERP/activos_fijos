// Programa   : DPACTIVOSTODEP
// Fecha/Hora : 15/10/2014 18:16:45
// Propósito  : Migrar Datos del Activo hacia Depreciaciones
// Creado Por : Juan Navas
// Llamado por: SQLDB_UPDATE
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodigo,dFecha,nCosto,dFchIni,nDepAcu,nMtoFin,nMtoFis)
   LOCAL oTable,cSql

   IF cCodigo=NIL

     // Las nuevas versiones no debe utilizar este campo, su CONTENIDO debe ser reemplazado por una Vista
     Checktable("DPACTIVOS")

     IF !ISFIELD("DPACTIVOS","ATV_COSADQ")
        RETURN .T.
     ENDIF

     cSql  :=[ SELECT ATV_CODIGO,ATV_COSADQ,ATV_FCHADQ,ATV_FCHINC,ATV_DEPACU FROM DPACTIVOS  ]+;
             [ LEFT JOIN DPDEPRECIAACT ON ATV_CODIGO=DEP_CODACT AND DEP_TIPTRA="V" ]+;
             [ WHERE DEP_CODACT IS NULL ]

   ELSE

     cSql  :=[ SELECT ATV_CODIGO,0 AS ATV_COSADQ,0 AS ATV_FCHADQ,0 AS ATV_FCHINC,0 AS ATV_DEPACU  FROM DPACTIVOS  ]+;
             [ WHERE ATV_CODIGO]+GetWhere("=",cCodigo)

   ENDIF

   oTable:=OpenTable(cSql,.T.)

// oTable:Browse()

   /*
   // Estos Campos son Removidos
   */

   IF !cCodigo=NIL
      oTable:ATV_COSADQ:=nCosto
      oTable:ATV_FCHADQ:=dFecha
      oTable:ATV_FCHINC:=dFchIni
      oTable:ATV_DEPACU:=nDepAcu
   ENDIF

   WHILE !oTable:Eof()

     // Crea el Valor del Activo
     CREAMOVDEP(oTable:ATV_CODIGO,oTable:ATV_FCHADQ,oTable:ATV_COSADQ,"V",1)

     // Crea la Depreciacion Acumulada desde la Fecha Inical
     IF !Empty(oTable:ATV_FCHINC)

       CREAMOVDEP(oTable:ATV_CODIGO,oTable:ATV_FCHINC,oTable:ATV_DEPACU,"I",-1)

     ELSE

       SQLDELETE("DPDEPRECIAACT","DEP_CODACT"+GetWhere("=",oTable:ATV_CODIGO)+" AND "+;
                                 "DEP_TIPTRA"+GetWhere("=","I"               ),.T.)


     ENDIF

     oTable:DbSkip()

   ENDDO

   oTable:End()

RETURN NIL

/*
// Crear Valor Inicial
*/
FUNCTION CREAMOVDEP(cCodigo,dFecha,nMonto,cTipTra,nSigno,nMtoFis,nMtoFin)
  LOCAL oDep
  LOCAL cNumEje:=EJECUTAR("GETNUMEJE",dFecha,.T.)

  oDep  :=OpenTable("SELECT * FROM DPDEPRECIAACT WHERE DEP_CODACT"+GetWhere("=",cCodigo)+;
                                                  "AND DEP_TIPTRA"+GetWhere("=",cTipTra),.T.)

  IF oDep:RecCount()=0
     oDep:AppendBlank()
     oDep:cWhere:=""
  ENDIF

  oDep:Replace("DEP_CODACT",cCodigo          )
  oDep:Replace("DEP_FECHA" ,dFecha           )
  oDep:Replace("DEP_TIPTRA",cTipTra          )
  oDep:Replace("DEP_SIGNO" ,nSigno           )
  oDep:Replace("DEP_ESTADO","A"              )
  oDep:Replace("DEP_CODSUC",oDp:cSucursal    )
  oDep:Replace("DEP_MONTO" ,nMonto           )

  IF cTipTra="V"
    oDep:Replace("DEP_NUMERO","0000"          ) // Debe ser la Primera Transacción
  ENDIF

  IF cTipTra="I"
    oDep:Replace("DEP_NUMERO","0001"          ) // Debe ser la Primera Transacción
  ENDIF

  oDep:Replace("DEP_MTOFIS",nMtoFis          ) // Acumulado Rexpresion Fiscal 
  oDep:Replace("DEP_MTOFIN",nmtoFin          ) // Acumulado Rexpresion Financiera
  oDep:Replace("DEP_NUMEJE",cNumEje          ) // Numero del Ejercicio

  oDep:Commit(oDep:cWhere)
 
  oDep:End()

RETURN .T.

//  EOF
