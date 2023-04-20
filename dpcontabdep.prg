// Programa   : DPCONTABDEP
// Fecha/Hora : 08/04/2006 10:46:33
// Propósito  : Contabilizar Depreciación
// Creado Por : Curso 08/04
// Llamado por: MENU CONTABILIDAD
// Aplicación : Depreciación
// Tabla      : DPDEPRECIAACT
// 06-08-2008  Inclusion de Asignacion de Numero Cbte desde DPNUMCBTE

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL oBtn,oFont,oBrw,oCol,aData

  EJECUTAR("BRDEPXCONTAB")


RETURN NIL


  aData:=ASQL("SELECT TDC_TIPO,TDC_DESCRI,0 AS LOGICA FROM DPTIPDOCCLI WHERE TDC_CXC<>'N' "+;
              " AND TDC_CONTAB=1  ORDER BY TDC_TIPO")

  AEVAL(aData,{|a,n|aData[n,3]:=.T. })

  DEFINE FONT oFont NAME "Arial"   SIZE 0, -14

  DPEDIT():New("Contabilizar Depreciación","FORMS\DPCONTABDEP.EDT","oConAct",.T.)

  oConAct:dDesde  :=FchIniMes(oDp:dFecha)
  oConAct:dHasta  :=FchFinMes(oDp:dFecha)
  oConAct:cCodGru :=SPACE(8)
  oConAct:cCodAct :=SPACE(15)
  oConAct:cNumero :=EJECUTAR("DPNUMCBTE","ACTFIJ")
  oConAct:nCuantos:=0
  oConAct:lMsgBar :=.F.

  @ 1,1 GROUP oBtn TO 2, 21.5 PROMPT " Seleccionar Activos "

  @ 1,1 GROUP oBtn TO 2, 21.5 PROMPT " Periodo de Depreciación"

  @ 1, 1.0 BMPGET oConAct:oCodGru  VAR oConAct:cCodGru ;
                  NAME "BITMAPS\FIND.BMP"; 
                  ACTION (oDpLbx:=DpLbx("DPGRUACTIVOS",NIL),;
                          oDpLbx:GetValue("GAC_CODIGO",oConAct:oCodGru)); 
                  VALID oConAct:VALCODGRU()


  @ 2, 1.0 BMPGET oConAct:oCodAct  VAR oConAct:cCodAct ;
                  NAME "BITMAPS\FIND.BMP"; 
                  ACTION (oDpLbx:=DpLbx("DPACTIVOS",NIL),;
                          oDpLbx:GetValue("ATV_CODIGO",oConAct:oCodAct)); 
                  VALID oConAct:VALCODACT()




   @ .1,1 SAY "Desde:"

   @ 1,1 BMPGET oConAct:oDesde VAR oConAct:dDesde;
                PICTURE "99/99/9999";
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oConAct:oDesde ,oConAct:dDesde);
                SIZE 41,10

   @ .1,1 SAY "Hasta:"

   @ 1,1 BMPGET oConAct:oHasta VAR oConAct:dHasta;
                PICTURE "99/99/9999";
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oConAct:oHasta ,oConAct:dHasta);
                SIZE 41,10

  @ 2,2 SAY "Comprobante:"
  @ 5,5 GET oConAct:cNumero

  @ 5,5 SAY oConAct:oSayProgress PROMPT "Lectura de Activos"


  @ 1,1 SAY oConAct:oSayGru PROMPT MYSQLGET("DPGRUACTIVOS","GAC_DESCRI",;
                                            "GAC_CODIGO"+GetWhere("=",oConAct:cCodGru))

  @ 2,1 SAY oConAct:oSayAct PROMPT MYSQLGET("DPACTIVOS","ATV_DESCRI",;
                                            "ATV_CODIGO"+GetWhere("=",oConAct:cCodAct))

  @ 1,1 SAY GetFromVar("{oDp:xDPGRUACTIVOS}")
  @ 2,1 SAY GetFromVar("{oDp:xDPACTIVOS}")

  @ 2,2 METER oConAct:oMeter VAR oConAct:nCuantos

  @09, 33 SBUTTON oBtn ;
          FILE "BITMAPS\RUN.BMP" ;
          FONT oFont;
          LEFT PROMPT "Ejecutar";
          NOBORDER;
          COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
          ACTION oConAct:HACERASIENTO()
  
  oBtn:cToolTip:="Ejecutar Proceso de Contabilizacion"
                 
  @10, 20  SBUTTON oBtn ;
           FONT oFont;
           FILE "BITMAPS\XSALIR.BMP" ;
           LEFT PROMPT "Cerrar";
           NOBORDER;
           COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
           ACTION oConAct:Close()

  //oBtn:cToolTip:="Cerrar"


  oConAct:Activate()

