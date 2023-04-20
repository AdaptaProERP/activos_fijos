// Programa   : DPDEPREC
// Fecha/Hora : 24/06/2006 15:08:26
// Propósito  : Calcular Depreciación de Activos
// Creado Por : Juan Navas
// Llamado por: DPACTMENU
// Aplicación : Activos
// Tabla      : DPDEPRECIA

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cCodAct)
  LOCAL I,aData:={},oFontG,oGrid,oCol,cSql,cWhere,oFont,oFontB
  LOCAL cTitle:=GETFROMVAR("{oDp:DPDEPRECIAACT}")
  LOCAL nMonto:=0

  DEFAULT cCodSuc:=oDp:cSucursal,;
          cCodAct:=STRZERO(1,5)

  
  // Font Para el Browse
  DEFINE FONT oFont  NAME "Times New Roman"   SIZE 0, -14
  DEFINE FONT oFontB NAME "Times New Roman"   SIZE 0, -12 BOLD

  oDepre:=DOCENC(cTitle,"oDepre","DPDEPRECIAACT.EDT")
  oDepre:cCodAct  :=cCodAct
  oDepre:cCodSuc  :=cCodSuc
  oDepre:nBtnStyle:=1
  oDepre:lBar     :=.F.
  oDepre:lAutoEdit:=.T.
  oDeprec:cScript :="DPDEPRECIA"


  oDepre:SetTable("DPACTIVOS","ATV_CODIGO"," WHERE ATV_CODIGO"+GetWhere("=",cCodAct))

  oDepre:Windows(0,0,425,735)

  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT "Activo [ "+ALLTRIM(oDepre:ATV_CODIGO)+" ]"
  @ 2,5 SAY oATV_DESCRI PROMPT oDepre:ATV_DESCRI

  cSql  :=" SELECT * FROM DPDEPRECIAACT"
  cWhere:=""

  oGrid:=oDepre:GridEdit( "DPDEPRECIAACT" , oDepre:cPrimary , "DEP_CODACT" , cSql , cWhere , "DEP_FECHA") 

  oGrid:cScript  :="DPDEPREC"
  oGrid:aSize    :={110-26+35,0,690,160+74}
  oGrid:bValid   :=".T."
  oGrid:lBar     :=.T.

  oGrid:cPostSave:="GRIDPOSTSAVE"
  oGrid:cLoad    :="GRIDLOAD"
  oGrid:cTotal   :="GRIDTOTAL" 
  oGrid:cPreSave :="GRIDPRESAVE"
  oGrid:oFontH   :=oFontB // Fuente para los Encabezados
  oGrid:oFont    :=oFont  // Fuente para los Encabezados
  oGrid:nClrPane1:=14612478
  oGrid:nClrPane2:=13104638
  oGrid:lTotal   :=.T.

  oGrid:nClrPaneH   :=4962803
  oGrid:nRecSelColor:=4962803
  oGrid:nClrTextH   :=CLR_BLACK


  oGrid:nClrPaneF:=4444924
  oGrid:nClrTextF:=CLR_BLACK

//  oGrid:AddBtn("xprint.bmp","imprimir Precios","oGrid:nOption=0","oGrid:GridPrint()")

  // Lista
  oCol:=oGrid:AddCol("DEP_FECHA")
  oCol:cTitle   :="Fecha"
//oCol:bValid   :={||oGrid:VPRE_LISTA(oGrid:PRE_LISTA)}
// oCol:cMsgValid:="Tipo de Precio no Existe"
  oCol:nWidth   :=90
//oCol:cListBox :="DPPRECIOTIP.LBX"
  oCol:lPrimary :=.T. // No puede Repetirse
//oCol:bPostEdit:='oGrid:ColCalc("TPP_DESCRI")'
//oCol:lRepeat  :=.T.
  oCol:nEditType:=EDIT_GET_BUTTON

  // Monto
  oCol:=oGrid:AddCol("DEP_MONTO")
  oCol:cTitle:="Monto"
  oCol:nWidth:=170
  oCol:lTotal:=.T.

  // Unidades Producidas
  oCol:=oGrid:AddCol("DEP_UNIPRO")
  oCol:cTitle:="Unid/Prod"
  oCol:nWidth:=110
  oCol:lTotal:=.T.

  // Precio de Venta
  oCol:=oGrid:AddCol("DEP_COMPRO")
  oCol:cTitle:="Comprobante"
  oCol:nWidth:=90

  // Fecha de Contabilización
  oCol:=oGrid:AddCol("DEP_FCHCON")
  oCol:cTitle:="Fecha Cont."
  oCol:nWidth:=90

  // % de Depreciación
  oCol:=oGrid:AddCol("DEP_PORCEN")
  oCol:cTitle:="%"
  oCol:nWidth:=45

  // Precio de Venta
  oCol:=oGrid:AddCol("DEP_ESTADO")
  oCol:cTitle:="Edo"
  oCol:nWidth:=40

  oDepre:oFocus:=oGrid:oBrw
  oDepre:Activate()

