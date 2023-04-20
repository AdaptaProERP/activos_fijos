// Programa   : DPCBTEPAGOCLILOADDOC
// Fecha/Hora : 24/05/2019 05:04:16
// Propósito  : Carga de Documentos del Cliente
// Creado Por :
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oCbtePag ,lSave)
  LOCAL oTable,cSql,I,aDoc:={},cWhere:="",nAt:=0 // Fecha y hora
  LOCAL nPagado:=0,aCopy:=ACLONE(oCbtePag:oBrwDC:aArrayData)
  LOCAL aCopyOrg:=ACLONE(oCbtePag:aDocOrgCli),cHora,aLine,nValCam:=0
  LOCAL cConcat :="",nNeto:=0,nMtoDif:=0,nDivisa:=0
  LOCAL lRetIslr:=.F.,lRetIva:=.F.,lRetMun:=.F.
  LOCAL aPagos  :={}
  LOCAL lFind,nDocCam:=1
  LOCAL cCodCli,cRif
  LOCAL aLine:={}

  DEFAULT lSave:=.T.

  cCodCli:=oCbtePag:PAG_CODIGO


  IF LEFT(oCbtePag:PAG_TIPPAG,1)="P"

     cRif   :=SQLGET("DPPROVEEDOR","PRO_RIF","PRO_CODIGO"+GetWhere("=",oCbtePag:PAG_CODIGO))
  
     oCbtePag:PAG_RIF:=cRif
     
     cCodCli:=SQLGET("DPPROVEEDOR","PRO_CODIGO","PRO_RIF"+GetWhere("=",cRif))

//? cCodCli,"LEE LOS DATOS DEL CLIENTE"

     IF Empty(cCodCli)
        RETURN .F.
     ENDIF

  ENDIF


  oCbtePag:lDocs   := .F. // No Edita Documentos
  cHora           := IIF( !lSave , TIME() , oCbtePag:PAG_HORA )
  oCbtePag:lRev    :=MYSQLGET("DPCLIENTES","CLI_ENOTRA","CLI_CODIGO"+GetWhere("=",oCbtePag:PAG_CODIGO))="S"

  IF oCbtePag:nOption=0 

     cWhere:="DOC_RECNUM"+GetWhere("=",oCbtePag:PAG_NUMERO)+" AND DOC_ACT=1 AND (DOC_TIPTRA='P' OR (DOC_DOCORG='R' AND DOC_TIPTRA='P'))"

  ELSE

     // Debe Recuperar EJECUTAR("DPRECIBOSCLILDO",oCbtePag)

     cConcat:=EJECUTAR("SQLCONCAT",oCbtePag:PAG_FECHA,cHora)

     cWhere :="(NOT (DOC_RECNUM"+GetWhere("=",oCbtePag:PAG_NUMERO)+" AND DOC_TIPTRA='P')) AND "+;
              "DOC_TIPDOC"+GetWhere("<>","RMU"             )+" AND "+;
              "DOC_CREREC=0  AND CONCAT(DOC_FECHA,DOC_HORA)"+GetWhere("<=",cConcat)


  ENDIF


  IF oCbtePag:nOption=1

     DEFAULT oDp:lRecFchConcat:=.T.


     IF oDp:lRecFchConcat

       cConcat:=EJECUTAR("SQLCONCAT",oCbtePag:PAG_FECHA,cHora)
       cWhere :=" ((CONCAT(DOC_FECHA,DOC_HORA)"+GetWhere("<=",cConcat)+") OR DOC_FECHA"+GetWhere("<=",oCbtePag:PAG_FECHA)+")"

     ENDIF

 
     // JN 13/10/2014 (Sucursal del Cliente)
     IF !Empty(oCbtePag:cSucCli)
        cWhere:=cWhere + " AND DOC_SUCCLI"+GetWhere("=",oCbtePag:cSucCli)
     ENDIF

  ENDIF

  CursorWait()

  oCbtePag:oFolder:aEnable[1]:=.T.

  IF oCbtePag:nOption=3

     cSql :=" SELECT DOC_CODIGO,DOC_CODSUC,DOC_CXC*-1,TDC_DESCRI,DOC_TIPDOC,DOC_NUMERO,DOC_NETO FROM DPDOCCLI "+;
            "  INNER JOIN DPTIPDOCCLI ON DOC_TIPDOC=TDC_TIPO "+;
            "  WHERE DOC_CODSUC"+GetWhere("=",oCbtePag:PAG_CODSUC) +;
            "    AND DOC_CODIGO"+GetWhere("=",cCodCli) +;
            "    AND DOC_RECNUM"+GetWhere("=",oCbtePag:PAG_NUMERO) +;
            "    AND DOC_TIPTRA"+GetWhere("=","P"               ) +;
            " ORDER BY DOC_FECHA,DOC_HORA "

      aPagos:=ASQL(cSql)

