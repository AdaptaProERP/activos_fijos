// Programa   : DPACTIVOS
// Fecha/Hora : 30/10/2005 08:11:19
// Propósito  : Documento DPACTIVOS
// Creado Por : DpXbase
// Llamado por: DPACTIVOS.LBX
// Aplicación : Activos Fijos                           
// Tabla      : DPACTIVOS

#INCLUDE "DPXBASE.CH"

FUNCTION DPACTIVOS(nOption,cCodigo)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG,oGrp,bInit
  LOCAL cSql,cFile,cExcluye:=""
  LOCAL nClrText
  LOCAL oBrw,cSqlCuerpo,oCuerpo,oCol,oCursorC
  LOCAL cTitle:="Activos Fijos",;
        aItems1:=GETOPTIONS("DPACTIVOS","ATV_DEPRE"),;
        aItems2:=GETOPTIONS("DPACTIVOS","ATV_METODO")

  DEFAULT cCodigo:="",nOption:=0

/*
  IF !SQLGET("DPEJERCICIOS","EJE_AXIINI","EJE_CODSUC"+GetWhere("=",oDp:cSucursal)+" AND EJE_AXIINI=1")
     MsgMemo("Es necesario Definir el Ejercicio Inicial para el Ajuste por Inflación ","Necesario para el AXI Inicial")
     DPLBX("DPEJERCICIOS.LBX")
     RETURN .F.
  ENDIF
*/
/*
  IF !EJECUTAR("DPACTIVOSPROPIE")
     MensajeErr("Sera Ejecutado el Formulario para indicar las Propiedades de las Cuentas")
     EJECUTAR("BRDPCTAPROP")
     RETURN .T.
  ENDIF
*/

  oDp:aFchEjer:=NIL // Release Ejercicios

  DEFINE FONT oFont  NAME "TAHOMA" SIZE 0, -12 BOLD
  DEFINE FONT oFontB NAME "TAHOMA" SIZE 0, -12 BOLD 
  DEFINE FONT oFontG NAME "TAHOMA" SIZE 0, -12

  nClrText:=10485760 // Color del texto
  cTitle  :=" {oDp:DPACTIVOS}"
  cSql    :=[SELECT * FROM DPACTIVOS]
  oTable  :=OpenTable(cSql,.F.) // nOption!=1)

  oTable:cPrimary:="ATV_CODIGO" // Clave de Validación de Registro

  oACTIVOS:=DPEDIT():New(cTitle,"DPACTIVOS.edt","oACTIVOS" , .F. )

  oACTIVOS:lDlg     :=.T.           // Formulario Sin Dialog
  oACTIVOS:nMode    :=1             // Formulario Tipo de Documento
  oACTIVOS:nOption  :=nOption
  oACTIVOS:cScope   :="ATV_CODSUC"+; 
                      GetWhere("=",oDp:cSucursal)+;
                      IIF(!Empty(cCodigo), " AND ATV_CODIGO"+GetWhere("=",cCodigo),"")

  oACTIVOS:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oACTIVOS
  oACTIVOS:SetScript()              // Asigna Funciones DpXbase como Metodos de oACTIVOS
  oACTIVOS:SetDefault()             // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oACTIVOS:SetMemo("ATV_NUMMEM")    // Campo para el Valor Memo
  oACTIVOS:SetBmp("ATV_FILBMP" )    // Asignación de Imagen

  IF DPVERSION()>4
    oACTIVOS:SetAdjuntos("ATV_FILMAI") // Vinculo con DPFILEEMP
  ENDIF

  oActivos:OpcButtons("Cuentas Contables"  ,"CONTABILIDAD.BMP",[EJECUTAR("DPACTIVOS_CTA" ,oActivos:ATV_CODIGO)])

  oACTIVOS:cView     :="DPACTIVOCON"   // Programa Consulta
  oACTIVOS:cList     :="DPACTIVOS.BRW"
  oACTIVOS:nContab   :=0
  oACTIVOS:nDesinc   :=0
  oACTIVOS:lDeprecia :=.F.
  oACTIVOS:lCompras  :=.F.
  oACTIVOS:nPorcen   :=0
  oACTIVOS:nMeses    :=0
  oACTIVOS:lCtaFijGru:=.F. //  Cuenta Fija segun Grupo, no se pueden cambiar las Cuentas

  oACTIVOS:lDatosIni:=.F. // Requiere Valores Iniciales, el campo de ATV_FCHINC sera vacio si este valor es falso

  // Campos Virtuales
  oACTIVOS:ATV_MTOFIS:=0
  oACTIVOS:ATV_MTOFIN:=0
  oACTIVOS:dFechaMax :=CTOD("")

  oACTIVOS:cEstado:="Activo"

  oACTIVOS:OpcButtons("Menú de Opciones","MENU.BMP" ,;
                      "EJECUTAR('DPACTIVOSMNU',oACTIVOS:ATV_CODSUC ,;
                       oACTIVOS:ATV_CODIGO)","oACTIVOS:nOption=0")

  oACTIVOS:ATV_CTAACT:=EJECUTAR("DPGETCTAMOD","DPACTIVOS",oACTIVOS:ATV_CODIGO,NIL,"CTAACT")
  oACTIVOS:ATV_CTAACU:=EJECUTAR("DPGETCTAMOD","DPACTIVOS",oACTIVOS:ATV_CODIGO,NIL,"CTAACU")
  oACTIVOS:ATV_CTADEP:=EJECUTAR("DPGETCTAMOD","DPACTIVOS",oACTIVOS:ATV_CODIGO,NIL,"CTADEP")
  oACTIVOS:ATV_CTAREV:=EJECUTAR("DPGETCTAMOD","DPACTIVOS",oACTIVOS:ATV_CODIGO,NIL,"CTAREV")


  oACTIVOS:CreateWindow()        // Presenta la Ventana

  oACTIVOS:ViewTable("DPGRUACTIVOS","GAC_DESCRI","GAC_CODIGO","ATV_CODGRU")
  oACTIVOS:ViewTable("DPUBIACTIVOS","UAC_DESCRI","UAC_CODIGO","ATV_CODUBI")
  oACTIVOS:ViewTable("DPCTA"       ,"CTA_DESCRI","CTA_CODIGO","ATV_CTAACT")
  oACTIVOS:ViewTable("DPDPTO"      ,"DEP_DESCRI","DEP_CODIGO","ATV_CODDEP")

