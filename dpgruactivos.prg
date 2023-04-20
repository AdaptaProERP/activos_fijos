// Programa   : DPGRUACTIVOS
// Fecha/Hora : 08/08/2011 02:11:22
// Propósito  : Incluir/Modificar DPGRUACTIVOS
// Creado Por : DpXbase
// Llamado por: DPGRUACTIVOS.LBX
// Aplicación : Activos Fijos                           
// Tabla      : DPGRUACTIVOS

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION DPGRUACTIVOS(nOption,cCodigo)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG
  LOCAL cTitle,cSql,cFile,cExcluye:=""
  LOCAL nClrText
  LOCAL cTitle:="Grupo de Activos"

  cExcluye:="GAC_CODIGO,;
             GAC_DESCRI,;
             GAC_VUTILA,;
             GAC_VUTILM,;
             GAC_PORVLS,;
             GAC_MEMO"


  DEFAULT cCodigo:="1234"

  DEFAULT nOption:=1

  DEFINE FONT oFont  NAME "Tahoma" SIZE 0, -10 BOLD
  DEFINE FONT oFontB NAME "Tahoma" SIZE 0, -12 BOLD ITALIC
  DEFINE FONT oFontG NAME "Tahoma" SIZE 0, -11

  nClrText:=10485760 // Color del texto