//      ViewArray(aPagos)

  ENDIF

  cSql :=" SELECT DOC_CODIGO,DOC_CODSUC,DOC_CXC,TDC_DESCRI,DOC_TIPDOC,DOC_NUMERO,SUM(DOC_NETO*DOC_CXC) AS DOC_NETO FROM DPDOCCLI "+;
         "  INNER JOIN DPTIPDOCCLI ON DOC_TIPDOC=TDC_TIPO "+;
         "  WHERE DOC_CODSUC"+GetWhere("=",oCbtePag:PAG_CODSUC) +;
         "    AND DOC_CODIGO"+GetWhere("=",cCodCli) +;
         "    AND DOC_ACT=1 AND DOC_CXC<>0 AND DOC_ACT<>0 "+;
         "    AND "+cWhere +;
         " GROUP BY DOC_CODIGO,DOC_CODSUC,TDC_DESCRI,DOC_TIPDOC,DOC_NUMERO "+;
         " HAVING ROUND(DOC_NETO,2)<>0 "+;
         " ORDER BY DOC_FECHA,DOC_HORA "

  oTable:=OpenTable(cSql,.T.)

//  ? CLPCOPY(oDp:cSql)

  dpwrite("temp\dpcbtepago_cli_load_recibos.sql",oDp:cSql)

  // Documentos Pagados
  FOR I=1 TO LEN(aPagos)

     nAt:=ASCAN(oTable:aDataFill,{|a,n| aPagos[I,5]=a[5] .AND. aPagos[I,6]=a[6]})

     IF nAt=0
       AADD(oTable:aDataFill,aPagos[I])
     ENDIF

  NEXT I

  IF oTable:RecCount()=0

     oTable:End()
     oCbtePag:aDocsC:={} 
     oCbtePag:oFolder:aEnable[6]:=.F. // oCbtePag:lDocs
     oCbtePag:oFolder:ForWhen()

     aLine:=oCbtePag:oBrwDC:aArrayData[1]
     AEVAL(aLine,{|a,n| aLine[n]:=CTOEMPTY(a)})
     oCbtePag:oBrwDC:aArrayData:={aLine}

     RETURN .F.
  ENDIF

  oCbtePag:lDocs:=.T.


  oCbtePag:lDocs:=(oTable:RecCount()>0) // No Edita Documentos
  oCbtePag:oFolder:aEnable[2]:=.T. // oCbtePag:lDocs
  oCbtePag:oFolder:Refresh(.T.)

// ? "AQUI LO ACTIVA",oCbtePag:lDocs

  oTable:Replace("DOC_FECHA" ,CTOD(""))
  oTable:Replace("DOC_PAGO"  ,.F.     ) // Indica si Pagó
  oTable:Replace("DOC_MTOORG",0       ) // Monto Original
  oTable:Replace("DOC_MTOPAG",0       ) // Monto Pagado
  oTable:Replace("DOC_MROREV",0       ) // Monto Revaluado
  oTable:Replace("DOC_DIFCAM",0       ) // Diferencia Cambiaria

  oTable:Gotop()
  oCbtePag:aDocsC:={}

  WHILE !oTable:Eof() 

     // Buscamos Datos Complementarios
     nValCam:=0
     oTable:Replace("DOC_MTOORG",oTable:DOC_NETO)
     oTable:Replace("DOC_MONNAC",oTable:DOC_NETO)

