// Programa   : DPCALAJUFICACT
// Fecha/Hora : 20/07/2011 01:18:43
// Propósito  : Calcular el ajuste Fiscal por Activo
// Creado Por : Daniel Vegas
// Llamado por: Activo Fijo
// Aplicación : Activo
// Tabla      : DPACTIVO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cModAjs)

  LOCAL oBtn,oFont,oBrw,oCol,aData,aUnd,oBrwU,nAt
  LOCAL cFchAct:=oDp:dFecha,cTitle:=""
  LOCAL dFecha :=oDp:dFecha


  // FS=Fiscal FN=Financiero 
 
  DEFAULT cModAjs:="FS" 

  dFecha :=CTOD(SQLGET([DPIPC],[CONCAT("01/",IPC_MES,"/",IPC_ANO)],[IPC_TASA>0 ORDER BY CONCAT(IPC_ANO,IPC_MES) DESC LIMIT 1]))

  IF Empty(dFecha)
     MensajeErr("No hay Indices de Precios al Consumidor")
     RETURN .F.
  ENDIF

  cTitle:=IIF(cModAjs="FS","Fiscal","Financiero DPC-10")

  DEFINE FONT oFont NAME "Arial"   SIZE 0, -10 BOLD

  DPEDIT():New("Calculo de Ajuste ["+cTitle+"] por Activo ","FORMS\DPCALAJUFICACT.EDT","oActAju",.T.)

  oActAju:cGruIni  :=SPACE(06)
  oActAju:cFchAct  :=dFecha
  oActAju:cGruFin  :=SPACE(06)
  oActAju:cCodInv1 :=SPACE(20)
  oActAju:cCodInv2 :=SPACE(20)
  oActAju:cModAjs  :=cModAjs
  oActAju:cGruWhere:=""
  oActAju:nRecord  :=0
  oActAju:lMsgBar  :=.F.
  oActAju:cCodSuc  :=oDp:cSucursal
  oActAju:lUpdate  :=.F.
  oActAju:cComent  :=PADR("Elaborado por "+oDp:cUsuario,50)
 
  oActAju:nCuantos:=0
  oActAju:lMsgBar :=.F.

  @ 8,1 GROUP oBtn TO 4, 21.5 PROMPT " Activos "
  @ 8,1 GROUP oBtn TO 4, 21.5 PROMPT " Grupos "

  @ .1,1 SAY "Desde:"
  @ 1,1 BMPGET oActAju:oGruIni VAR oActAju:cGruIni;
               VALID oActAju:ValGruIni();
               NAME "BITMAPS\FIND.BMP"; 
               ACTION (oDpLbx:=DpLbx("DPACTIVOS",NIL,NIL),;
                       oDpLbx:GetValue("ATV_CODIGO",oActAju:oGruIni)); 
               SIZE 48,10

  @ .1,1 SAY "Hasta:"
  @ 1,1 BMPGET oActAju:oGruFin VAR oActAju:cGruFin;
               VALID oActAju:ValGruFin();
               WHEN !Empty(oActAju:cGruIni);
               NAME "BITMAPS\FIND.BMP"; 
               ACTION (oDpLbx:=DpLbx("DPACTIVOS",NIL,NIL),;
                       oDpLbx:GetValue("ATV_CODIGO",oActAju:oGruFin)); 
               SIZE 48,10

  @ 0,0 SAY oActAju:oSayGruIni PROMPT MYSQLGET("DPACTIVOS","ATV_DESCRI","ATV_CODIGO"+GetWhere("=",oActAju:cGruIni))
  @ 0,0 SAY oActAju:oSayGruFin PROMPT MYSQLGET("DPACTIVOS","ATV_DESCRI","ATV_CODIGO"+GetWhere("=",oActAju:cGruFin))

  @ 5,5 SAY oActAju:oSayProgress PROMPT "Comentarios"
  @ 5,5 SAY oActAju:oSayNum      PROMPT "Registro: 0/0"

  @ 0,1 SAY "Desde:" RIGHT
  @ 1,1 SAY "Hasta:" RIGHT

  @ 4,1 SAY oActAju:oSayRecord PROMPT "  "

  @ .1,06 BMPGET oActAju:oCodInv1 VAR oActAju:cCodInv1;
                 VALID oActAju:FindCodAtv(oActAju:cCodInv1,oActAju:oCodInv1);
                 NAME "BITMAPS\FIND.BMP"; 
                 ACTION (oDpLbx:=DpLbx("DPGRUACTIVOS",NIL,NIL),;              
                         oDpLbx:GetValue("GAC_CODIGO",oActAju:oCodInv1)); 
                SIZE 48,10

  @ 3,2 SAY oActAju:oInvNombre1 PROMPT MYSQLGET("DPGRUACTIVOS","GAC_DESCRI","GAC_CODIGO"+GetWhere("=",oActAju:cCodInv1))
            

  @ 1 ,06 BMPGET oActAju:oCodInv2 VAR oActAju:cCodInv2;
                 VALID oActAju:VALCOD2() .AND. ;
                       oActAju:FindCodAtv(oActAju:cCodInv2,oActAju:oCodInv2);
                 NAME "BITMAPS\FIND.BMP"; 
                 ACTION (oDpLbx:=DpLbx("DPGRUACTIVOS",NIL,NIL),;
                         oDpLbx:GetValue("GAC_CODIGO",oActAju:oCodInv2)); 
                SIZE 48,20

  @ 3,2 SAY oActAju:oInvNombre2 PROMPT MYSQLGET("DPGRUACTIVOS","GAC_DESCRI","GAC_CODIGO"+GetWhere("=",oActAju:cCodInv2));
            UPDATE

  @ 0,1 SAY "Calculo al :" RIGHT

  @ .5,3.5 BMPGET oActAju:oFchAct VAR oActAju:cFchAct;
                  SIZE 46,10;
                  NAME "BITMAPS\Calendar.bmp";
                  ACTION LbxDate(oActAju:oFchAct ,oActAju:cFchAct)


  @ 11,5   GET oActAju:cComent 


  @ 2,2 METER oActAju:oMeter VAR oActAju:nCuantos

  oActAju:Activate({||oActAju:ViewDatBar()})