// oDp:lDpXbase:=.T.

  IF nOption=1 // Incluir
    cSql     :=[SELECT * FROM DPGRUACTIVOS WHERE ]+BuildConcat("GAC_CODIGO")+GetWhere("=",cCodigo)+[]
    cTitle   :=" Incluir {oDp:DPGRUACTIVOS}"
  ELSE // Modificar o Consultar
    cSql     :=[SELECT * FROM DPGRUACTIVOS WHERE ]+BuildConcat("GAC_CODIGO")+GetWhere("=",cCodigo)+[]
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" Grupo de Activos                        "
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" {oDp:DPGRUACTIVOS}"
  ENDIF

  oTable   :=OpenTable(cSql,"WHERE"$cSql) // nOption!=1)

  IF nOption=1 .AND. oTable:RecCount()=0 // Genera Cursor Vacio
     oTable:End()
     cSql     :=[SELECT * FROM DPGRUACTIVOS]
     oTable   :=OpenTable(cSql,.F.) // nOption!=1)
  ENDIF

  oTable:cPrimary:="GAC_CODIGO" // Clave de Validación de Registro

  oGRUACTIVOS:=DPEDIT():New(cTitle,"DPGRUACTIVOS.edt","oGRUACTIVOS" , .F. )

  oGRUACTIVOS:nOption  :=nOption
  oGRUACTIVOS:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oGRUACTIVOS
  oGRUACTIVOS:SetScript()        // Asigna Funciones DpXbase como Metodos de oGRUACTIVOS
  oGRUACTIVOS:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oGRUACTIVOS:nClrPane:=oDp:nGris

  oGRUACTIVOS:GAC_CTAACT:=EJECUTAR("DPGETCTAMOD","DPGRUACTIVOS",oGRUACTIVOS:GAC_CODIGO,NIL,"CTAACT")
  oGRUACTIVOS:GAC_CTAACU:=EJECUTAR("DPGETCTAMOD","DPGRUACTIVOS",oGRUACTIVOS:GAC_CODIGO,NIL,"CTAACU")
  oGRUACTIVOS:GAC_CTADEP:=EJECUTAR("DPGETCTAMOD","DPGRUACTIVOS",oGRUACTIVOS:GAC_CODIGO,NIL,"CTADEP")
  oGRUACTIVOS:GAC_CTAREV:=EJECUTAR("DPGETCTAMOD","DPGRUACTIVOS",oGRUACTIVOS:GAC_CODIGO,NIL,"CTAREV")

  IF oGRUACTIVOS:nOption=1 // Incluir en caso de ser Incremental
     // oGRUACTIVOS:RepeatGet(NIL,"GAC_CODIGO") // Repetir Valores
     
     oGRUACTIVOS:GAC_CTAINT:=.T.
     oGRUACTIVOS:GAC_CODIGO:=oGRUACTIVOS:Incremental("GAC_CODIGO",.T.)

     oGRUACTIVOS:GAC_ACTIVO:=.T.

  ENDIF
  //Tablas Relacionadas con los Controles del Formulario

  oGRUACTIVOS:CreateWindow()       // Presenta la Ventana

  // Opciones del Formulario

  
  //
  // Campo : GAC_CODIGO
  // Uso   : C¢digo                                  
  //
  @ 1.0, 1.0 GET oGRUACTIVOS:oGAC_CODIGO  VAR oGRUACTIVOS:GAC_CODIGO  VALID CERO(oGRUACTIVOS:GAC_CODIGO) .AND.; 
                 oGRUACTIVOS:ValUnique(oGRUACTIVOS:GAC_CODIGO);
                   .AND. !VACIO(oGRUACTIVOS:GAC_CODIGO,NIL);
                    WHEN (AccessField("DPGRUACTIVOS","GAC_CODIGO",oGRUACTIVOS:nOption);
                    .AND. oGRUACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 32,10

    oGRUACTIVOS:oGAC_CODIGO:cMsg    :="C¢digo"
    oGRUACTIVOS:oGAC_CODIGO:cToolTip:="C¢digo"

  @ oGRUACTIVOS:oGAC_CODIGO:nTop-08,oGRUACTIVOS:oGAC_CODIGO:nLeft SAY "Código" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : GAC_DESCRI
  // Uso   : Descripción                             
  //
  @ 2.8, 1.0 GET oGRUACTIVOS:oGAC_DESCRI  VAR oGRUACTIVOS:GAC_DESCRI  VALID  !VACIO(oGRUACTIVOS:GAC_DESCRI,NIL);
                    WHEN (AccessField("DPGRUACTIVOS","GAC_DESCRI",oGRUACTIVOS:nOption);
                    .AND. oGRUACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 140,10

    oGRUACTIVOS:oGAC_DESCRI:cMsg    :="Descripción"
    oGRUACTIVOS:oGAC_DESCRI:cToolTip:="Descripción"

  @ oGRUACTIVOS:oGAC_DESCRI:nTop-08,oGRUACTIVOS:oGAC_DESCRI:nLeft SAY "Descripción" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  @ 3,1 CHECKBOX oGRUACTIVOS:oGAC_ACTIVO VAR oGRUACTIVOS:GAC_ACTIVO PROMPT "Registro Activo"
  @ 4,1 CHECKBOX oGRUACTIVOS:oGAC_CTAFIJ VAR oGRUACTIVOS:GAC_CTAFIJ PROMPT "Cuenta Contable Fija en Activos"
  @ 5,1 CHECKBOX oGRUACTIVOS:oGAC_DEPREC VAR oGRUACTIVOS:GAC_DEPREC PROMPT "Depreciable"
  @ 5,1 CHECKBOX oGRUACTIVOS:oGAC_CTAINT VAR oGRUACTIVOS:GAC_CTAINT PROMPT ANSITOOEM("Cuenta Contable Según Integración")

  //
  // Campo : GAC_VUTILA
  // Uso   : Vida Util en Años                       
  //
  @ 6.4, 1.0 GET oGRUACTIVOS:oGAC_VUTILA  VAR oGRUACTIVOS:GAC_VUTILA  PICTURE "99";
                    WHEN (AccessField("DPGRUACTIVOS","GAC_VUTILA",oGRUACTIVOS:nOption);
                         .AND. oGRUACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 8,10;
                    RIGHT SPINNER


    oGRUACTIVOS:oGAC_VUTILA:cMsg    :="Vida Util en Años"
    oGRUACTIVOS:oGAC_VUTILA:cToolTip:="Vida Util en Años"

  @ oGRUACTIVOS:oGAC_VUTILA:nTop-08,oGRUACTIVOS:oGAC_VUTILA:nLeft SAY "Vida Util"+CRLF+"en Años" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : GAC_VUTILM
  // Uso   : Vida Util en Meses                      
  //
  @ 8.2, 1.0 GET oGRUACTIVOS:oGAC_VUTILM  VAR oGRUACTIVOS:GAC_VUTILM  PICTURE "99";
                    WHEN (AccessField("DPGRUACTIVOS","GAC_VUTILM",oGRUACTIVOS:nOption);
                    .AND. oGRUACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 8,10;
                  RIGHT SPINNER


    oGRUACTIVOS:oGAC_VUTILM:cMsg    :="Vida Util en Meses"
    oGRUACTIVOS:oGAC_VUTILM:cToolTip:="Vida Util en Meses"

  @ oGRUACTIVOS:oGAC_VUTILM:nTop-08,oGRUACTIVOS:oGAC_VUTILM:nLeft SAY "Vida Util"+CRLF+"en Meses" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : GAC_PORVLS
  // Uso   : % Valor de Salvamento                   
  //
  @ 10.0, 1.0 GET oGRUACTIVOS:oGAC_PORVLS  VAR oGRUACTIVOS:GAC_PORVLS  PICTURE "99";
                    WHEN (AccessField("DPGRUACTIVOS","GAC_PORVLS",oGRUACTIVOS:nOption);
                    .AND. oGRUACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 12,10;
                  RIGHT SPINNER


    oGRUACTIVOS:oGAC_PORVLS:cMsg    :="% Valor de Salvamento"
    oGRUACTIVOS:oGAC_PORVLS:cToolTip:="% Valor de Salvamento"

  @ oGRUACTIVOS:oGAC_PORVLS:nTop-08,oGRUACTIVOS:oGAC_PORVLS:nLeft SAY "% Valor de"+CRLF+"Salvamento" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  oGRUACTIVOS:GAC_MEMO:=ALLTRIM(oGRUACTIVOS:GAC_MEMO)  //

  // Campo : GAC_MEMO  
  // Uso   : Comentario                              
  //
  @ 4.6, 1.0 GET oGRUACTIVOS:oGAC_MEMO    VAR oGRUACTIVOS:GAC_MEMO  ;
           MEMO SIZE 80,80; 
      ON CHANGE 1=1;
                    WHEN (AccessField("DPGRUACTIVOS","GAC_MEMO",oGRUACTIVOS:nOption);
                    .AND. oGRUACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 40,10

    oGRUACTIVOS:oGAC_MEMO  :cMsg    :="Comentario"
    oGRUACTIVOS:oGAC_MEMO  :cToolTip:="Comentario"

  @ oGRUACTIVOS:oGAC_MEMO  :nTop-08,oGRUACTIVOS:oGAC_MEMO  :nLeft SAY "Comentario" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris



  //
  // Campo : GAC_CTAACT
  // Uso   : Cuenta de Activo                        
  //
  @ 15,14.0 BMPGET oGRUACTIVOS:oGAC_CTAACT  VAR oGRUACTIVOS:GAC_CTAACT ;
             VALID oGRUACTIVOS:VALLBXCTA(oGRUACTIVOS:oGAC_CTAACT,"ATV",oGRUACTIVOS:oCTA_DESCRI);
             NAME "BITMAPS\FIND.BMP"; 
             ACTION (oGRUACTIVOS:LBXCTA(oGRUACTIVOS:oGAC_CTAACT,"ATV"));
                     WHEN (AccessField("DPACTIVOS","GAC_CTAACT",oGRUACTIVOS:nOption);
                    .AND. oGRUACTIVOS:nOption!=0 .AND. !oGRUACTIVOS:GAC_CTAINT);
             FONT oFontG;
             SIZE 80,10

    oGRUACTIVOS:oGAC_CTAACT:cMsg    :="Cuenta Contable de Activo"
    oGRUACTIVOS:oGAC_CTAACT:cToolTip:="Cuenta Contable de Activo"

  @ 16,10 SAY "Cuenta Contable Activo" 

  @ 17,10 SAY oGRUACTIVOS:oCTA_DESCRI;
          PROMPT SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oGRUACTIVOS:GAC_CTAACT)) PIXEL;
          SIZE NIL,12 FONT oFont COLOR 16777215,16711680 


  //
  // Campo : GAC_CTAACU
  // Uso   : Cuenta Contable Depreciación Acumulada Activo           
  //
  @ 14,14.0 BMPGET oGRUACTIVOS:oGAC_CTAACU  VAR oGRUACTIVOS:GAC_CTAACU;
            VALID oGRUACTIVOS:VALLBXCTA(oGRUACTIVOS:oGAC_CTAACU,"DEP",oGRUACTIVOS:oCTAACTDEP);
            NAME "BITMAPS\FIND.BMP"; 
            ACTION oGRUACTIVOS:LBXCTA(oGRUACTIVOS:oGAC_CTAACU,"DEP");
                   WHEN (AccessField("DPGRUACTIVOS","GAC_CTAACU",oGRUACTIVOS:nOption);
                        .AND. oGRUACTIVOS:nOption!=0 .AND. !oGRUACTIVOS:GAC_CTAINT);
             FONT oFontG;
             SIZE 80,10

  oGRUACTIVOS:oGAC_CTAACU:cMsg    :="Depreciación Acumulada Activo"
  oGRUACTIVOS:oGAC_CTAACU:cToolTip:="Depreciación Acumulada Activo"

  @ 16,0 SAY "Depreciación Activo" PIXEL;
         SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris



  @ 14,05 SAY oGRUACTIVOS:oCTAACTDEP;
             PROMPT SQLGET("DPCTA","CTA_DESCRI","CTA_CODMOD"+GetWhere("=",oDp:cCtaMod)+" AND CTA_CODIGO"+GetWhere("=",oGRUACTIVOS:GAC_CTAACU)) PIXEL;
             SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  //
  // Campo : GAC_CTADEP
  // Uso   : Depreciación Gasto
  //
  @ 14.8,14.0 BMPGET oGRUACTIVOS:oGAC_CTADEP  VAR oGRUACTIVOS:GAC_CTADEP ;
             VALID oGRUACTIVOS:VALLBXCTA(oGRUACTIVOS:oGAC_CTADEP,"GAS",oGRUACTIVOS:oCTAGASDEP); 
             NAME "BITMAPS\FIND.BMP"; 
             ACTION oGRUACTIVOS:LBXCTA(oGRUACTIVOS:oGAC_CTADEP,"GAS"); 
                    WHEN (AccessField("DPGRUACTIVOS","GAC_CTADEP",oGRUACTIVOS:nOption);
                    .AND. oGRUACTIVOS:nOption!=0 .AND. !oGRUACTIVOS:GAC_CTAINT);
             FONT oFontG;
             SIZE 80,10

    oGRUACTIVOS:oGAC_CTADEP:cMsg    :="Depreciación Gasto"
    oGRUACTIVOS:oGAC_CTADEP:cToolTip:="Depreciación Gasto"

  @ 12,0 SAY "Depreciación Gasto" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  @ 0,05 SAY oGRUACTIVOS:oCTAGASDEP;
             PROMPT SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oGRUACTIVOS:GAC_CTADEP)) PIXEL;
             SIZE NIL,12 FONT oFont COLOR 16777215,16711680  


  //
  // Campo : GAC_CTAREV
  // Uso   : Depreciación Gasto
  //
  @ 14.8,14.0 BMPGET oGRUACTIVOS:oGAC_CTAREV  VAR oGRUACTIVOS:GAC_CTAREV ;
             VALID oGRUACTIVOS:VALLBXCTA(oGRUACTIVOS:oGAC_CTAREV,"REV",oGRUACTIVOS:oCTAGASREV);
             NAME "BITMAPS\FIND.BMP"; 
             ACTION oGRUACTIVOS:LBXCTA(oGRUACTIVOS:oGAC_CTAREV,"REV"); 
                    WHEN (AccessField("DPGRUACTIVOS","GAC_CTAREV",oGRUACTIVOS:nOption);
                    .AND. oGRUACTIVOS:nOption!=0 .AND. !oGRUACTIVOS:GAC_CTAINT);
             FONT oFontG;
             SIZE 80,10

    oGRUACTIVOS:oGAC_CTAREV:cMsg    :="Revaluación"
    oGRUACTIVOS:oGAC_CTAREV:cToolTip:="Revaluación"

  @ 14,0 SAY "Revaluación " PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  @ 14,0 SAY oGRUACTIVOS:oCTAGASREV;
             PROMPT SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oGRUACTIVOS:GAC_CTAREV)) PIXEL;
             SIZE NIL,12 FONT oFont COLOR 16777215,16711680  