// oACTIVOS:ViewTable("DPCTA","CTA_DESCRI","CTA_CODIGO","ATV_CTAACU")
// oACTIVOS:ViewTable("DPCTA","CTA_DESCRI","CTA_CODIGO","ATV_CTADEP")
 
  //
  // Campo : ATV_CODIGO
  // Uso   : Código                                  
  //
  @ 3.0, 1.0 GET oACTIVOS:oATV_CODIGO  VAR oACTIVOS:ATV_CODIGO  VALID oACTIVOS:ValUnique(oACTIVOS:ATV_CODIGO);
                   .AND. !VACIO(oACTIVOS:ATV_CODIGO,NIL);
                    WHEN (AccessField("DPACTIVOS","ATV_CODIGO",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0) .AND. !(oDp:lACTAut .AND. oDp:nACTLen>1);
                    FONT oFontG;
                    SIZE 60,10

    oACTIVOS:oATV_CODIGO:cMsg    :="Código"
    oACTIVOS:oATV_CODIGO:cToolTip:="Código"

  @ 0,0 SAY "Código" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : ATV_DESCRI
  // Uso   : Descripción                             
  //
  @ 4.8, 1.0 GET oACTIVOS:oATV_DESCRI  VAR oACTIVOS:ATV_DESCRI ;
                    WHEN (AccessField("DPACTIVOS","ATV_DESCRI",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 200,10

    oACTIVOS:oATV_DESCRI:cMsg    :="Descripción"
    oACTIVOS:oATV_DESCRI:cToolTip:="Descripción"

  @ 0,0 SAY "Descripción" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : ATV_DEPRE 
  // Uso   : Depreciable S/N                         
  //
  @ 6.1, 1.0 COMBOBOX oACTIVOS:oATV_DEPRE  VAR oACTIVOS:ATV_DEPRE  ITEMS aItems1;
                      WHEN (AccessField("DPACTIVOS","ATV_DEPRE",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0 .AND. !oACTIVOS:lDeprecia);
                      FONT oFontG;


  ComboIni(oACTIVOS:oATV_DEPRE )

  oACTIVOS:oATV_DEPRE :cMsg    :="Depreciable S/N"
  oACTIVOS:oATV_DEPRE :cToolTip:="Depreciable S/N"

  @ 0,0 SAY "Tipo de Activo" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  @ 2,1 SAY "Estado:" 
  @ 2,1 SAY oACTIVOS:oEstado PROMPT " "+oACTIVOS:cEstado+" "

  @ 2,10 SAY "Método/Depreciación" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris 

  //
  // Campo : ATV_METODO
  // Uso   : Método de Depreciación                  
  //
  @ 2, 10 COMBOBOX oACTIVOS:oATV_METODO VAR oACTIVOS:ATV_METODO ITEMS aItems2;
                      WHEN (AccessField("DPACTIVOS","ATV_METODO",oACTIVOS:nOption);
                           .AND. oACTIVOS:nOption!=0 .AND. !oACTIVOS:lDeprecia);
                      FONT oFontG;

  ComboIni(oACTIVOS:oATV_METODO)

  oACTIVOS:oATV_METODO:cMsg    :="Método de Depreciación"
  oACTIVOS:oATV_METODO:cToolTip:="Método de Depreciación"

  @ 7.9, 1.0 FOLDER oACTIVOS:oFolder ITEMS "Básicos","Datos Adicionales";
                      FONT oFontG

  SETFOLDER( 1)

  //  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT "Vida Util" OF oACTIVOS:oFolder:aDialogs[1]
  //
  // Campo : ATV_CODGRU
  // Uso   : Grupo                                   
  //
  @ 1.1, 0.0 BMPGET oACTIVOS:oATV_CODGRU  VAR oACTIVOS:ATV_CODGRU ;
                    VALID oACTIVOS:oDPGRUACTIVOS:SeekTable("GAC_CODIGO",oACTIVOS:oATV_CODGRU,NIL,oACTIVOS:oGAC_DESCRI);
                          .AND. oACTIVOS:VALCODGRU();
                    NAME "BITMAPS\FIND.BMP"; 
                          ACTION (oDpLbx:=DpLbx("DPGRUACTIVOS",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,oACTIVOS:oATV_CODGRU),;
                                  oDpLbx:GetValue("GAC_CODIGO",oACTIVOS:oATV_CODGRU)); 
                    WHEN (AccessField("DPACTIVOS","ATV_CODGRU",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 12,10

    oACTIVOS:oATV_CODGRU:cMsg    :="Grupo"
    oACTIVOS:oATV_CODGRU:cToolTip:="Grupo"

  @ 0,0 SAY GETFROMVAR("{oDp:xDPGRUACTIVOS}") PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  @ 0,0 SAY oACTIVOS:oGAC_DESCRI;
        PROMPT oACTIVOS:oDPGRUACTIVOS:GAC_DESCRI PIXEL;
        SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  //
  // Campo : ATV_CODUBI
  // Uso   : Ubicación                               
  //
  @ 2.9, 0.0 BMPGET oACTIVOS:oATV_CODUBI  VAR oACTIVOS:ATV_CODUBI ;
             VALID (oACTIVOS:oDPUBIACTIVOS:SeekTable("UAC_CODIGO",oACTIVOS:oATV_CODUBI,NIL,oACTIVOS:oUAC_DESCRI) .AND. (DPFOCUS(oACTIVOS:oATV_CODDEP),.T.));
                    NAME "BITMAPS\FIND.BMP"; 
                    ACTION (oDpLbx:=DpLbx("DPUBIACTIVOS",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,oACTIVOS:oATV_CODUBI),;
                             oDpLbx:GetValue("UAC_CODIGO",oACTIVOS:oATV_CODUBI)); 
                    WHEN (AccessField("DPACTIVOS","ATV_CODUBI",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 12,10

    oACTIVOS:oATV_CODUBI:cMsg    :="Ubicación Física"
    oACTIVOS:oATV_CODUBI:cToolTip:="Ubicación Física"

  oACTIVOS:oATV_CODUBI:oJump:=oACTIVOS:oATV_CODDEP

  @ 0,0 SAY GETFROMVAR("{oDp:xDPUBIACTIVOS}")

  @ 0,0  SAY oACTIVOS:oUAC_DESCRI;
         PROMPT oACTIVOS:oDPUBIACTIVOS:UAC_DESCRI PIXEL;
         SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  //
  // Campo : ATV_FCHADQ
  // Uso   : Fecha de Adquisición                    
  //
  @ 4.7, 0.0 BMPGET oACTIVOS:oATV_FCHADQ  VAR oACTIVOS:ATV_FCHADQ;
             PICTURE "99/99/9999";
             VALID oACTIVOS:ATVFCHADQ();
             NAME "BITMAPS\Calendar.bmp";
             ACTION LbxDate(oACTIVOS:oATV_FCHADQ,oACTIVOS:ATV_FCHADQ);
                    WHEN (AccessField("DPACTIVOS","ATV_FCHADQ",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0) .AND. Empty(oACTIVOS:ATV_TIPDOC);
                    FONT oFontG;
                    SIZE 32,10

    oACTIVOS:oATV_FCHADQ:cMsg    :="Fecha de Adquisición"
    oACTIVOS:oATV_FCHADQ:cToolTip:="Fecha de Adquisición"

  @ 0,0 SAY "Fecha de "+CRLF+"Adquisición" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : ATV_COSADQ
  // Uso   : Costo de Adquisición                    
  //
  @ 6.5, 0.0 GET oACTIVOS:oATV_COSADQ  VAR oACTIVOS:ATV_COSADQ;
                 PICTURE "9,999,999,999,999.99";
                 VALID oACTIVOS:ATVCOSADQ();
                 WHEN (AccessField("DPACTIVOS","ATV_COSADQ",oACTIVOS:nOption);
                      .AND. oACTIVOS:nOption!=0) .AND. Empty(oACTIVOS:ATV_TIPDOC);
                 RIGHT


    oACTIVOS:oATV_COSADQ:cMsg    :="Costo de Adquisición"
    oACTIVOS:oATV_COSADQ:cToolTip:="Costo de Adquisición"

  @ 0,0 SAY "Costo de"+CRLF+"Adquisición" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris RIGHT


  //
  // Campo : ATV_COSADQ
  // Uso   : Costo de Adquisición                    
  //
  @ 6.5, 0.0 GET oACTIVOS:oATV_PORVAL  VAR oACTIVOS:ATV_PORVAL;
                 PICTURE "99" SPINNER;
                 VALID oACTIVOS:ATVPORVAL();
                 WHEN (AccessField("DPACTIVOS","ATV_PORVAL",oACTIVOS:nOption);
                      .AND. oACTIVOS:nOption!=0) .AND. Empty(oACTIVOS:ATV_TIPDOC);
                 RIGHT


    oACTIVOS:oATV_COSADQ:cMsg    :="Costo de Adquisición"
    oACTIVOS:oATV_COSADQ:cToolTip:="Costo de Adquisición"

  @ 0,0 SAY "% Valor"+CRLF+"Salvamento" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris RIGHT


  //
  // Campo : ATV_VALSAL
  // Uso   : Valor de Salvamento                     
  //
  @ 8.3, 0.0 GET oACTIVOS:oATV_VALSAL  VAR oACTIVOS:ATV_VALSAL;
                 PICTURE "9,999,999,999,999.99";
                 VALID oACTIVOS:ATVVALSAL();
                 WHEN (AccessField("DPACTIVOS","ATV_VALSAL",oACTIVOS:nOption);
                      .AND. oACTIVOS:nOption!=0.AND. !oACTIVOS:lDeprecia) .AND. oACTIVOS:ATV_PORVAL=0 ;
                 FONT oFontG;
                 SIZE 64,10;
                 RIGHT


    oACTIVOS:oATV_VALSAL:cMsg    :="Valor de Salvamento"
    oACTIVOS:oATV_VALSAL:cToolTip:="Valor de Salvamento"

  @ 0,0 SAY "Valor de"+CRLF+"Salvamento" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris RIGHT


  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT "Vida Util" OF oACTIVOS:oFolder:aDialogs[1]


  //
  // Campo : ATV_VIDA_A
  // Uso   : Vida Util en Años                       
  //
  @ 10.1, 0.0 GET oACTIVOS:oATV_VIDA_A  VAR oACTIVOS:ATV_VIDA_A  PICTURE "99";
                   VALID oACTIVOS:ATVVIDA_M();
                    WHEN (AccessField("DPACTIVOS","ATV_VIDA_A",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0 .AND. !oACTIVOS:lDeprecia);
                    FONT oFontG;
                    SIZE 8,10;
                  RIGHT

    oACTIVOS:oATV_VIDA_A:cMsg    :="Vida Util en Años"
    oACTIVOS:oATV_VIDA_A:cToolTip:="Vida Util en Años"

  @ 0,0 SAY "Años:" PIXEL;
        SIZE NIL,7 RIGHT

  //
  // Campo : ATV_VIDA_M
  // Uso   : Más Vida Util en Meses                  
  //
  @ 3.0,14.0 GET oACTIVOS:oATV_VIDA_M  VAR oACTIVOS:ATV_VIDA_M;
                 PICTURE "999";
                 VALID oACTIVOS:ATVVIDA_M();
                 WHEN (AccessField("DPACTIVOS","ATV_VIDA_M",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0 .AND. !oACTIVOS:lDeprecia);
                 FONT oFontG;
                 SIZE 12,10;
                 RIGHT


    oACTIVOS:oATV_VIDA_M:cMsg    :="Más Vida Util en Meses"
    oACTIVOS:oATV_VIDA_M:cToolTip:="Más Vida Util en Meses"

  @ 0,0 SAY oACTIVOS:oSayMeses PROMPT "Meses:" PIXEL;
        SIZE NIL,7 RIGHT

  @ 10,2 SAY oACTIVOS:oFechaMax PROMPT DTOC(oACTIVOS:dFechaMax)
  @ 12,2 SAY "Fecha"+CRLF+"Culmina"

  @ 10,2 SAY oACTIVOS:oCantMeses PROMPT LSTR(oACTIVOS:nMeses,4,0) RIGHT
  @ 12,2 SAY "Cant."+CRLF+"Meses"

  @ 14,06 CHECKBOX oACTIVOS:lDatosIni PROMPT "Datos Iniciales";
          WHEN (AccessField("DPACTIVOS","ATV_VIDA_M",oACTIVOS:nOption);
               .AND. oACTIVOS:nOption!=0 .AND. !oACTIVOS:lDeprecia);
          ON CHANGE oACTIVOS:AVTDATOSINI()

  @ 13,1 GROUP oGrp TO 16, 21.5 PROMPT "Datos Iniciales" OF oACTIVOS:oFolder:aDialogs[1]

  @ 14,1 GROUP oGrp TO 16, 21.5 PROMPT "Depreciación" OF oACTIVOS:oFolder:aDialogs[1]

  @ 16,1 GROUP oGrp TO 17, 1 PROMPT "Cuentas Contables" OF oACTIVOS:oFolder:aDialogs[1]

  @ 16,1 GROUP oGrp TO 17, 1 PROMPT "Garantía" OF oACTIVOS:oFolder:aDialogs[1]


  @ 14,10 SAY "Fecha"+CRLF+"Inicio" PIXEL;
          SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  //
  // Campo : ATV_FCHINC
  // Uso   : Fecha de Inclusión en el Sistema o Inicio de la Depreciacion por parte del Sistema
  //         Entre la fecha de la primera depreciacion y la fecha de inclusion, se genera el tiempo que ya se deprecio anteriormente                      
  //         La fecha de inclusión, es utilizada para calcular cuantos meses han transcurrido.


  @ 13, 0.0 BMPGET oACTIVOS:oATV_FCHINC  VAR oACTIVOS:ATV_FCHINC;
             PICTURE "99/99/9999";
             NAME "BITMAPS\Calendar.bmp";
             VALID oACTIVOS:ATVFCHINC();
             ACTION LbxDate(oACTIVOS:oATV_FCHINC,oACTIVOS:ATV_FCHINC);
                    WHEN (AccessField("DPACTIVOS","ATV_FCHINC",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0 .AND. !oACTIVOS:lDeprecia .AND. oACTIVOS:lDatosIni);
                    FONT oFontG;
                    SIZE 32,10

    oACTIVOS:oATV_FCHINC:cMsg    :="Fecha de Inclusión"
    oACTIVOS:oATV_FCHINC:cToolTip:="Fecha de Inclusión"


   @ 14,1 BUTTON oACTIVOS:oATVFCHINCMAS PROMPT ">";
          ACTION (EJECUTAR("FCHSPINNERMES",oACTIVOS:oATV_FCHINC,+1),oACTIVOS:ATVFCHINC());
          WHEN EVAL(oACTIVOS:oATV_FCHINC:bWhen)

   @ 14,2 BUTTON oACTIVOS:oATVFCHINCMAS PROMPT "<";
          ACTION (EJECUTAR("FCHSPINNERMES",oACTIVOS:oATV_FCHINC,-1),oACTIVOS:ATVFCHINC());
          WHEN EVAL(oACTIVOS:oATV_FCHINC:bWhen)

  //
  // Campo : ATV_MESDEP
  // Uso   : Meses Depreciados                       
  //
  @ 15, 0.0 GET oACTIVOS:oATV_MESDEP  VAR oACTIVOS:ATV_MESDEP;
                 PICTURE "9999";
                 VALID oACTIVOS:ATVMESDEP();
                 WHEN (AccessField("DPACTIVOS","ATV_MESDEP",oACTIVOS:nOption);
                       .AND. oACTIVOS:nOption!=0) .AND. (oACTIVOS:ATV_FCHDEP<>oACTIVOS:ATV_FCHINC);
                       .AND. !oACTIVOS:lDeprecia .AND. oACTIVOS:lDatosIni;
                 FONT oFontG;
                 SIZE 16,10;
                 RIGHT SPINNER


  oACTIVOS:oATV_MESDEP:cMsg    :="Meses Depreciados"
  oACTIVOS:oATV_MESDEP:cToolTip:="Meses Depreciados"


  @ 16,0 SAY "Meses"+CRLF+"Depreciados" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  //
  // Campo : ATV_DEPACU
  // Uso   : Depreciación Acumulada                  
  //
  @ 17, 0.0 GET oACTIVOS:oATV_DEPACU  VAR oACTIVOS:ATV_DEPACU ;
                 RIGHT;
                 VALID oACTIVOS:ATVDEPACU(); 
                 PICTURE "9,999,999,999,999.99";
                 WHEN (AccessField("DPACTIVOS","ATV_DEPACU",oACTIVOS:nOption);
                      .AND. oACTIVOS:nOption!=0) .AND. oACTIVOS:ATV_MESDEP>0;
                      .AND. !oACTIVOS:lDeprecia .AND. oACTIVOS:lDatosIni;
                 FONT oFontG

  oACTIVOS:oATV_DEPACU:cMsg    :="Depreciación Acumulada"
  oACTIVOS:oATV_DEPACU:cToolTip:="Depreciación Acumulada"
  oACTIVOS:oATV_MESDEP:oJump   :=oACTIVOS:oATV_DEPACU 

  @ 18,0 SAY "Depreciación"+CRLF+"Acumulada" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris RIGHT

  //
  // Campo : ATV_MTOFIS
  // Uso   : Acumulado Rexpresion Fiscal                  
  //
  @ 19, 0.0 GET oACTIVOS:oATV_MTOFIS  VAR oACTIVOS:ATV_MTOFIS ;
                 RIGHT;
                 VALID oACTIVOS:ATVMTOFIS(); 
                 PICTURE "9,999,999,999,999.99";
                 WHEN (AccessField("DPACTIVOS","ATV_MTOFIS",oACTIVOS:nOption);
                      .AND. oACTIVOS:nOption!=0) .AND. oACTIVOS:ATV_MESDEP>0;
                      .AND. !oACTIVOS:lDeprecia .AND. oACTIVOS:lDatosIni;
                 FONT oFontG

    oACTIVOS:oATV_MTOFIS:cMsg    :="Rexpresion Fiscal Acumulada"
    oACTIVOS:oATV_MTOFIS:cToolTip:="Rexpresión Fiscal Acumulada"

  @ 19,0 SAY "Rexpresion"+CRLF+"Fiscal" PIXEL;
         SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris RIGHT


  //
  // Campo : ATV_MTOFIN
  // Uso   : Acumulado Rexpresion Financiera                  
  //
  @ 20, 0.0 GET oACTIVOS:oATV_MTOFIN  VAR oACTIVOS:ATV_MTOFIN ;
                 RIGHT;
                 VALID oACTIVOS:ATVMTOFIS(); 
                 PICTURE "9,999,999,999,999.99";
                 WHEN (AccessField("DPACTIVOS","ATV_MTOFIN",oACTIVOS:nOption);
                      .AND. oACTIVOS:nOption!=0) .AND. oACTIVOS:ATV_MESDEP>0;
                      .AND. !oACTIVOS:lDeprecia .AND. oACTIVOS:lDatosIni;
                 FONT oFontG

    oACTIVOS:oATV_MTOFIN:cMsg    :="Rexpresion Fiscal Acumulada"
    oACTIVOS:oATV_MTOFIN:cToolTip:="Rexpresión Fiscal Acumulada"

  @ 21,0 SAY "Rexpresion"+CRLF+"Finaciera" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris RIGHT



  @12,0 SAY "Primera"+CRLF+"Depreciación" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  //
  // Campo : ATV_FCHDEP
  // Uso   : Fecha de Depreciación   
  // Fecha de la primera Depreciacion.                
  //
  @ 22, 0.0 BMPGET oACTIVOS:oATV_FCHDEP  VAR oACTIVOS:ATV_FCHDEP;
             PICTURE "99/99/9999";
             VALID oACTIVOS:ATVFCHDEP();
             NAME "BITMAPS\Calendar.bmp";
             ACTION LbxDate(oACTIVOS:oATV_FCHDEP,oACTIVOS:ATV_FCHDEP);
                    WHEN (AccessField("DPACTIVOS","ATV_FCHDEP",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0 .AND. !oACTIVOS:lDeprecia);
                    FONT oFontG;
                    SIZE 32,10

    oACTIVOS:oATV_FCHDEP:cMsg    :="Fecha de Inicio de la Depreciación"
    oACTIVOS:oATV_FCHDEP:cToolTip:="Fecha de Inicio de la Depreciación"


  //
  // Campo : ATV_DEPMEN
  // Uso   : Depreciación Mensual Fija               
  //
  @ 13,14.0 GET oACTIVOS:oATV_DEPMEN  VAR oACTIVOS:ATV_DEPMEN  PICTURE "9,999,999,999,999.99";
                    WHEN (AccessField("DPACTIVOS","ATV_DEPMEN",oACTIVOS:nOption);
                         .AND. oACTIVOS:nOption!=0 .AND. LEFT(oACTIVOS:ATV_METODO,1)="L");
                         .AND. (oACTIVOS:ATV_VIDA_A+oACTIVOS:ATV_VIDA_M)>0;
                         .AND. !oACTIVOS:lDeprecia;
                    FONT oFontG;
                    SIZE 64,10;
                    RIGHT

   oACTIVOS:oATV_DEPMEN:cMsg    :="Depreciación Mensual Fija"
   oACTIVOS:oATV_DEPMEN:cToolTip:="Depreciación Mensual Fija"

   @ 16,0 SAY "Depreciación"+CRLF+"Mensual Fija" PIXEL;
         SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris RIGHT

  //
  // Campo : ATV_UNIPRO
  // Uso   : Cantidad a Producir                     
  //
  @ 16, 0.0 GET oACTIVOS:oATV_UNIPRO  VAR oACTIVOS:ATV_UNIPRO  PICTURE "9999999.99";
                    WHEN (AccessField("DPACTIVOS","ATV_UNIPRO",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0) .AND. LEFT(oACTIVOS:ATV_METODO,1)="U" ;
                    .AND. !oACTIVOS:lDeprecia;
                    FONT oFontG;
                    SIZE 40,10;
                    RIGHT

  oACTIVOS:oATV_UNIPRO:cMsg    :="Cantidad a Producir"
  oACTIVOS:oATV_UNIPRO:cToolTip:="Cantidad a Producir"

  @ 12,0 SAY "Capacidad"+CRLF+"Productiva" PIXEL;
        RIGHT;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

//// GARANTIAS

  @ 16, 10 GET oACTIVOS:oATV_ANOGAR VAR oACTIVOS:ATV_ANOGAR SPINNER PICTURE "999" RIGHT;
               VALID oACTIVOS:ATVCALFCHGAR();
               WHEN (AccessField("DPACTIVOS","ATV_ANOGAR",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0)

  @ 17, 10 GET oACTIVOS:oATV_MESGAR VAR oACTIVOS:ATV_MESGAR SPINNER PICTURE "99" RIGHT;
               VALID oACTIVOS:ATVCALFCHGAR();
               WHEN (AccessField("DPACTIVOS","ATV_MESGAR",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0)

  @ 18, 10 BMPGET oACTIVOS:oATV_FCHGAR VAR oACTIVOS:ATV_FCHGAR;
           PICTURE "99/99/9999";
           VALID oACTIVOS:ATVFCHGAR();
           NAME "BITMAPS\Calendar.bmp";
           ACTION LbxDate(oACTIVOS:oATV_FCHGAR,oACTIVOS:ATV_FCHGAR);
                  WHEN (AccessField("DPACTIVOS","ATV_FCHGAR",oACTIVOS:nOption);
                        .AND. oACTIVOS:nOption!=0 .AND. (oACTIVOS:ATV_ANOGAR+oACTIVOS:ATV_MESGAR)=0);
           FONT oFontG;
           SIZE 32,10

  oACTIVOS:oATV_FCHADQ:cMsg    :="Fecha de Adquisición"
  oACTIVOS:oATV_FCHADQ:cToolTip:="Fecha de Adquisición"


  @ 5,1 CHECKBOX oACTIVOS:oATV_CTAINT VAR oACTIVOS:ATV_CTAINT PROMPT ANSITOOEM("Cuenta Contable Según Integración")

  //
  // Campo : ATV_CTAACT
  // Uso   : Cuenta de Activo                        
  //
  @ 15,14.0 BMPGET oACTIVOS:oATV_CTAACT  VAR oACTIVOS:ATV_CTAACT ;
             VALID oACTIVOS:VALLBXCTA(oACTIVOS:oATV_CTAACT,"ATV",oACTIVOS:oCTAACTACT);
             NAME "BITMAPS\FIND.BMP"; 
             ACTION (oACTIVOS:LBXCTA(oACTIVOS:oATV_CTAACT,"ATV"));
                     WHEN ((AccessField("DPACTIVOS","ATV_CTAACT",oACTIVOS:nOption);
                            .AND. oACTIVOS:nOption!=0);
                            .AND. Empty(oACTIVOS:ATV_TIPDOC) .AND. !oACTIVOS:lCtaFijGru .AND. !oACTIVOS:ATV_CTAINT);
             FONT oFontG;
             SIZE 80,10

    oACTIVOS:oATV_CTAACT:cMsg    :="Cuenta Contable de Activo"
    oACTIVOS:oATV_CTAACT:cToolTip:="Cuenta Contable de Activo"

  @ 16,10 SAY "Cuenta Activo" 

  @ 17,10 SAY oACTIVOS:oCTAACTACT;
          PROMPT SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oACTIVOS:ATV_CTAACT)) PIXEL;
          SIZE NIL,12 FONT oFont COLOR 16777215,16711680 

/*
// Datos Iniciales
*/

  //
  // Campo : ATV_CTAACU
  // Uso   : Cuenta Contable Depreciación Acumulada Activo           
  //
  @ 14,14.0 BMPGET oACTIVOS:oATV_CTAACU  VAR oACTIVOS:ATV_CTAACU;
            VALID oACTIVOS:VALLBXCTA(oACTIVOS:oATV_CTAACU,"DEP",oACTIVOS:oCTAACTDEP);
            NAME "BITMAPS\FIND.BMP"; 
            ACTION oACTIVOS:LBXCTA(oACTIVOS:oATV_CTAACU,"DEP");
                   WHEN (AccessField("DPACTIVOS","ATV_CTAACU",oACTIVOS:nOption);
                        .AND. oACTIVOS:nOption!=0 .AND. !oACTIVOS:lCtaFijGru .AND. !oACTIVOS:ATV_CTAINT);
             FONT oFontG;
             SIZE 80,10

  oACTIVOS:oATV_CTAACU:cMsg    :="Depreciación Acumulada Activo"
  oACTIVOS:oATV_CTAACU:cToolTip:="Depreciación Acumulada Activo"

  @ 16,0 SAY "Depreciación Activo" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  @ 14,05 SAY oACTIVOS:oCTAACTACU;
             PROMPT SQLGET("DPCTA","CTA_DESCRI","CTA_CODMOD"+GetWhere("=",oDp:cCtaMod)+" AND CTA_CODIGO"+GetWhere("=",oACTIVOS:ATV_CTAACU)) PIXEL;
             SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  //
  // Campo : ATV_CTADEP
  // Uso   : Depreciación Gasto
  //
  @ 14.8,14.0 BMPGET oACTIVOS:oATV_CTADEP  VAR oACTIVOS:ATV_CTADEP ;
             VALID oACTIVOS:VALLBXCTA(oACTIVOS:oATV_CTADEP,"GAS",oACTIVOS:oCTAACTDEP); 
             NAME "BITMAPS\FIND.BMP"; 
             ACTION oACTIVOS:LBXCTA(oACTIVOS:oATV_CTADEP,"GAS"); 
                    WHEN (AccessField("DPACTIVOS","ATV_CTADEP",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0 .AND. !oACTIVOS:lCtaFijGru .AND. !oACTIVOS:ATV_CTAINT);
             FONT oFontG;
             SIZE 80,10

  oACTIVOS:oATV_CTADEP:cMsg    :="Depreciación Gasto"
  oACTIVOS:oATV_CTADEP:cToolTip:="Depreciación Gasto"

  @ 12,0 SAY "Depreciación Gasto" PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  @ 0,05 SAY oACTIVOS:oCTAACTDEP;
             PROMPT SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oACTIVOS:ATV_CTADEP)) PIXEL;
             SIZE NIL,12 FONT oFont COLOR 16777215,16711680  


  //
  // Campo : ATV_CTAREV
  // Uso   : Depreciación Gasto
  //
  @ 14.8,14.0 BMPGET oACTIVOS:oATV_CTAREV  VAR oACTIVOS:ATV_CTAREV ;
              VALID oACTIVOS:VALLBXCTA(oACTIVOS:oATV_CTAREV,"REV",oACTIVOS:oCTAACTREV);
              NAME "BITMAPS\FIND.BMP"; 
              ACTION oACTIVOS:LBXCTA(oACTIVOS:oATV_CTAREV,"REV"); 
                     WHEN (AccessField("DPACTIVOS","ATV_CTAREV",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0 .AND. !oACTIVOS:lCtaFijGru .AND. !oACTIVOS:ATV_CTAINT);
              FONT oFontG;
              SIZE 80,10

    oACTIVOS:oATV_CTAREV:cMsg    :="Revaluación"
    oACTIVOS:oATV_CTAREV:cToolTip:="Revaluación"

  @ 14,0 SAY "Revaluación " PIXEL;
        SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

  @ 14,0 SAY oACTIVOS:oCTAACTREV;
             PROMPT SQLGET("DPCTA","CTA_DESCRI","CTA_CODIGO"+GetWhere("=",oACTIVOS:ATV_CTAREV)) PIXEL;
             SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  @ 16, 10 SAY "Año(s)"
  @ 17, 10 SAY "+Meses"
  @ 18, 10 SAY "Fecha"+CRLF+"Concluye"

//             VALID oACTIVOS:oDPUBIACTIVOS:SeekTable("DEP_CODIGO",oACTIVOS:oATV_CODDEP,NIL,oACTIVOS:oDEP_DESCRI);

  //
  // Campo : ATV_CODDEP
  // Uso   : Ubicación                               
  //
  @ 2.9, 0.0 BMPGET oACTIVOS:oATV_CODDEP  VAR oACTIVOS:ATV_CODDEP ;
             VALID (oACTIVOS:oDPDPTO:SeekTable("DEP_CODIGO",oACTIVOS:oATV_CODDEP,NIL,oACTIVOS:oDEP_DESCRI) .AND. (DPFOCUS(oACTIVOS:oATV_FCHADQ),.T.));
             NAME "BITMAPS\FIND.BMP"; 
             ACTION (oDpLbx:=DpLbx("DPDPTO",NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,oACTIVOS:oATV_CODDEP),;
                     oDpLbx:GetValue("DEP_CODIGO",oACTIVOS:oATV_CODDEP)); 
             WHEN (AccessField("DPACTIVOS","ATV_CODDEP",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 12,10

    oACTIVOS:oATV_CODDEP:cMsg    :=oDp:xDPDPTO                  
    oACTIVOS:oATV_CODDEP:cToolTip:=oDp:xDPDPTO

  @ 0,0 SAY oDp:xDPDPTO                                    

  @ 0,0  SAY oACTIVOS:oDEP_DESCRI;
         PROMPT oACTIVOS:oDPDPTO:DEP_DESCRI PIXEL;
         SIZE NIL,12 FONT oFont COLOR 16777215,16711680  

  SETFOLDER(2)

  oACTIVOS:oScroll:=oACTIVOS:SCROLLGET("DPACTIVOS","DPACTIVOS.SCG",cExcluye)
  oACTIVOS:oScroll:SetColSize(160,250+15,180+120+60)
  oACTIVOS:oScroll:SetColorHead(CLR_BLACK ,oDp:nGrid_ClrPaneH,oFont) 

//  oACTIVOS:oScroll:SetColor(14613246 , CLR_BLUE  , 1 , 11595007 , oFontB) 
//  oACTIVOS:oScroll:SetColor(14613246 , CLR_BLACK , 2 , 11595007 , oFont ) 
//  oACTIVOS:oScroll:SetColor(14613246 , CLR_GRAY  , 3 , 11595007 , oFont ) 

  oACTIVOS:oScroll:SetColor(16773862 , CLR_BLUE  , 1 , 16771538 , oFontB) 
  oACTIVOS:oScroll:SetColor(16773862 , CLR_BLACK , 2 , 16771538 , oFont ) 
  oACTIVOS:oScroll:SetColor(16773862 , CLR_GRAY  , 3 , 16771538 , oFont ) 

  IF oACTIVOS:IsDef("oScroll")
    oACTIVOS:oScroll:SetEdit(.F.)
  ENDIF

  SETFOLDER(0)

  bInit:=IIF(oACTIVOS:nOption<>0,{||oACTIVOS:INICIO(),oACTIVOS:LOAD(oACTIVOS:nOption)},{||oACTIVOS:INICIO()})

  oACTIVOS:SetEdit(!oACTIVOS:nOption=0)

  oACTIVOS:Activate(bInit)

  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oACTIVOS

FUNCTION INICIO()

  oACTIVOS:oScroll:oBrw:SetColor(NIL , 16773862 )
  oACTIVOS:oDlg:oBar:SetColor(CLR_WHITE,oDp:nGris)
  AEVAL(oACTIVOS:oDlg:oBar:aControls,{|oBtn|oBtn:SetColor(CLR_WHITE,oDp:nGris)})
  oACTIVOS:lDatosIni:=Empty(oACTIVOS:ATV_FCHINC)
  oACTIVOS:CALFCHMAXDEP() // Calcula Fecha Maxima depreciación

  IF oACTIVOS:nOption=1
     oACTIVOS:LOAD(1)
  ENDIF


RETURN .T.
/*
// Carga de los Datos
*/
FUNCTION LOAD()
  LOCAL cMsg,I,cATVCODIGO:=oACTIVOS:ATV_CODIGO

  oACTIVOS:lDeprecia:=.F.
  oACTIVOS:lCompras :=.F.

  IF oACTIVOS:nOption=0 // Incluir en caso de ser Incremental
     oACTIVOS:SetEdit(.F.) // Inactiva la Edicion
  ELSE
     oACTIVOS:SetEdit(.T.) // Activa la Edicion
  ENDIF

  IF oACTIVOS:nOption=1 // Incluir en caso de ser Incremental

     oACTIVOS:oFolder:SetOption(1)

     cATVCODIGO:=oACTIVOS:oTable:ATV_CODIGO

     oACTIVOS:SET("ATV_CENCOS",oDp:cCenCos  ,.T.)
     oACTIVOS:SET("ATV_CODSUC",oDp:cSucursal,.T.)
     oACTIVOS:SET("ATV_ESTADO","A"          ,.T.)
     oACTIVOS:SET("ATV_FCHINC",CTOD("")     ,.T.)
     oACTIVOS:SET("ATV_MESDEP",0                )
     oACTIVOS:SET("ATV_COSADQ",0                )
     oACTIVOS:SET("ATV_ANOGAR",0                )
     oACTIVOS:SET("ATV_MESGAR",0                )
     oACTIVOS:SET("ATV_DEPMEN",0                )

     oACTIVOS:SET("ATV_FCHADQ",CTOD("")         )
     oACTIVOS:SET("ATV_FCHDEP",CTOD("")         )
     oACTIVOS:SET("ATV_FCHINC",CTOD("")         )
     oACTIVOS:SET("ATV_FCHGAR",CTOD("")         )
     oACTIVOS:SET("ATV_METODO","L"          ,.T.)

     COMBOINI(oACTIVOS:oATV_METODO)

     oACTIVOS:ATV_CTAINT:=.T.
//   oACTIVOS:oATV_FCHADQ:VarPut(oDp:dFecha,.T.)
//   oACTIVOS:oATV_FCHINC:VarPut(FCHFINMES(FCHFINMES(oDp:dFecha)+1),.T.)
//   oACTIVOS:oATV_FCHDEP:VarPut(FCHFINMES(FCHFINMES(oDp:dFecha)+1),.T.)

     oACTIVOS:AUTOCODE()

  ELSE

     oACTIVOS:SET("ATV_ESTADO","A"          ,.T.)
     oACTIVOS:SETATVCODGRU()
//   oACTIVOS:lCtaFijGru:=SQLGET("DPGRUACTIVOS","GAC_CTAFIJ","GAC_CODIGO"+GetWhere("=",oACTIVOS:ATV_CODGRU))
  ENDIF

  oACTIVOS:lDatosIni:=!Empty(oACTIVOS:ATV_FCHINC)
  oACTIVOS:CALFCHMAXDEP() // Calcula Fecha Maxima depreciación

  oACTIVOS:ATV_CTAACT:=EJECUTAR("DPGETCTAMOD","DPACTIVOS",cATVCODIGO,NIL,"CTAACT")
  oACTIVOS:ATV_CTAACU:=EJECUTAR("DPGETCTAMOD","DPACTIVOS",cATVCODIGO,NIL,"CTAACU")
  oACTIVOS:ATV_CTADEP:=EJECUTAR("DPGETCTAMOD","DPACTIVOS",cATVCODIGO,NIL,"CTADEP")
  oACTIVOS:ATV_CTAREV:=EJECUTAR("DPGETCTAMOD","DPACTIVOS",cATVCODIGO,NIL,"CTAREV")

  // Modificar

  IF oACTIVOS:nOption=3

    oACTIVOS:GETDEPRECIA()

    IF oACTIVOS:nContab>0
       cMsg:=LSTR(oACTIVOS:nContab)+" Depreciacion(es) Contabilizada(s)"
    ENDIF

    IF oACTIVOS:nDesinc>0
       cMsg:=IIF(Empty(cMsg),"",CRLF)+;
             LSTR(oACTIVOS:nDesinc)+" Depreciacion(es) Desincorporadas(s)"
    ENDIF

    IF !Empty(cMsg)
       oACTIVOS:lDeprecia:=.T.
       MensajeErr("No será posible Editar campos que afectan las depreciaciones"+CRLF+cMsg)
    ENDIF

    IF !Empty(oACTIVOS:ATV_TIPDOC)

       MensajeErr("Activo Ingresado desde Documentos de Compras"+CRLF+;
                  "No será Posible Editar Campos que Afecten los Resultados")

      oACTIVOS:lCompras:=.T.

    ENDIF

  ENDIF

  IF oACTIVOS:IsDef("oScroll")
    oACTIVOS:oScroll:SetEdit(oACTIVOS:nOption=1.OR.oACTIVOS:nOption=3)
  ENDIF

  oACTIVOS:cEstado:=IIF(oACTIVOS:ATV_ESTADO="A","Activo","")
  oACTIVOS:cEstado:=IIF(oACTIVOS:ATV_ESTADO="D","Desincorporada",oACTIVOS:cEstado)
  oACTIVOS:cEstado:=IIF(oACTIVOS:ATV_ESTADO="I","Inactivo"      ,oACTIVOS:cEstado)

  FOR I=1 TO LEN(oACTIVOS:oFolder:aDialogs)
     AEVAL(oACTIVOS:oFolder:aDialogs[i]:aControls,{|o,n| o:Refresh(.T.) } )
  NEXT I

  oACTIVOS:oEstado:Refresh(.T.)

  oACTIVOS:oSayMeses:Refresh(.T.)

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

  IF oACTIVOS:nOption=1
    oACTIVOS:AUTOCODE()
  ENDIF

  IF !oACTIVOS:ValUnique(oACTIVOS:ATV_CODIGO)
    oACTIVOS:AUTOCODE()
    RETURN .F.
  ENDIF

  IF !oACTIVOS:VALEJEINI(oACTIVOS:ATV_FCHADQ,"Fecha de Adquisición")
      RETURN .F.
  ENDIF

  IF !oACTIVOS:VALEJEINI(oACTIVOS:ATV_FCHINC,"Fecha de Inclusión")
      RETURN .F.
  ENDIF

  IF !oACTIVOS:VALEJEINI(oACTIVOS:ATV_FCHDEP,"Fecha de la Primera Depreciación")
     RETURN .F.
  ENDIF

  IF EMPTY(oACTIVOS:ATV_CODSUC)
     oACTIVOS:ATV_CODSUC:=oDp:cSucursal
  ENDIF

  lResp:=oACTIVOS:ValUnique(oACTIVOS:ATV_CODIGO)

  IF !lResp
     MsgAlert("Registro "+CTOO(oACTIVOS:ATV_CODIGO),"Ya Existe")
  ENDIF

  IF oACTIVOS:ATV_COSADQ=0

     MsgAlert("Debe Indicar el Costo de Adquisición")
     lResp:=.F.

  ENDIF
 
  IF EMPTY(oACTIVOS:ATV_CODIGO)
     MensajeErr("Código no Puede estar Vacio")
     RETURN .F.
  ENDIF
  
  // Fecha Maxima
  oACTIVOS:ATV_FCHMAX:=oACTIVOS:dFechaMax

  // ? oACTIVOS:dFechaMax,oACTIVOS:ATV_FCHMAX
  // Datos Iniciales

  oACTIVOS:lIntRef:=.F.
  oACTIVOS:AVTDATOSINI()

RETURN lResp

/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()

  // Antes debemos Verificar si tiene Asientos Contables

  EJECUTAR("DPACTIVOSTODEP",oACTIVOS:ATV_CODIGO,;
                            oACTIVOS:ATV_FCHADQ,;
                            oACTIVOS:ATV_COSADQ,;
                            oACTIVOS:ATV_FCHINC,;
                            oACTIVOS:ATV_DEPACU,;
                            oACTIVOS:ATV_MTOFIN,;
                            oACTIVOS:ATV_MTOFIS)

//  IF oACTIVOS:nOption<>1 .AND. LEFT(oACTIVOS:ATV_DEPRE,1)="D"
  IF LEFT(oACTIVOS:ATV_DEPRE,1)="D"
    MsgRun("Recalculando Depreciación","Por Favor Espere...",{||EJECUTAR("DPDEPRECCALC",oACTIVOS:ATV_CODSUC,oACTIVOS:ATV_CODIGO,.T.)})
  ENDIF

  // Grabar las cuentas bancarias JN 18/08/2014
  EJECUTAR("SETCTAINTMOD","DPACTIVOS",oACTIVOS:ATV_CODIGO,NIL,"CTAACT",oACTIVOS:ATV_CTAACT,.T.)
  EJECUTAR("SETCTAINTMOD","DPACTIVOS",oACTIVOS:ATV_CODIGO,NIL,"CTAACU",oACTIVOS:ATV_CTAACU,.T.)
  EJECUTAR("SETCTAINTMOD","DPACTIVOS",oACTIVOS:ATV_CODIGO,NIL,"CTADEP",oACTIVOS:ATV_CTADEP,.T.)
  EJECUTAR("SETCTAINTMOD","DPACTIVOS",oACTIVOS:ATV_CODIGO,NIL,"CTAREV",oACTIVOS:ATV_CTAREV,.T.)

// FCHADQ
// cCodigo,dFecha,nCosto
  EJECUTAR("DPACTIVOSMNU",oACTIVOS:ATV_CODSUC,oACTIVOS:ATV_CODIGO)

RETURN .T.

FUNCTION PRINT()
  REPORTE("DPACTIVOS")
RETURN .T.

FUNCTION AUTOCOD()

   LOCAL cCod:=SQLINCREMENTAL("DPACTIVOS","ATV_CODIGO")

   oACTIVOS:oATV_CODIGO:VarPut(cCod,.T.)
   oACTIVOS:oATV_CODIGO:KeyBoard(13)
   
RETURN .T.

FUNCTION ATVFCHINC()
    LOCAL nMeses:=0

    IF Empty(oACTIVOS:ATV_FCHINC)
       oACTIVOS:oATV_FCHINC:VarPut(oACTIVOS:ATV_FCHDEP,.T.)
       oACTIVOS:CALATVMESDEP() 
       RETURN .T.
    ENDIF

    oACTIVOS:CALFCHMAXDEP()

    IF !(oACTIVOS:dFechaMax>oACTIVOS:ATV_FCHINC)
       MensajeErr("Fecha de Inclusion debe ser Menor que la Fecha Máxima de Depreciación "+DTOC(oACTIVOS:dFechaMax))
       RETURN .F.
    ENDIF

    IF oACTIVOS:ATV_FCHINC<oACTIVOS:ATV_FCHDEP

      MensajeErr("Fecha de Depreciación Desde "+DTOC(oACTIVOS:ATV_FCHINC)+CRLF+;
                 "debe ser Mayor o Igual que "+DTOC(oACTIVOS:ATV_FCHDEP))
    
      oACTIVOS:oATV_FCHINC:VarPut(oACTIVOS:ATV_FCHDEP,.T.)
      oACTIVOS:oATV_MESDEP:VarPut(0,.T.)

    ELSE

       oACTIVOS:CALATVMESDEP()

    ENDIF



RETURN .T.

/*
// Calculo de Meses depreciados, este valor se calcula entre la fecha de la primera depreciacion con Fecha de Inclusion del Activo ATV_FCHINC
*/
FUNCTION CALATVMESDEP()
    LOCAL nMeses:=0
  
    nMeses:=MESES(oACTIVOS:ATV_FCHDEP,oACTIVOS:ATV_FCHINC)

// ? "CALATVMESDEP()"

    oACTIVOS:oATV_MESDEP:VarPut(nMeses,.T.)
    oACTIVOS:oATV_DEPACU:VarPut(oACTIVOS:ATV_DEPMEN * nMeses,.T.)

RETURN .T.

/*
// Valida Valor de Salvamento
*/
FUNCTION ATVVALSAL()
    LOCAL nMeses:=0

    IF oACTIVOS:ATV_VALSAL>oACTIVOS:ATV_COSADQ
       MensajeErr("Valor de Salvamento debe ser Inferior que el Costo de Adquisición")
       RETURN .F.
    ENDIF

    // Debe calcular la Depreciacion Mensual
    oACTIVOS:ATVVIDA_M()

RETURN .T.

/*
// Costo de Adquisición
*/
FUNCTION ATVCOSADQ() 

   oACTIVOS:ATVVIDA_M()

RETURN .T.
/*
// Vida Mensual
*/
FUNCTION ATVVIDA_M()
   LOCAL nMeses:=0,nCuotas:=0
   nMeses :=((oActivos:ATV_VIDA_A*12)+oActivos:ATV_VIDA_M)-oActivos:ATV_MESDEP

   nCuotas:=DIV(oActivos:ATV_COSADQ - (oActivos:ATV_VALSAL+oActivos:ATV_DEPACU  ),nMeses)

   oACTIVOS:oATV_DEPMEN:VarPut(nCuotas,.T.)
   oACTIVOS:ATV_DEPMEN:=nCuotas

   oACTIVOS:CALATVMESDEP() // Calcula la depreciacion Acumulada
   oACTIVOS:CALFCHMAXDEP()

RETURN .T.
/*
// Maxima Fecha de Depreciacion
*/
FUNCTION CALFCHMAXDEP()
   LOCAL nMeses:=((oActivos:ATV_VIDA_A*12)+oActivos:ATV_VIDA_M)-oActivos:ATV_MESDEP

   oACTIVOS:dFechaMax:=CTOD("")

   IF !Empty(oACTIVOS:ATV_FCHDEP)

    oACTIVOS:nMeses:=nMeses
    oACTIVOS:dFechaMax:=FCHFINMES(oACTIVOS:ATV_FCHDEP) // Fecha depreciacion

    // Calcula la Fecha de Conclusion del Activo
    AEVAL(ARRAY(MAX(nMeses-1,0)),{|a,n| oACTIVOS:dFechaMax:=FCHFINMES(oACTIVOS:dFechaMax)+1 })

    oACTIVOS:dFechaMax:=FCHFINMES(oACTIVOS:dFechaMax)

   ENDIF

   oACTIVOS:oFechaMax:Refresh(.T.)
   oACTIVOS:oCantMeses:Refresh(.T.)

RETURN .T.

/*
// Valida Meses Depreciados
*/
FUNCTION ATVMESDEP()
    LOCAL nMeses:=0,nCuotas

    IF oACTIVOS:ATV_MESDEP<0
       MensajeErr("Meses Depreciados debe ser Mayor o Igual que Cero 0")
       RETURN .F.
    ENDIF

    oACTIVOS:CALATVMESDEP()  // Calcula los Me

//  IF oACTIVOS:ATV_MESDEP=0
//     oACTIVOS:oATV_DEPACU:VarPut(0,.T.)
//  ENDIF

    nMeses :=((oActivos:ATV_VIDA_A*12)+oActivos:ATV_VIDA_M)
    nCuotas:=DIV(oActivos:ATV_COSADQ - (oActivos:ATV_VALSAL),nMeses)

//  oACTIVOS:oATV_DEPMEN:VarPut(nCuotas,.T.)
//  oACTIVOS:ATV_DEPMEN:=nCuotas

// JN 15/10/2014
// oACTIVOS:oATV_DEPACU:VarPut(oACTIVOS:ATV_MESDEP * nCuotas,.T.)
// LA DEPRECIACION ACUMULADA DEBE SER CALCULADA ENTRE LOS MESES DE FECHA DE INGRESO CON FECHA DE LA PRIMERA DEPRECIACION
     oACTIVOS:ATVVIDA_M()

RETURN .T.

/*
// Validar Fecha de la Primera Depreciación
*/
FUNCTION ATVFCHDEP()

    IF oACTIVOS:ATV_FCHDEP<oACTIVOS:ATV_FCHADQ

       MensajeErr("Fecha de la Primera Depreciación: "+DTOC(oACTIVOS:ATV_FCHDEP)+CRLF+;
                  "Debe ser superior que la Fecha de Adquisición: "+DTOC(oACTIVOS:ATV_FCHADQ))
       oACTIVOS:oATV_FCHDEP:VarPut(FCHFINMES(oACTIVOS:ATV_FCHADQ),.T.)

       RETURN .F.

    ENDIF

    oACTIVOS:CALATVMESDEP()
    oACTIVOS:CALFCHMAXDEP()


RETURN .T.
     
/*
// Revisa Fecha de Adquisición
*/
FUNCTION ATVFCHADQ()
  LOCAL cNumEje:=""
  
  IF EMPTY(oACTIVOS:ATV_FCHADQ)
     MensajeErr("Fecha de Adquisición no puede estar Vacia")
     RETURN .F.
  ENDIF

  cNumEje:=EJECUTAR("GETNUMEJE",oACTIVOS:ATV_FCHADQ,.F.)

  IF Empty(cNumEje)
     MensajeErr("Fecha "+DTOC(oACTIVOS:ATV_FCHADQ)+" no corresponde a Ningún Ejercicio Registrado")
     RETURN .F.
  ENDIF

  oACTIVOS:oATV_FCHINC:VarPut(FCHFINMES(FCHFINMES(oACTIVOS:ATV_FCHADQ)+1),.T.)
  oACTIVOS:oATV_FCHDEP:VarPut(FCHFINMES(FCHFINMES(oACTIVOS:ATV_FCHADQ)+1),.T.)

RETURN .T.

/*
// Obtiene Datos de Depreciación Contabilizada
*/

FUNCTION GETDEPRECIA()

   CursorWait()

   oACTIVOS:nContab:=MYCOUNT("DPDEPRECIAACT","DEP_CODACT"+GetWhere("=",oACTIVOS:ATV_CODIGO)+" AND "+;
                                             "DEP_ESTADO='C'")

   oACTIVOS:nDesinc:=MYCOUNT("DPDEPRECIAACT","DEP_CODACT"+GetWhere("=",oACTIVOS:ATV_CODIGO)+" AND "+;
                                             "DEP_ESTADO='D'")

RETURN .T.

FUNCTION ATVDEPACU()

   IF oACTIVOS:ATV_DEPACU>oACTIVOS:ATV_COSADQ

      MensajeErr("Depreciación Acumulada no puede ser superior"+CRLF+;
                 "que el costo de adquisición:"+ALLTRIM(TRAN(oACTIVOS:ATV_COSADQ,"999,999,999,999.99")))

      RETURN .F.

   ENDIF

   oACTIVOS:ATVVIDA_M()

RETURN .T.

FUNCTION PRINT()

    EJECUTAR("DPFICHAACTIVOS",oACTIVOS:ATV_CODIGO,NIL,NIL," WHERE ATV_CODSUC"+GetWhere("=",oACTIVOS:ATV_CODSUC)+;
                                                          "   AND ATV_CODIGO"+GetWhere("=",oACTIVOS:ATV_CODIGO),,,,,,,oACTIVOS:ATV_CODSUC)

RETURN .T.
/*
// Valida Grupo
*/
FUNCTION VALCODGRU()

   LOCAL nMeses:=0

   nMeses:=SQLGET("DPGRUACTIVOS","GAC_VUTILA,GAC_VUTILM,GAC_PORVLS","GAC_CODIGO"+GetWhere("=",oACTIVOS:ATV_CODGRU))

   oACTIVOS:nPorcen:=0

   IF !Empty(oDp:aRow)

      oACTIVOS:oATV_VIDA_A:VarPut(oDp:aRow[1],.T.)
      oACTIVOS:oATV_VIDA_M:VarPut(oDp:aRow[2],.T.)
      oACTIVOS:oATV_PORVAL:VarPut(oDp:aRow[3],.T.)

      oACTIVOS:nPorcen:=oDp:aRow[3]

      oACTIVOS:ASIGNAVALSAL()

   ENDIF

   oACTIVOS:SETATVCODGRU()

RETURN .T.

/*
// Calcula el Valor de Salvamento segun % Indicado en el Grupo del Activo
*/
FUNCTION ASIGNAVALSAL()

  IF oACTIVOS:nPorcen>0
    oACTIVOS:oATV_VALSAL:VarPut(PORCEN(oACTIVOS:ATV_COSADQ,oACTIVOS:nPorcen),.T.)
  ENDIF


RETURN .T.

FUNCTION ATVMTOFIS()
RETURN .T.

FUNCTION ATVMTOFIN()
RETURN .T.

FUNCTION ATVGUARDAR(oControl)

  IF oControl:nLastkey=13
     oACTIVOS:SAVE(.T.) // Ejecuta guardar
  ENDIF

RETURN .T.

/*
// Datos Iniciales
*/
FUNCTION AVTDATOSINI()

  IF oACTIVOS:lDatosIni
     oACTIVOS:oATV_FCHINC:VarPut(CTOD(""),.T.)
     oACTIVOS:oATV_MESDEP:VarPut(0       ,.T.)
     oACTIVOS:oATV_DEPACU:VarPut(0       ,.T.)
     oACTIVOS:oATV_MTOFIS:VarPut(0       ,.T.)
     oACTIVOS:oATV_MTOFIN:VarPut(0       ,.T.)
  ENDIF

RETURN .T.

FUNCTION VALCTADET(cCodCta,cTipo)

   IF !EJECUTAR("ISCTADET",cCodCta,.F.)
     MensajeErr("Cuenta "+cCodCta+" no Acepta Asientos")
     RETURN .F.
   ENDIF

RETURN .T.

FUNCTION VALLBXCTA(oGet,cPropied,oSay)
  LOCAL cWhere:=EJECUTAR("DPCTAPROPWHERE",cPropied)
  LOCAL cTiTLE:=EJECUTAR("DPCTAPROPGET",cPropied)
  LOCAL cCodigo:=ALLTRIM(EVAL(oGet:bSetGet))
  LOCAL cCtaPro:=ALLTRIM(SQLGET("DPCTA","CTA_PROPIE,CTA_CODIGO","CTA_CODIGO"+GetWhere("=",cCodigo)))
  LOCAL cCtaCod:=DPSQLROW(2)

  IF COUNT("DPCTA",cWhere)=0 
     MensajeErr("No hay Cuentas Contables definidas para ["+cTitle+"]")
     RETURN .F.
  ENDIF
  
  IF Empty(cCtaCod)
     MensajeErr("Cuenta "+cCodigo+" no Existe")
     EVAL(oGet:bAction)
     RETURN .F.
  ENDIF

  IF !(cCtaPro==cTitle)
     MensajeErr("Cuenta ["+cCodigo+"] Deber poseer Propiedad ["+cTitle+"]")
     RETURN .F.
  ENDIF

  IF !EJECUTAR("ISCTADET",cCodigo,.F.) 
    MensajeErr("Cuenta "+cCodigo+" no Acepta Asientos")
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
     MensajeErr("No hay Cuentas Contables definidas para ["+cTitle+"]")
     RETURN .F.
  ENDIF
 
  
  oDpLbx:=DpLbx("DPCTA",cTitle,cWhere)
  oDpLbx:GetValue("CTA_CODIGO",oGet)

RETURN .T.

FUNCTION VALEJEINI(dFecha,cText)
  LOCAL dFchIni:=SQLGET("DPEJERCICIOS","EJE_DESDE","EJE_AXIINI=1")

  IF !Empty(dFecha) .AND. dFecha<dFchIni
    MensajeErr(cText+" "+DTOC(dFecha)+" no puede ser Inferior a la Fecha de Ejercicio Inicial "+DTOC(dFchIni))
    RETURN .F.
  ENDIF

RETURN .T.
/*
// Fecha de Conclusion de Garantía
*/
FUNCTIO ATVFCHGAR()
RETURN .T.
/*
// Calcular Fecha de Garantía
*/
FUNCTION ATVCALFCHGAR()
   LOCAL nMeses:=((oACTIVOS:ATV_ANOGAR*12)+oACTIVOS:ATV_MESGAR)

   oACTIVOS:ATV_FCHGAR:=FCHFINMES(oACTIVOS:ATV_FCHADQ)

   // Calcula la Fecha de Conclusion del Activo
   AEVAL(ARRAY(nMeses),{|a,n| oACTIVOS:ATV_FCHGAR:=FCHFINMES(oACTIVOS:ATV_FCHGAR)+1 })

   oACTIVOS:oATV_FCHGAR:VARPUT(oACTIVOS:ATV_FCHGAR,.T.)

RETURN .T.

FUNCTION SETATVCODGRU()
   LOCAL oCuentas

   oACTIVOS:lCtaFijGru:=SQLGET("DPGRUACTIVOS","GAC_CTAFIJ","GAC_CODIGO"+GetWhere("=",oACTIVOS:ATV_CODGRU))
   
   //  Si modifica y es fija debe Asignar las Cuentas Bancarias

   IF oACTIVOS:nOption=1 .OR. oACTIVOS:lCtaFijGru

      oCuentas:=OpenTable("SELECT CIC_CODINT,CIC_CUENTA FROM DPGRUACTIVOS_CTA WHERE CIC_CTAMOD"+GetWhere("=",oDp:cCtaMod)+" AND "+;
                                                               "CIC_CODIGO"+GetWhere("=",oACTIVOS:ATV_CODGRU))

      WHILE !oCuentas:EOF()

        IF "CTAACT"$oCuentas:CIC_CODINT
         oACTIVOS:oATV_CTAACT:VarPut(oCuentas:CIC_CUENTA,.T.)
        ENDIF

        IF "CTAACU"$oCuentas:CIC_CODINT
         oACTIVOS:oATV_CTAACU:VarPut(oCuentas:CIC_CUENTA,.T.)
        ENDIF

        IF "CTADEP"$oCuentas:CIC_CODINT
         oACTIVOS:oATV_CTADEP:VarPut(oCuentas:CIC_CUENTA,.T.)
        ENDIF

       IF "CTAREV"$oCuentas:CIC_CODINT
         oACTIVOS:oATV_CTAREV:VarPut(oCuentas:CIC_CUENTA,.T.)
       ENDIF

       oCuentas:DbSkip()

      ENDDO
      oCuentas:End()

      oACTIVOS:oCTAACTACT:Refresh(.T.)
      oACTIVOS:oCTAACTACU:Refresh(.T.)
      oACTIVOS:oCTAACTDEP:Refresh(.T.)
      oACTIVOS:oCTAACTREV:Refresh(.T.)
   
   ENDIF
   
RETURN .T.

FUNCTION AUTOCODE()
   LOCAL oTable,nLen:=LEN(oACTIVOS:ATV_CODIGO)

   IF (oDp:lACTAut .AND. oDp:nACTLen>1)

      oTable:=OpenTable("SELECT ATV_CODIGO FROM DPACTIVOS ORDER BY CAST(ATV_CODIGO AS UNSIGNED) DESC LIMIT 1")
      oTable:End()

      oACTIVOS:ATV_CODIGO:=ALLTRIM(oTable:ATV_CODIGO)

      IF Empty(oACTIVOS:ATV_CODIGO)
         oACTIVOS:ATV_CODIGO:=SQLINCREMENTAL("DPACTIVOS","ATV_CODIGO",NIL,NIL,NIL,.T.)
         oACTIVOS:ATV_CODIGO:=PADR(RIGHT(oACTIVOS:ATV_CODIGO,oDp:nACTLen),nLen)
         oACTIVOS:oATV_CODIGO:VarPut(oACTIVOS:ATV_CODIGO,.T.)
         RETURN .T.
      ENDIF

      IF LEN(oACTIVOS:ATV_CODIGO)>oDp:nACTLen 
         MensajeErr("Longitud ("+LSTR(LEN(oACTIVOS:ATV_CODIGO))+") del Ultimo Codigo "+oACTIVOS:ATV_CODIGO+;
                               " es superior a la Longitud "+LSTR(oDp:nACTLen)+" indicada en Configuración de la Empresa")
         oACTIVOS:CANCEL()
      ENDIF

      oACTIVOS:ATV_CODIGO:=PADR(DPINCREMENTAL(oACTIVOS:ATV_CODIGO),nLen)
      oACTIVOS:oATV_CODIGO:VarPut(oACTIVOS:ATV_CODIGO,.T.)

    ENDIF

RETURN .T.

/*
// Porcentaje del Valor de Salvamento
*/
FUNCTION ATVPORVAL()

   IF oACTIVOS:ATV_PORVAL>0
     oACTIVOS:ATV_VALSAL:=PORCEN(oACTIVOS:ATV_COSADQ,oACTIVOS:ATV_PORVAL)
     oACTIVOS:oATV_VALSAL:VarPut(oACTIVOS:ATV_VALSAL,.T.)
     RETURN .T.
   ENDIF

   IF oACTIVOS:ATV_PORVAL<0 .OR. .T.
      MensajeErr("Porcentaje del Valor de Salvamento debe ser Mayor que cero")
      RETURN .T.
   ENDIF
    
RETURN .T.

/*
<LISTA:ATV_CODIGO:Y:GET:N:N:N:Código,ATV_DESCRI:N:GET:N:N:Y:Descripción,ATV_DEPRE:N:COMBO:N:N:Y:Tipo de Activo,Pestaña01:N:GET:N:N:N:Básicos,ATV_CODGRU:N:BMPGETL:N:N:Y:Grupo,ATV_CODUBI:N:BMPGETL:N:N:Y:Ubicación,ATV_FCHADQ:N:BMPGET:N:N:Y:Fecha de Adquisición,ATV_COSADQ:N:GET:N:N:Y:Costo de Adquisición
,ATV_VALSAL:N:GET:N:N:Y:Valor de Salvamento,ATV_VIDA_A:N:GET:N:N:Y:Vida Util en Años,ATV_VIDA_M:N:GET:N:N:Y:Más Vida Util en Meses,ATV_CTAACT:N:BMPGETL:N:N:Y:Activo
,Pestaña02:N:GET:N:N:N:Depreciación,ATV_METODO:N:COMBO:N:N:Y:Método de Depreciación,ATV_FCHINC:N:BMPGET:N:N:Y:Inicio Contable,ATV_FCHDEP:N:BMPGET:N:N:Y:Primeria Depreciación
,ATV_DEPACU:N:GET:N:N:Y:Depreciación Acumulada,ATV_MESDEP:N:GET:N:N:Y:Meses Depreciados,ATV_UNIPRO:N:GET:N:N:Y:Unidades a Producir,ATV_DEPMEN:N:GET:N:N:Y:Depreciación Mensual Fija
,ATV_CTAACU:N:BMPGETL:N:N:Y:Depreciación  Activo,ATV_CTADEP:N:BMPGETL:N:N:Y:Depreciación Gasto,Pestaña03:N:GET:N:N:N:Datos Adicionales,SCROLLGET:N:GET:N:N:N:Para Diversos Campos>
*/
