// Programa   : DPBUILDWHERE
// Fecha/Hora : 17/06/2005 18:17:31
// Prop¢sito  : Crear Where para Restricciones por Usuario
// Creado Por : Juan Navas
// Llamado por: DPLOADCN
// Aplicaci¢n : 
// Tabla      : 

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cUsuario,lSet)
   LOCAL cWhere:="",cWhereInv:="",oTable,cWhereCli:="",cWherePro:=""
   LOCAL aTablasCta:={},aCta:={},nAt,aCodigos:={}
   LOCAL oDb:=OpenOdbc(oDp:cDsnData)
   LOCAL aData :=oDb:GetTables()

   IF LEN(aData)<10
      oDp:oMeter:=NIL
      oDp:oSay  :=NIL
      EJECUTAR("DPCREATEFROMDPTABLAS")
   ENDIF

//   EJECUTAR("DPCAMPOSADD","DPTABXUSU","TXU_KEY","C",20,0,"Clave Primaria")
    
   // Filtro de Tablas por Usuarios

   oDp:aTabXUsu:={}


   DEFAULT cUsuario      :=oDp:cUsuario,;
           lSet          :=.T.,;
           oDp:lInvConsol:=.F.,;
           oDp:cCtaTip   :="C"

   // Solo Empresas Permitidas

   oDp:aExcluye  :={} // Release todas las Exclusiones JN 17/09/2014

   IF !EJECUTAR("DBISTABLE",oDp:cDsnData,"dptabxusu",.F.)
      RETURN .T.
   ENDIF

   SQLDELETE("dptabxusu",[TXU_KEY LIKE "%,%"])

   SETEXCLUYE("DPPANELERPEMP","ERP_CODEMP"+GetWhere("=",oDp:cEmpCod))

   cWhere       :=WHEREEMPUSU("DPEMPRESA","EMP_CODIGO")

   SETEXCLUYE("DPEMPRESA"    , cWhere  )

   cWhere       :=WHEREEMPUSU("DPBRW","BRW_CODIGO")
   SETEXCLUYE("DPBRW"    , cWhere  )

   cWhere       :=WHEREEMPUSU("DPBRWCLASIFICA","CBR_CODIGO")
   SETEXCLUYE("DPBRWCLASIFICA"    , cWhere  )

   IF .T.
//oDp:nVersion>=6

     aTablasCta:=ASQL([SELECT LNK_TABLED FROM DPLINK WHERE LNK_FIELDD LIKE "%CIC_CODIGO%" AND LNK_TABLED LIKE "%_CTA"])

     IF oDp:cCtaMod<>NIL .AND. COUNT("DPCTAMODELO")>1
      SETEXCLUYE("DPCTA","DPCTA.CTA_CODMOD"+GetWhere("=",oDp:cCtaMod  ),"")
      AEVAL(aTablasCta,{|a,n|SETEXCLUYE(a[1], "CIC_CTAMOD"+GetWhere("=",oDp:cCtaMod  ),"") })
    ELSE
      SETEXCLUYE("DPCTA","")
      AEVAL(aTablasCta,{|a,n|SETEXCLUYE(a[1],"") })
    ENDIF

   ENDIF

   // Cuentas Inactivas

   IF oDp:cSucursal<>NIL
     SETEXCLUYE("DPEJERCICIOS" , "EJE_CODSUC"+GetWhere("=",oDp:cSucursal),"")
     SETEXCLUYE("DPACTIVOS"    , "ATV_CODSUC"+GetWhere("=",oDp:cSucursal),"") // JN 17/09/2014
   ENDIF

   // Con esto se hace la prueba del filtro de las empresas
   // DPLBX("DPEMPRESA")

   oDp:cWhereTF28:="T28_ANO"+GetWhere("=",STRZERO(YEAR(oDp:dFechaIni),4))

   // si no hay restricciones, se devuelve sin necesidad de hacer consultas.
   IF COUNT("DPTABXUSU")=0 .AND. COUNT("DPTABXSUC")=0
      RETURN NIL
   ENDIF

   // Asigna Filtro para todas las Tablas, Asi evitamos indicar una por una
   EJECUTAR("DPTABXUSUFILTER") 

   // JN 29/04/2014
   DEFAULT oDp:lInvXSuc:=.F.,;
           oDp:lCliXSuc:=.F.,;
           oDp:lProXSuc:=.F.


   oDp:lInvXSuc:=CTOO(oDp:lInvXSuc,"L")
   oDp:lCliXSuc:=CTOO(oDp:lCliXSuc,"L")
   oDp:lProXSuc:=CTOO(oDp:lProXSuc,"L")

   oDp:cWhereInv:=""
   oDp:cWhereCli:=""
   oDp:cWherePro:=""

   IF oDp:lInvXSuc
     oDp:cWhereInv    :=WHERETABXUSU("=",cUsuario,"DPINV"        ,"INV_CODIGO")
   ENDIF

   IF oDp:lCliXSuc
     oDp:cWhereCli    :=WHERETABXUSU("=",cUsuario,"DPCLIENTES"   ,"CLI_CODIGO")
   ENDIF

   IF oDp:lProXSuc
      oDp:cWherePro    :=WHERETABXUSU("=",cUsuario,"DPPROVEEDOR"  ,"PRO_CODIGO")
   ENDIF

   oDp:cWhereGru    :=WHERETABXUSU("=",cUsuario,"DPGRU"        ,"GRU_CODIGO")