/*

  IF nOption!=2

    @09, 33  SBUTTON oBtn ;
             SIZE 45, 20 FONT oFont;
             FILE "BITMAPS\\XSAVE.BMP" NOBORDER;
             LEFT PROMPT "Grabar";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oGRUACTIVOS:Save())

    oBtn:cToolTip:="Grabar Registro"
    oBtn:cMsg    :=oBtn:cToolTip

    @09, 43 SBUTTON oBtn ;
            SIZE 45, 20 FONT oFont;
            FILE "BITMAPS\\XCANCEL.BMP" NOBORDER;
            LEFT PROMPT "Cancelar";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION (oGRUACTIVOS:Cancel()) CANCEL

    oBtn:lCancel :=.T.
    oBtn:cToolTip:="Cancelar y Cerrar Formulario "
    oBtn:cMsg    :=oBtn:cToolTip

  ELSE


     @09, 43 SBUTTON oBtn ;
             SIZE 42, 23 FONT oFontB;
             FILE "BITMAPS\\XSALIR.BMP" NOBORDER;
             LEFT PROMPT "Salir";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oGRUACTIVOS:Cancel()) CANCEL

             oBtn:lCancel:=.T.
             oBtn:cToolTip:="Cerrar Formulario"
             oBtn:cMsg    :=oBtn:cToolTip

  ENDIF

*/

  oGRUACTIVOS:Activate({||oGRUACTIVOS:ViewDatBar()})

  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oGRUACTIVOS