RETURN

FUNCTION INICIO()
RETURN .T.


FUNCTION HACERASIENTO()
  LOCAL oTable,cSql,cWhere
  LOCAL aTipDoc:={}

  cWhere:="ATV_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND "+;
          "(ATV_ESTADO='A' OR ATV_ESTADO=' ')"


  IF !Empty(oConAct:cCodAct)
     cWhere:=ADDWHERE(cWhere,"ATV_CODIGO"+GetWhere("=",oConAct:cCodAct))
  ENDIF


  IF !Empty(oConAct:cCodGru)
     cWhere:=ADDWHERE(cWhere,"ATV_CODGRU"+GetWhere("=",oConAct:cCodGru))
  ENDIF
 
  cWhere:=ADDWHERE(cWhere,GetWhereAnd("DEP_FECHA",oConAct:dDesde,oConAct:dHasta))

  cSql:="SELECT ATV_CODIGO,ATV_DESCRI FROM DPACTIVOS "+;
        "INNER JOIN DPDEPRECIAACT ON ATV_CODIGO=DEP_CODACT "+;
        "WHERE "+cWhere+" "+;
        "GROUP BY ATV_CODIGO,ATV_DESCRI"


  oTable:=OpenTable(cSql,.T.)

  IF oTable:RecCount()=0

     oTable:End()

     MensajeErr("No hay Depreciaciones para Contabilizar en el Periodo "+DTOC(oConAct:dDesde)+;
                DTOC(oConAct:dHasta))



     RETURN .F.

  ENDIF

  oConAct:oMeter:SetTotal(oTable:RecCount())

  WHILE !oTable:Eof()

     oConAct:oMeter:Set(oTable:RecNo())
     oConAct:oSayProgress:SetText(LSTR(oTable:Recno())+"/"+LSTR(oTable:RecCount())+;
                                 " Activo: "+ALLTRIM(oTable:ATV_CODIGO)+" "+ALLTRIM(oTable:ATV_DESCRI))


     EJECUTAR("DPACTCONTAB", NIL,oDp:cSucursal,;
                                 oTable:ATV_CODIGO,;
                                 oConAct:dDesde,oConAct:dHasta,.F.)

     oTable:DbSkip()

  ENDDO

  oTable:End()

  MensajeErr(LSTR(oTable:RecCount())+" Activo(s) Depreciado(s)","Proceso Finalizado")

  oConAct:oSayProgress:SetText("")
  oConAct:oMeter:Set(0)
  oConAct:oMeter:Refresh(.T.)

RETURN .T.

FUNCTION VALCODGRU()

   oConAct:oSayGru:Refresh(.T.)

   IF Empty(oConAct:cCodGru)
      RETURN .T.
   ENDIF
 
   IF !ISMYSQLGET("DPGRUACTIVOS","GAC_CODIGO",oConAct:cCodGru)
      oConAct:oCodGru:KeyBoard(VK_F6)
   ENDIF

RETURN .T.

FUNCTION VALCODACT()

   oConAct:oSayAct:Refresh(.T.)

   IF Empty(oConAct:cCodAct)
      RETURN .T.
   ENDIF
 
   IF !ISMYSQLGET("DPACTIVOS","ATV_CODIGO",oConAct:cCodAct)
      oConAct:oCodAct:KeyBoard(VK_F6)
   ENDIF

RETURN .T.