// ? oDp:cWhereGru,"oDp:cWhereGru"

   oDp:cWhereMarcas :=WHERETABXUSU("=",cUsuario,"DPMARCAS"     ,"MAR_CODIGO")
   oDp:cWhereInvGru :=WHERETABXUSU("=",cUsuario,"DPGRU"        ,"INV_GRUPO" )
   oDp:cWhereInvMar :=WHERETABXUSU("=",cUsuario,"DPMARCAS"     ,"INV_CODMAR")
//   oDp:cWhereTipPre :=WHERETABXUSU("=",cUsuario,"DPPRECIOTIP"  ,"TPP_CODIGO")
//   oDp:cWherePrecio :=WHERETABXUSU("=",cUsuario,"DPPRECIOTIP"  ,"PRE_LISTA" )
//   oDp:cWhereSerFis :=WHERETABXUSU("=",cUsuario,"DPSERIEFISCAL","SFI_MODELO")
//   oDp:cWhereCtaEgr :=WHERETABXUSU("=",cUsuario,"DPCTAEGRESO"  ,"CEG_CODIGO")
//   oDp:cWhereSucurs :=WHERETABXUSU("=",cUsuario,"DPSUCURSAL"   ,"SUC_CODIGO")
//   oDp:cWhereCenCos :=WHERETABXUSU("=",cUsuario,"DPCENCOS"     ,"CEN_CODIGO")
//   oDp:cWhereCaja   :=WHERETABXUSU("=",cUsuario,"DPCAJA"       ,"CAJ_CODIGO")
   oDp:cWhereClaCli :=WHERETABXUSU("=",cUsuario,"DPCLICLA"     ,"CLC_CODIGO")
   cWhereCli        :=WHERETABXUSU("=",cUsuario,"DPCLICLA"     ,"CLI_CODCLA")
   cWherePro        :=WHERETABXUSU("=",cUsuario,"DPPROCLA"     ,"PRO_CODCLA")
//   oDp:cWhereMoneda :=WHERETABXUSU("=",cUsuario,"DPTABMON"     ,"MON_CODIGO")
//   oDp:cWhereAlm    :=WHERETABXUSU("=",cUsuario,"DPALMACEN"    ,"ALM_CODIGO",oDp:cSucursal)
//   oDp:cWhereTDocPro:=WHERETABXUSU("=",cUsuario,"DPTIPDOCPRO"  ,"TDC_TIPO",NIL,.T.)
//   oDp:cWhereTDocCli:=WHERETABXUSU("=",cUsuario,"DPTIPDOCCLI"  ,"TDC_TIPO",NIL,.T.)
//   oDp:cWhereCajInst:=WHERETABXUSU("=",cUsuario,"DPCAJAINST"   ,"ICJ_CODIGO")

   IF !Empty(oDp:cWhereAlm)
      oDp:cWhereAlm:="ALM_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+oDp:cWhereAlm
   ENDIF

   IF !Empty(oDp:cWhereInvGru) 
     cWhereInv:=oDp:cWhereInvGru+IIF(Empty(oDp:cWhereInvMar),""," OR "+oDp:cWhereInvMar)
   ELSE
     cWhereInv:=oDp:cWhereInvMar+IIF(Empty(oDp:cWhereInvGru),""," OR "+oDp:cWhereInvGru)
   ENDIF

   // JN 24/02/2014
   IF !Empty(cWhereInv)
     cWhereInv:=oDp:cWhereInv
   ELSE
     IF !Empty(oDp:cWhereInv)
       cWhereInv:=cWhereInv+IF(Empty(cWhereInv),"", " AND ")+oDp:cWhereInv
     ENDIF
   ENDIF

   // JN 24/02/2014
   IF !Empty(cWhereCli)
     cWhereCli:=oDp:cWhereCli
   ELSE
     IF !Empty(oDp:cWhereCli)
       cWhereCli:=cWhereCli+IF(Empty(cWhereCli),"", " AND ")+oDp:cWhereCli
     ENDIF
   ENDIF

   // JN 24/02/2014
   IF !Empty(cWherePro)
     cWherePro:=oDp:cWherePro
   ELSE
    IF !Empty(oDp:cWherePro)
      cWherePro:=cWherePro+IF(Empty(cWherePro),"", " AND ")+oDp:cWherePro
    ENDIF
   ENDIF

   // Determina las Sucursales que Comparten el Inventario
   oDp:aSucConsol:={}
   oDp:cWhereExi :=""

   IF ValType(oDp:lInvConsol)="L" .AND. oDp:lInvConsol .AND. !Empty(oDp:cSucursal)
     oDp:aSucConsol:=ASQL("SELECT SUC_CODIGO FROM DPSUCURSAL WHERE SUC_INVCSL=1 OR SUC_CODIGO"+GetWhere("=",oDp:cSucursal))
     oDp:cWhereExi :=GetWhereOr("MOV_CODSUC",oDp:aSucConsol)
   ENDIF

   cWhereInv:=STRTRAN(cWhereInv,")) OR ((",") OR (")
   cWhereCli:=STRTRAN(cWhereCli,")) OR ((",") OR (")
   cWherePro:=STRTRAN(cWherePro,")) OR ((",") OR (")

   IF lSet

      SETEXCLUYE("DPGRU"        ,oDp:cWhereGru      )
      SETEXCLUYE("DPINV"        , cWhereInv         )
      SETEXCLUYE("DPCLIENTES"   , cWhereCli         ) // oDp:cWhereCli     )
      SETEXCLUYE("DPPROVEEDOR"  , cWherePro         ) // oDp:cWherePro     )
      SETEXCLUYE("DPPRNREMOTO"  , " ( PRN_PC"+GetWhere("<>",oDp:cPcName)+" AND PRN_TODOS=1 )")

   ENDIF

   // Los Almacenes se define x Sucursal
   // oDp:cWhereAlm:="ALM_CODSUC"+GetWhere("=",oDp:cSucursal )
   oDp:aMonedas:=aTable("SELECT MON_CODIGO,MON_DESCRI FROM DPTABMON",.T.)