/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oGRUACTIVOS:oDlg
   LOCAL nLin:=0


   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -10 BOLD

   IF !oGRUACTIVOS:nOption=2

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP";
            ACTION oGRUACTIVOS:Save()

     oBtn:cToolTip:="Guardar"

   ENDIF


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oGRUACTIVOS:Cancel()


  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  

RETURN .T.

/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()

  IF oGRUACTIVOS:nOption=1 // Incluir en caso de ser Incremental
     
     oGRUACTIVOS:GAC_CODIGO:=oGRUACTIVOS:Incremental("GAC_CODIGO",.T.)
  ENDIF

RETURN .T.
/*
// Ejecuta Cancelar
*/
FUNCTION CANCEL()
RETURN .T.

/*
// Ejecución PreGrabar
*/
FUNCTION PRESAVE()
  LOCAL lResp:=.T.

  lResp:=oGRUACTIVOS:ValUnique(oGRUACTIVOS:GAC_CODIGO)

  IF Empty(oGRUACTIVOS:GAC_CTAACT) .AND. oGRUACTIVOS:GAC_CTAFIJ .AND. !oGRUACTIVOS:GAC_CTAINT
     oGRUACTIVOS:oGAC_CTAACT:MsgErr("Requiere Cuenta Contable",oGRUACTIVOS:oGAC_CTAACT:cToolTip)
     RETURN .F.
  ENDIF

  IF Empty(oGRUACTIVOS:GAC_CTAACU) .AND. oGRUACTIVOS:GAC_CTAFIJ  .AND. !oGRUACTIVOS:GAC_CTAINT
     oGRUACTIVOS:oGAC_CTAACU:MsgErr("Requiere Cuenta Contable",oGRUACTIVOS:oGAC_CTAACU:cToolTip)
     RETURN .F.
  ENDIF

  IF Empty(oGRUACTIVOS:GAC_CTADEP) .AND. oGRUACTIVOS:GAC_CTAFIJ  .AND. !oGRUACTIVOS:GAC_CTAINT
     oGRUACTIVOS:oGAC_CTADEP:MsgErr("Requiere Cuenta Contable",oGRUACTIVOS:oGAC_CTADEP:cToolTip)
     RETURN .F.
  ENDIF

  IF Empty(oGRUACTIVOS:GAC_CTAREV) .AND. oGRUACTIVOS:GAC_CTAFIJ .AND. !oGRUACTIVOS:GAC_CTAINT
     oGRUACTIVOS:oGAC_CTAREV:MsgErr("Requiere Cuenta Contable",oGRUACTIVOS:oGAC_CTAREV:cToolTip)
     RETURN .F.
  ENDIF

  IF !lResp
    MsgAlert("Registro "+CTOO(oGRUACTIVOS:GAC_CODIGO),"Ya Existe")
  ENDIF