//? oTable:DOC_NETO,"oTable:DOC_NETO"

     oTable:Replace("DOC_FECHA",SQLGET("DPDOCCLI","MAX(DOC_FECHA) AS DOC_FECHA,DOC_VALCAM,DOC_CODMON,DOC_HORA,DOC_NETO,DOC_MTOCOM","DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
                                                  "DOC_TIPDOC"+GetWhere("=",oTable:DOC_TIPDOC )+" AND "+;
                                                  "DOC_CODIGO"+GetWhere("=",oTable:DOC_CODIGO )+" AND "+;
                                                  "DOC_NUMERO"+GetWhere("=",oTable:DOC_NUMERO )+" AND "+;
                                                  "DOC_TIPTRA='D' AND DOC_ACT=1"))


     nDocCam:=MAX(oDp:aRow[2],1)

     oTable:Replace("DOC_VALCAM",nDocCam ) // MAX(oDp:aRow[2],1))
     oTable:Replace("DOC_CODMON",oDp:aRow[3])
     oTable:Replace("DOC_HORA"  ,oDp:aRow[4])
     oTable:Replace("DOC_ENOTRA",DIV(oTable:DOC_NETO,oTable:DOC_VALCAM))
     oTable:Replace("DOC_CAMBIO",MAX(1,nValCam))


   IF oCbtePag:lRev .AND. oCbtePag:nOption<>0

     IF Empty(oCbtePag:cCodMon)

        IF oCbtePag:PAG_CODMON<>oTable:DOC_CODMON
          nValCam:=EJECUTAR("DPGETVALCAM",oCbtePag:PAG_CODMON,oCbtePag:PAG_FECHA,cHora)
        ELSE
          nValCam:=EJECUTAR("DPGETVALCAM",oTable:DOC_CODMON,oCbtePag:PAG_FECHA,cHora)
        ENDIF

     ELSE

        nValCam:=oCbtePagX:nValCam // EJECUTAR("DPGETVALCAM",oCbtePag:cCodMon,oCbtePag:PAG_FECHA,cHora)

     ENDIF

// ? nValCam,"Valor Cambiario",oTable:DOC_CODMON,oCbtePag:PAG_CODMON,"oCbtePag:PAG_CODMON, Según Recibo"

        oTable:Replace("DOC_CAMBIO",nValCam)
        oTable:Replace("DOC_MTOORG",oTable:DOC_NETO)
        nNeto :=DIV(oTable:DOC_NETO,oTable:DOC_VALCAM)*nValCam
        nMtoDif:=nNeto-oTable:DOC_NETO

//   ? oTable:DOC_NETO,nValCam,nNeto,nMtoDif,oTable:DOC_NETO
// ? "AQUI",oTable:DOC_NETO,"DOC_NETO",nPagado,nNeto,nValCam,"nValCam"

     ENDIF

     IF oCbtePag:nOption<>0

        cWhere:="DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
                "DOC_TIPDOC"+GetWhere("=",oTable:DOC_TIPDOC)+" AND "+;
                "DOC_NUMERO"+GetWhere("=",oTable:DOC_NUMERO)+" AND "+;
                "DOC_TIPTRA"+GetWhere("=","P"              )+" AND "+;
                "DOC_RECNUM"+GetWhere("=",oCbtePag:PAG_NUMERO)

        nPagado:=0

        lFind:=ISSQLFIND("DPDOCCLI",cWhere)

        IF !lFind

           nPagado:=SQLGET("DPDOCCLI","(DOC_NETO+DOC_OTROS)*DOC_CXC","DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
                                                           "DOC_TIPDOC"+GetWhere("=",oTable:DOC_TIPDOC)+" AND "+;
                                                           "DOC_CODIGO"+GetWhere("=",oTable:DOC_CODIGO)+" AND "+;
                                                           "DOC_NUMERO"+GetWhere("=",oTable:DOC_NUMERO)+" AND DOC_TIPTRA='P' AND "+;
                                                           "DOC_RECNUM"+GetWhere("=",oCbtePag:PAG_NUMERO))

           nPagado:=nPagado*-1

        ENDIF

     ELSE

       nPagado:=oTable:DOC_NETO*-1

     IF .F. // oTable:DOC_CXC=-1 .AND. oTable:DOC_NETO<0 // Documentos Creados en Recibos
       oTable:Replace("DOC_CXC" , 1 )
     ENDIF

     ENDIF

     IF Empty(nPagado)

        nPagado:=oTable:DOC_NETO

        IF lFind
           nPagado:=0 
        ENDIF

     ELSE

        oTable:Replace("DOC_PAGO"  ,.T.     ) // Indica si Pagó

     ENDIF

     IF  oCbtePag:nOption<>0 .OR. (oCbtePag:nOption=0 .AND. oTable:DOC_PAGO)


       IF oCbtePag:nOption=0

         nMtoDif:=SQLGET("DPDOCCLI","DOC_MTOCOM","DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC )+" AND "+;
                                                 "DOC_TIPDOC"+GetWhere("=",oTable:DOC_TIPDOC )+" AND "+;
                                                 "DOC_CODIGO"+GetWhere("=",oTable:DOC_CODIGO )+" AND "+;
                                                 "DOC_NUMERO"+GetWhere("=",oTable:DOC_NUMERO )+" AND "+;
                                                 "DOC_RECNUM"+GetWhere("=",oCbtePag:PAG_NUMERO)+" AND "+;
                                                 "DOC_TIPTRA='P' AND DOC_ACT=1")

         nDivisa:=nPagado/oTable:DOC_VALCAM

         AADD(oCbtePag:aDocsC,{oTable:TDC_DESCRI,oTable:DOC_NUMERO,oTable:DOC_FECHA,;
                             IIF(oTable:DOC_CXC=-1 ,nPagado*+1,0),;
                             IIF(oTable:DOC_CXC=+1 ,nPagado*-1,0),oTable:DOC_VALCAM,nDivisa,nMtoDif,nPagado+nMtoDif,lRetIslr,lRetIva,lRetMun})

       ELSE

         // Revalorizado


         oTable:Replace("DOC_VALCAM",nDocCam)
         nDivisa:=nPagado/nDocCam // oTable:DOC_VALCAM

         nMtoDif:=(nDivisa*nValCam)-nPagado