RETURN

/*
// Carga los Datos
*/
FUNCTION LOAD()

   IF oDepre:nOption=1
   ENDIF

RETURN .T.

/*
// Carga de data del Grid
*/
FUNCTION GRIDLOAD()
RETURN .T.

/*
// Pregrabar del Grid
*/
FUNCTION GRIDPRESAVE()

  oGrid:PRE_UNDMED:=oDepre:cCodUnd

RETURN .T.

/*
// Ejecuta la Impresión del Documento
*/
FUNCTION PRINTER()
   ? "IMPRIMIR"
RETURN .T.

/*
// Permiso para Borrar
*/
FUNCTION PREDELETE()
RETURN .T.

/*
// Después de Borrar
*/
FUNCTION POSTDELETE()
RETURN .T.

/*
// Valida el Código
*/
FUNCTION VPRE_LISTA(cLista)
  LOCAL lRet

  oGrid:PRE_UNDMED:=LEFT(oDepre:cCodUnd,oDepre:nLenUnd)
  oGrid:PRE_CODMON:=LEFT(oDepre:cCodMon,oDepre:nLenMon)

  lRet:=(cLista==SQLGET("DPPRECIOTIP","TPP_CODIGO","TPP_CODIGO"+GetWhere("=",cLista)))

RETURN lRet

/*
// Carga para Incluir o Modificar en el Grid
*/
FUNCTION GRIDLOAD()
  LOCAL cLista:=""

  IF oGrid:nOption=1
/*
     IF oGrid:RecCount()=1 // Primero
        cLista:=SqlGetMin("DPPRECIOTIP","TPP_CODIGO")
     ELSE
        cLista:=oGrid:oBrw:aArrayData[oGrid:oBrw:nArrayAt-1,1]
        cLista:=SqlGetMin("DPPRECIOTIP","TPP_CODIGO","TPP_CODIGO"+GetWhere(">",cLista))
     ENDIF

     oGrid:Replace("PRE_LISTA",cLista,.T.)
     oGrid:ColCalc("TPP_DESCRI")
     oGrid:PRE_CODMON:=LEFT(oDepre:cCodMon,oDepre:nLenMon)
*/

  ENDIF

RETURN NIL

/*
// Ejecución despues de Grabar el Item
*/
FUNCTION GRIDPOSTSAVE()
RETURN .T.

/*
// Genera los Totales por Grid
*/
FUNCTION GRIDTOTAL()
RETURN .T.

FUNCTION GRIDSETSCOPE()
   LOCAL cWhere

   cWhere:=" PRE_UNDMED "+GetWhere("=",LEFT(oDepre:cCodUnd,oDepre:nLenUnd))+ " AND "+;
           " PRE_CODMON "+GetWhere("=",LEFT(oDepre:cCodMon,oDepre:nLenMon))

   oDepre:aGrids[1]:SetScope(cWhere)
   oDepre:oCantid:Refresh(.T.)

   oGrid:PRE_CODMON:=LEFT(oDepre:cCodMon,oDepre:nLenMon)

RETURN .T.

/*
// Realiza un Salto de Valor en el Combo
*/
FUNCTION COMBOSKIP(oCombo,nSkip,lChange)
   LOCAL nAt,uValue
   DEFAULT nSkip:=1,lChange:=.T.

   IF ValType(oCombo)!="O"
      RETURN .F.
   ENDIF

   oCombo:nAt:=oCombo:nAt+(nSkip)

   IF oCombo:nAt>LEN(oCombo:aItems)
      oCombo:nAt:=1
   ENDIF

   IF oCombo:nAt<1
      oCombo:nAt:=Len(oCombo:nAt)
   ENDIF

   uValue:=oCombo:aItems[oCombo:nAt]
   oCombo:VarPut(uValue,.T.)
   oCombo:Change()
   oDepre:cCodUnd:=uValue

   oDepre:GRIDSETSCOPE()

RETURN .T.

FUNCTION GRIDPRINT()
   LOCAL oRep

   oRep:=REPORTE("DPPRECIO")
  
   oRep:SetRango(1,oDepre:cCodInv,oDepre:cCodInv)
   oRep:SetCriterio(2,LEFT(oDepre:cCodMon,oDepre:nLenMon))
   oRep:SetCriterio(3,LEFT(oDepre:cCodUnd,oDepre:nLenUnd))

RETURN .T.
// EOF