RETURN

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oActAju:oDlg,oBtnCal

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILE "BITMAPS\RUN.BMP";
          ACTION (oActAju:DPRUNAXI())

   oBtn:cToolTip:="Ejecutar"
   oBtn:cMsg    :=oBtn:cToolTip

   oActAju:oBtnRun:=oBtn

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILE "BITMAPS\ACTIVOS.BMP";
          ACTION EJECUTAR("DPACTXDEP")

   oBtn:cToolTip:="Activos por Depreciar"
   oBtn:cMsg    :=oBtn:cToolTip



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oActAju:Close()

  oBar:SetColor(CLR_BLACK,oDp:nGris )

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oActAju:oBar:=oBar

RETURN .T.



FUNCTION VALGRUINI()

  IF Empty(oActAju:cGruIni)
      RETURN .T.
  ENDIF

  oActAju:cGruWhere:=""

  IF !ISMYSQLGET("DPACTIVOS","ATV_CODIGO",oActAju:cGruIni)
     oActAju:oGruIni:KeyBoard(VK_F6)
  ELSE
     oActAju:cGruWhere:="GAC_CODIGO"+GetWhere("=",oActAju:cGruIni)
  ENDIF

  oActAju:oSayGruIni:Refresh(.T.)

RETURN .T.


FUNCTION VALGRUFIN()

  IF Empty(oActAju:cGruFin)
     oActAju:oGruFin:VarPut(oActAju:cGruIni,.T.)
  ENDIF

  oActAju:cGruWhere:=""

  IF !ISMYSQLGET("DPACTIVOS","ATV_CODIGO",oActAju:cGruFin) .OR.  oActAju:cGruIni>oActAju:cGruFin

     oActAju:oGruFin:KeyBoard(VK_F6)

  ELSE

     oActAju:cGruWhere:=GetWhereAnd("GAC_CODIGO",oActAju:cGruIni,oActAju:cGruFin)

  ENDIF

  oActAju:oSayGruFin:Refresh(.T.)

RETURN .T.

FUNCTION PutCrear(nCol)
  LOCAL uValue:=oActAju:oBrwU:aArrayData[oActAju:oBrwU:nArrayAt,nCol]

  DpFocus(oActAju:oBrwU)

  oActAju:oBrwU:aArrayData[oActAju:oBrwU:nArrayAt,nCol]:=!uValue

  oActAju:oBrwU:DrawLine(.T.)

//  IF nCol=4
//    oActAju:oBrwU:KeyBoard(VK_DOWN)
//  ENDIF
  
RETURN .T.

FUNCTION FINDCODATV(cCod,oGet)

   oActAju:oInvNombre1:Refresh(.T.) 
   oActAju:oInvNombre2:Refresh(.T.) 

   IF !ISMYSQLGET("DPGRUACTIVOS","GAC_CODIGO",cCod)

      oGet:KEYBOARD(VK_F6)

      RETURN .F.

   ENDIF

RETURN .T.

FUNCTION VALCOD2()
   LOCAL cSwap:=oActAju:cCodInv2

   IF !Empty(oActAju:cCodInv1) .AND. Empty(oActAju:cCodInv2)
       oActAju:oCodInv2:VarPut(oActAju:cCodInv1,.T.)
   ENDIF

   IF oActAju:cCodInv1>oActAju:cCodInv2

     oActAju:oCodInv2:VarPut(oActAju:cCodInv1,.T.)
     oActAju:oCodInv1:VarPut(cSwap,.T.)

   ENDIF
   
RETURN .T.

/*
// Ejecutar Ajuste por Inflación 
*/
FUNCTION DPRUNAXI()
  LOCAL cWhere:=NIL
  LOCAL cCodSuc:=oDp:cSucursal

  EJECUTAR("DPCALAXIACT",cWhere,cCodSuc,oActAju:cFchAct,oActAju:cModAjs,oActAju:oMeter,oActAju:oSayRecord)

RETURN .F.

// EOF