//? nPagado,"nPagado",nDivisa,"nDivisa",nDocCam,"nDocCam",nValCam,"nValCam"


         IF oTable:DOC_VALCAM=1 .OR. nValCam=1
            nMtoDif:=0
            nNeto  :=0
            nDivisa:=0
         ENDIF

         AADD(oCbtePag:aDocsC,{oTable:TDC_DESCRI,oTable:DOC_NUMERO,oTable:DOC_FECHA,;
                             IIF(oTable:DOC_CXC= 1 ,nPagado   ,0),;
                             IIF(oTable:DOC_CXC=-1 ,nPagado*-1,0),nDocCam,nDivisa,nMtoDif,nPagado+nMtoDif,lRetIslr,lRetIva,lRetMun})

         oTable:Replace("DOC_DIFCAM",nMtoDif)

       ENDIF

     ENDIF

     oTable:DbSkip()

  ENDDO

  oCbtePag:aDocOrgCli:=ACLONE(oTable:aDataFill)

// ViewArray(oCbtePag:aDocOrgCli)

  IF !lSave

     FOR I=1 TO LEN(aCopy)
       nAt:=ASCAN(oCbtePag:aDocsC,{|a,n|aCopy[I,1]=a[1] .AND. aCopy[I,2]=a[2]})

       IF nAt>0 

         IF aCopyOrg[I,9]
       // se quito los dos 2.0
       //    oCbtePag:aDocsC[nAt,4]  :=IIF(aCopy[I,4]<>0 , MIN( aCopy[I,4] , oCbtePag:aDocsC[nAt,4] ) , oCbtePag:aDocsC[nAt,4] )
       //    oCbtePag:aDocsC[nAt,5]  :=IIF(aCopy[I,5]<>0 , MIN( aCopy[I,5] , oCbtePag:aDocsC[nAt,5] ) , oCbtePag:aDocsC[nAt,5] )
           oCbtePag:aDocOrgCliCli[nAt,9]:=aCopyOrg[I,9]

         ENDIF
//       oCbtePag:aDocOrgCliCli[nAt,9]:=aCopyOrg[I,9]
       ENDIF
     NEXT I

  ENDIF

  oCbtePag:aDatView:=IIF(oCbtePag:nOption=0,oCbtePag:aDocsC,{})
  oCbtePag:oBrwDC:aArrayData:=ACLONE(oCbtePag:aDocsC)

  oCbtePag:oBrwDC:nArrayAt:=1
  oCbtePag:oBrwDC:nRowSel :=1

  EJECUTAR("BRWCALTOTALES",oCbtePag:oBrwD,.F.)
  EJECUTAR("BRWCALTOTALES",oCbtePag:oBrw ,.F.)

  oCbtePag:oBrwDC:Refresh(.F.)  
  oCbtePag:oBrwDC:GoTop(.T.)  
  oCbtePag:oBrwDC:DrawLine(.T.)

  oTable:End()

  SysRefresh(.T.)

//  oCbtePag:PUTDEBCRE(NIL,0,4,.F.)

RETURN .T.
// EOF