//  ViewArray(oDp:aExcluye)

RETURN cWhere

FUNCTION WHERETABXUSU(cOper,cUsuario,cTabla,cField,cCodSuc,lSay)
   LOCAL cWhere:="",I,nAt,cWhereUsu:=""
   LOCAL aCodigos:={},cWhereSuc:=""

   DEFAULT cUsuario:=oDp:cUsuario,;
           cOper   :="=",;
           cTabla  :="DPGRU",;
           cField  :="GRU_CODIGO",;
           cCodSuc :="",;
           lSay    :=.F.

   cWhereUsu:=" AND TXU_CODUSU"+GetWhere(cOper,cUsuario)+;
              " AND TXU_PERMIS=0 "+;
              IIF( !Empty(cCodSuc) , " AND TXU_CODSUC"+GetWhere("=",cCodSuc),"")

   // Departamentos
   aCodigos:=ATABLE(" SELECT TXU_CODIGO FROM DPTABXUSU WHERE"+;
                    " TXU_TABLA "+GetWhere("=",cTabla)+cWhereUsu+;
                    " GROUP BY TXU_CODIGO ")

   cWhere:=GetWhereOr(cTabla+"."+cField,aCodigos)

   IF !Empty(cWhere)
      cWhere:="("+cWhere+")"
   ENDIF

   // Restricciones por Sucursal

   IF oDp:nVersion>=5 

     aCodigos:=ATABLE(" SELECT RXS_CLAVE FROM DPTABXSUC WHERE"+;
                      " RXS_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
                      " RXS_TABLA "+GetWhere("=",cTabla       )+" AND "+;
                      " RXS_SELECT"+GetWhere("=",1            )+;
                      " GROUP BY RXS_CLAVE ")

     cWhereSuc:=GetWhereOr(cTabla+"."+cField,aCodigos)

     IF !Empty(cWhereSuc)

        cWhereSuc:=" NOT ("+cWhereSuc+")"
        cWhere   :=cWhere + IIF( Empty(cWhere) , "", " AND ")+cWhereSuc

     ENDIF

   ENDIF

   AADD(oDp:aTabXUsu,{cTabla,cWhere})

RETURN cWhere

FUNCTION WHEREEMPUSU(cTable,cField)
   LOCAL aCodEmp:={},cWhere:=""

   DEFAULT cTable:="DPEMPRESA",;
           cField:="EMP_CODIGO"

   SETEXCLUYE(cTable,"" )

   aCodEmp:=ASQL(" SELECT EXU_CODIGO FROM DPEMPUSUARIO "+;
                 " WHERE EXU_TABLA "+GetWhere("=",cTable       )+" AND "+;
                 "       EXU_CODUSU"+GetWhere("=",oDp:cUsuario )+" AND "+;
                 "       EXU_SELECT=1")

   IF !Empty(aCodEmp)

       aCodEmp:=ASQL("SELECT "+cField+" FROM "+cTable+" WHERE NOT "+;
                GetWhereOr(cField,aCodEmp))

       cWhere :=GetWhereOr(cTable+"."+cField,aCodEmp)

   ENDIF

RETURN cWhere

// EOF