RETURN lResp

/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()

  EJECUTAR("SETCTAINTMOD","DPGRUACTIVOS",oGRUACTIVOS:GAC_CODIGO,NIL,"CTAACT",oGRUACTIVOS:GAC_CTAACT,.T.)
  EJECUTAR("SETCTAINTMOD","DPGRUACTIVOS",oGRUACTIVOS:GAC_CODIGO,NIL,"CTAACU",oGRUACTIVOS:GAC_CTAACU,.T.)
  EJECUTAR("SETCTAINTMOD","DPGRUACTIVOS",oGRUACTIVOS:GAC_CODIGO,NIL,"CTADEP",oGRUACTIVOS:GAC_CTADEP,.T.)
  EJECUTAR("SETCTAINTMOD","DPGRUACTIVOS",oGRUACTIVOS:GAC_CODIGO,NIL,"CTAREV",oGRUACTIVOS:GAC_CTAREV,.T.)


RETURN .T.

FUNCTION VALLBXCTA(oGet,cPropied,oSay)
  LOCAL cWhere:=EJECUTAR("DPCTAPROPWHERE",cPropied)
  LOCAL cTiTLE:=EJECUTAR("DPCTAPROPGET",cPropied)
  LOCAL cCodigo:=ALLTRIM(EVAL(oGet:bSetGet))
  LOCAL cCtaPro:=ALLTRIM(SQLGET("DPCTA","CTA_PROPIE,CTA_CODIGO","CTA_CODIGO"+GetWhere("=",cCodigo)))
  LOCAL cCtaCod:=DPSQLROW(2)

  IF COUNT("DPCTA",cWhere)=0 
     oGet:MsgErr("No hay Cuentas Contables definidas para "+CRLF+"["+cTitle+"]",oGet:cToolTip)
     RETURN .F.
  ENDIF
  
  IF Empty(cCtaCod)
     oGet:MsgErr("Cuenta "+cCodigo+" no Existe")
     EVAL(oGet:bAction)
     RETURN .F.
  ENDIF

  IF !(cCtaPro==cTitle)
     oGet:MsgErr("Cuenta ["+cCodigo+"] Deber poseer Propiedad"+CRLF+"["+cTitle+"]",oGet:cToolTip)
     RETURN .F.
  ENDIF

  IF !EJECUTAR("ISCTADET",cCodigo,.F.) 
    oGet:MsgErr("Cuenta "+cCodigo+" no Acepta Asientos")
    RETURN .F.
  ENDIF

  oSay:Refresh(.T.)

RETURN .T.

/*
// Ejecuta LBX de la Cuenta
*/
FUNCTION LBXCTA(oGet,cPropied)
  LOCAL cWhere:=EJECUTAR("DPCTAPROPWHERE",cPropied)+" AND CTA_CTADET=1"
  LOCAL cTitle:=oDp:DPCTA+" para ["+EJECUTAR("DPCTAPROPGET",cPropied)+"]"

  IF COUNT("DPCTA",cWhere)=0 
     oGet:MsgErr("No hay Cuentas Contables definidas para"+CRLF+"["+cTitle+"]"+CRLF+"Definir Propiedades de las Cuentas",oGet:cToolTip)
//   RETURN .F.
  ENDIF

  oDpLbx:=DpLbx("DPCTA",cTitle,cWhere,NIL,NIL,NIL,NIL,NIL,NIL,oGet)
  oDpLbx:GetValue("CTA_CODIGO",oGet)

RETURN .T.

/*
<LISTA:GAC_CODIGO:Y:GET:Y:N:N:Código,GAC_DESCRI:N:GET:N:N:N:Descripción,GAC_MEMO:N:MGET:N:N:Y:Comentario,GAC_VUTILA:N:GET:N:N:Y:Vida Util en Años
,GAC_VUTILM:N:GET:N:N:Y:Vida Util en Meses,GAC_PORVLS:N:GET:N:N:Y:% Valor de Salvamento>
*/
