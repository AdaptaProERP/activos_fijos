// Programa   : DPACTIVOS
// Fecha/Hora : 21/06/2006 17:44:39
// Propósito  : Documento DPACTIVOS
// Creado Por : DpXbase
// Llamado por: DPACTIVOS.LBX
// Aplicación : Activos Fijos                           
// Tabla      : DPACTIVOS

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION DPACTIVOS(nOption,cCodigo)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG
  LOCAL cSql,cFile,cExcluye:=""
  LOCAL nClrText
  LOCAL oBrw,cSqlCuerpo,oCuerpo,oCol,oCursorC
  LOCAL cTitle:="Activos Fijos",;
         aItems1:=GETOPTIONS("DPACTIVOS","ATV_DEPRE"),;
         aItems2:=GETOPTIONS("DPACTIVOS","ATV_METODO")

  cExcluye:="ATV_CODIGO,;
             ATV_DESCRI,;
             ATV_DEPRE,;
             ATV_CODGRU,;
             ATV_CODUBI,;
             ATV_FCHADQ,;
             ATV_COSADQ,;
             ATV_VALSAL,;
             ATV_VIDA_A,;
             ATV_VIDA_M,;
             ATV_CTAACT,;
             ATV_METODO,;
             ATV_FCHINC,;
             ATV_FCHDEP,;
             ATV_DEPACU,;
             ATV_MESDEP,;
             ATV_UNIPRO,;
             ATV_DEPMEN,;
             ATV_CTAACU,;
             ATV_CTADEP"

  DEFAULT cCodigo:="1234"

  DEFAULT nOption:=0

  DEFINE FONT oFont  NAME "Verdana" SIZE 0, -10 BOLD
  DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD ITALIC
  DEFINE FONT oFontG NAME "Arial"   SIZE 0, -11

  nClrText:=10485760 // Color del texto

  cTitle   :=" {oDp:DPACTIVOS}"

  cSql  :=[SELECT * FROM DPACTIVOS]
  oTable:=OpenTable(cSql,.F.) // nOption!=1)
  oTable:cPrimary:="ATV_CODIGO" // Clave de Validación de Registro

  oACTIVOS:=DPEDIT():New(cTitle,"DPACTIVOS.edt","oACTIVOS" , .F. )

  oACTIVOS:lDlg :=.T.            // Formulario Sin Dialog
  oACTIVOS:nMode:=1              // Formulario Tipo de Documento
  oACTIVOS:nClrPane:=oDp:nGris
  oACTIVOS:nOption  :=nOption
  oACTIVOS:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oACTIVOS

  oACTIVOS:SetScript()        // Asigna Funciones DpXbase como Metodos de oACTIVOS
  oACTIVOS:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY

  //Tablas Relacionadas con los Controles del Formulario
  

  oACTIVOS:CreateWindow()        // Presenta la Ventana

  
  oACTIVOS:ViewTable("DPGRUACTIVOS","GAC_DESCRI","GAC_CODIGO","ATV_CODGRU")
  oACTIVOS:ViewTable("DPUBIACTIVOS","UAC_DESCRI","UAC_CODIGO","ATV_CODUBI")
  oACTIVOS:ViewTable("DPCTA","CTA_DESCRI","CTA_CODIGO","ATV_CTAACT")
  oACTIVOS:ViewTable("DPCTA","CTA_DESCRI","CTA_CODIGO","ATV_CTAACU")
  oACTIVOS:ViewTable("DPCTA","CTA_DESCRI","CTA_CODIGO","ATV_CTADEP")

  
  //
  // Campo : ATV_CODIGO
  // Uso   : Código                                  
  //
  @ 3.0, 1.0 GET oACTIVOS:oATV_CODIGO  VAR oACTIVOS:ATV_CODIGO  VALID oACTIVOS:ValUnique(oACTIVOS:ATV_CODIGO);
                   .AND. !VACIO(oACTIVOS:ATV_CODIGO,NIL);
                    WHEN (AccessField("DPACTIVOS","ATV_CODIGO",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 60,10

    oACTIVOS:oATV_CODIGO:cMsg    :="Código"
    oACTIVOS:oATV_CODIGO:cToolTip:="Código"

  @ oACTIVOS:oATV_CODIGO:nTop-08,oACTIVOS:oATV_CODIGO:nLeft SAY "Código" PIXEL;
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

  @ oACTIVOS:oATV_DESCRI:nTop-08,oACTIVOS:oATV_DESCRI:nLeft SAY "Descripción" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : ATV_DEPRE 
  // Uso   : Depreciable S/N                         
  //
  @ 6.1, 1.0 COMBOBOX oACTIVOS:oATV_DEPRE  VAR oACTIVOS:ATV_DEPRE  ITEMS aItems1;
                      WHEN (AccessField("DPACTIVOS","ATV_DEPRE",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                      FONT oFontG;


 ComboIni(oACTIVOS:oATV_DEPRE )


    oACTIVOS:oATV_DEPRE :cMsg    :="Depreciable S/N"
    oACTIVOS:oATV_DEPRE :cToolTip:="Depreciable S/N"

  @ oACTIVOS:oATV_DEPRE :nTop-08,oACTIVOS:oATV_DEPRE :nLeft SAY "Tipo de Activo" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris



  @ 7.9, 1.0 FOLDER oACTIVOS:oFolder ITEMS "Básicos","Depreciación","Datos Adicionales";
                      FONT oFontG

     SETFOLDER( 1)
  //
  // Campo : ATV_CODGRU
  // Uso   : Grupo                                   
  //
  @ 1.1, 0.0 BMPGET oACTIVOS:oATV_CODGRU  VAR oACTIVOS:ATV_CODGRU ;
                VALID oACTIVOS:oDPGRUACTIVOS:SeekTable("GAC_CODIGO",oACTIVOS:oATV_CODGRU,NIL,oACTIVOS:oGAC_DESCRI);
                    NAME "BITMAPS\FIND.BMP"; 
                     ACTION (oDpLbx:=DpLbx("DPGRUACTIVOS"), oDpLbx:GetValue("GAC_CODIGO",oACTIVOS:oATV_CODGRU)); 
                    WHEN (AccessField("DPACTIVOS","ATV_CODGRU",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 32,10

    oACTIVOS:oATV_CODGRU:cMsg    :="Grupo"
    oACTIVOS:oATV_CODGRU:cToolTip:="Grupo"

  @ oACTIVOS:oATV_CODGRU:nTop-08,oACTIVOS:oATV_CODGRU:nLeft SAY GetFromVar("{oDp:xDPGRUACTIVOS}") PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

//GetFromVar("{oDp:xDPGRUACTIVOS}")
  @ oACTIVOS:oATV_CODGRU:nTop,oACTIVOS:oATV_CODGRU:nRight+5 SAY oACTIVOS:oGAC_DESCRI;
                            PROMPT oACTIVOS:oDPGRUACTIVOS:GAC_DESCRI PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680 BORDER 


  //
  // Campo : ATV_CODUBI
  // Uso   : Ubicación                               
  //
  @ 2.9, 0.0 BMPGET oACTIVOS:oATV_CODUBI  VAR oACTIVOS:ATV_CODUBI ;
                VALID oACTIVOS:oDPUBIACTIVOS:SeekTable("UAC_CODIGO",oACTIVOS:oATV_CODUBI,NIL,oACTIVOS:oUAC_DESCRI);
                    NAME "BITMAPS\FIND.BMP"; 
                     ACTION (oDpLbx:=DpLbx("DPUBIACTIVOS"), oDpLbx:GetValue("UAC_CODIGO",oACTIVOS:oATV_CODUBI)); 
                    WHEN (AccessField("DPACTIVOS","ATV_CODUBI",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 32,10

    oACTIVOS:oATV_CODUBI:cMsg    :="Ubicación"
    oACTIVOS:oATV_CODUBI:cToolTip:="Ubicación"

  @ oACTIVOS:oATV_CODUBI:nTop-08,oACTIVOS:oATV_CODUBI:nLeft SAY GetFromVar("{oDp:xDPUBIACTIVOS}") PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

//GetFromVar("{oDp:xDPUBIACTIVOS}")
  @ oACTIVOS:oATV_CODUBI:nTop,oACTIVOS:oATV_CODUBI:nRight+5 SAY oACTIVOS:oUAC_DESCRI;
                            PROMPT oACTIVOS:oDPUBIACTIVOS:UAC_DESCRI PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680 BORDER 


  //
  // Campo : ATV_FCHADQ
  // Uso   : Fecha de Adquisición                    
  //
  @ 4.7, 0.0 BMPGET oACTIVOS:oATV_FCHADQ  VAR oACTIVOS:ATV_FCHADQ  PICTURE "99/99/9999";
          NAME "BITMAPS\Calendar.bmp";
          ACTION LbxDate(oACTIVOS:oATV_FCHADQ,oACTIVOS:ATV_FCHADQ);
                    WHEN (AccessField("DPACTIVOS","ATV_FCHADQ",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 32,10

    oACTIVOS:oATV_FCHADQ:cMsg    :="Fecha de Adquisición"
    oACTIVOS:oATV_FCHADQ:cToolTip:="Fecha de Adquisición"

  @ oACTIVOS:oATV_FCHADQ:nTop-08,oACTIVOS:oATV_FCHADQ:nLeft SAY "Fecha de Adquisición" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : ATV_COSADQ
  // Uso   : Costo de Adquisición                    
  //
  @ 6.5, 0.0 GET oACTIVOS:oATV_COSADQ  VAR oACTIVOS:ATV_COSADQ  PICTURE "9,999,999,999,999.99";
                    WHEN (AccessField("DPACTIVOS","ATV_COSADQ",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 64,10;
                  RIGHT


    oACTIVOS:oATV_COSADQ:cMsg    :="Costo de Adquisición"
    oACTIVOS:oATV_COSADQ:cToolTip:="Costo de Adquisición"

  @ oACTIVOS:oATV_COSADQ:nTop-08,oACTIVOS:oATV_COSADQ:nLeft SAY "Costo de Adquisición" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : ATV_VALSAL
  // Uso   : Valor de Salvamento                     
  //
  @ 8.3, 0.0 GET oACTIVOS:oATV_VALSAL  VAR oACTIVOS:ATV_VALSAL  PICTURE "9999999999999.99";
                    WHEN (AccessField("DPACTIVOS","ATV_VALSAL",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 64,10;
                  RIGHT


    oACTIVOS:oATV_VALSAL:cMsg    :="Valor de Salvamento"
    oACTIVOS:oATV_VALSAL:cToolTip:="Valor de Salvamento"

  @ oACTIVOS:oATV_VALSAL:nTop-08,oACTIVOS:oATV_VALSAL:nLeft SAY "Valor de Salvamento" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : ATV_VIDA_A
  // Uso   : Vida Util en Años                       
  //
  @ 10.1, 0.0 GET oACTIVOS:oATV_VIDA_A  VAR oACTIVOS:ATV_VIDA_A  PICTURE "99";
                    WHEN (AccessField("DPACTIVOS","ATV_VIDA_A",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 8,10;
                  RIGHT


    oACTIVOS:oATV_VIDA_A:cMsg    :="Vida Util en Años"
    oACTIVOS:oATV_VIDA_A:cToolTip:="Vida Util en Años"

  @ oACTIVOS:oATV_VIDA_A:nTop-08,oACTIVOS:oATV_VIDA_A:nLeft SAY "Vida Util en Años" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : ATV_VIDA_M
  // Uso   : Más Vida Util en Meses                  
  //
  @ 3.0,14.0 GET oACTIVOS:oATV_VIDA_M  VAR oACTIVOS:ATV_VIDA_M  PICTURE "999";
                    WHEN (AccessField("DPACTIVOS","ATV_VIDA_M",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 12,10;
                  RIGHT


    oACTIVOS:oATV_VIDA_M:cMsg    :="Más Vida Util en Meses"
    oACTIVOS:oATV_VIDA_M:cToolTip:="Más Vida Util en Meses"

  @ oACTIVOS:oATV_VIDA_M:nTop-08,oACTIVOS:oATV_VIDA_M:nLeft SAY "Más Vida Util en Meses" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : ATV_CTAACT
  // Uso   : Cuenta de Activo                        
  //
  @ 4.8,14.0 BMPGET oACTIVOS:oATV_CTAACT  VAR oACTIVOS:ATV_CTAACT ;
                VALID oACTIVOS:oDPCTA:SeekTable("CTA_CODIGO",oACTIVOS:oATV_CTAACT,NIL,oACTIVOS:oCTA_DESCRI);
                    NAME "BITMAPS\FIND.BMP"; 
                     ACTION (oDpLbx:=DpLbx("DPCTA"), oDpLbx:GetValue("CTA_CODIGO",oACTIVOS:oATV_CTAACT)); 
                    WHEN (AccessField("DPACTIVOS","ATV_CTAACT",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 80,10

    oACTIVOS:oATV_CTAACT:cMsg    :="Cuenta de Activo"
    oACTIVOS:oATV_CTAACT:cToolTip:="Cuenta de Activo"

  @ oACTIVOS:oATV_CTAACT:nTop-08,oACTIVOS:oATV_CTAACT:nLeft SAY GetFromVar("{oDp:xDPCTA}") PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

//GetFromVar("{oDp:xDPCTA}")
  @ oACTIVOS:oATV_CTAACT:nTop,oACTIVOS:oATV_CTAACT:nRight+5 SAY oACTIVOS:oCTA_DESCRI;
                            PROMPT oACTIVOS:oDPCTA:CTA_DESCRI PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680 BORDER 



     SETFOLDER( 2)
  //
  // Campo : ATV_METODO
  // Uso   : Método de Depreciación                  
  //
  @ 0.6, 0.0 COMBOBOX oACTIVOS:oATV_METODO VAR oACTIVOS:ATV_METODO ITEMS aItems2;
                      WHEN (AccessField("DPACTIVOS","ATV_METODO",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                      FONT oFontG;


 ComboIni(oACTIVOS:oATV_METODO)


    oACTIVOS:oATV_METODO:cMsg    :="Método de Depreciación"
    oACTIVOS:oATV_METODO:cToolTip:="Método de Depreciación"

  @ oACTIVOS:oATV_METODO:nTop-08,oACTIVOS:oATV_METODO:nLeft SAY "Método de Depreciación" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : ATV_FCHINC
  // Uso   : Fecha de Inclusión                      
  //
  @ 2.4, 0.0 BMPGET oACTIVOS:oATV_FCHINC  VAR oACTIVOS:ATV_FCHINC  PICTURE "99/99/9999";
          NAME "BITMAPS\Calendar.bmp";
          ACTION LbxDate(oACTIVOS:oATV_FCHINC,oACTIVOS:ATV_FCHINC);
                    WHEN (AccessField("DPACTIVOS","ATV_FCHINC",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 32,10

    oACTIVOS:oATV_FCHINC:cMsg    :="Fecha de Inclusión"
    oACTIVOS:oATV_FCHINC:cToolTip:="Fecha de Inclusión"

  @ oACTIVOS:oATV_FCHINC:nTop-08,oACTIVOS:oATV_FCHINC:nLeft SAY "Inicio Contable" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : ATV_FCHDEP
  // Uso   : Fecha de Depreciación                   
  //
  @ 4.2, 0.0 BMPGET oACTIVOS:oATV_FCHDEP  VAR oACTIVOS:ATV_FCHDEP  PICTURE "99/99/9999";
          NAME "BITMAPS\Calendar.bmp";
          ACTION LbxDate(oACTIVOS:oATV_FCHDEP,oACTIVOS:ATV_FCHDEP);
                    WHEN (AccessField("DPACTIVOS","ATV_FCHDEP",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 32,10

    oACTIVOS:oATV_FCHDEP:cMsg    :="Fecha de Depreciación"
    oACTIVOS:oATV_FCHDEP:cToolTip:="Fecha de Depreciación"

  @ oACTIVOS:oATV_FCHDEP:nTop-08,oACTIVOS:oATV_FCHDEP:nLeft SAY "Primeria Depreciación" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : ATV_DEPACU
  // Uso   : Depreciación Acumulada                  
  //
  @ 6.0, 0.0 GET oACTIVOS:oATV_DEPACU  VAR oACTIVOS:ATV_DEPACU  PICTURE "9999999999999.99";
                    WHEN (AccessField("DPACTIVOS","ATV_DEPACU",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 64,10;
                  RIGHT


    oACTIVOS:oATV_DEPACU:cMsg    :="Depreciación Acumulada"
    oACTIVOS:oATV_DEPACU:cToolTip:="Depreciación Acumulada"

  @ oACTIVOS:oATV_DEPACU:nTop-08,oACTIVOS:oATV_DEPACU:nLeft SAY "Depreciación Acumulada" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : ATV_MESDEP
  // Uso   : Meses Depreciados                       
  //
  @ 7.8, 0.0 GET oACTIVOS:oATV_MESDEP  VAR oACTIVOS:ATV_MESDEP  PICTURE "9999";
                    WHEN (AccessField("DPACTIVOS","ATV_MESDEP",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 16,10;
                  RIGHT


    oACTIVOS:oATV_MESDEP:cMsg    :="Meses Depreciados"
    oACTIVOS:oATV_MESDEP:cToolTip:="Meses Depreciados"

  @ oACTIVOS:oATV_MESDEP:nTop-08,oACTIVOS:oATV_MESDEP:nLeft SAY "Meses Depreciados" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : ATV_UNIPRO
  // Uso   : Cantidad a Producir                     
  //
  @ 9.6, 0.0 GET oACTIVOS:oATV_UNIPRO  VAR oACTIVOS:ATV_UNIPRO  PICTURE "9999999.99";
                    WHEN (AccessField("DPACTIVOS","ATV_UNIPRO",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 40,10;
                  RIGHT


    oACTIVOS:oATV_UNIPRO:cMsg    :="Cantidad a Producir"
    oACTIVOS:oATV_UNIPRO:cToolTip:="Cantidad a Producir"

  @ oACTIVOS:oATV_UNIPRO:nTop-08,oACTIVOS:oATV_UNIPRO:nLeft SAY "Unidades a Producir" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : ATV_DEPMEN
  // Uso   : Depreciación Mensual Fija               
  //
  @ 3.0,14.0 GET oACTIVOS:oATV_DEPMEN  VAR oACTIVOS:ATV_DEPMEN  PICTURE "9999999999999.99";
                    WHEN (AccessField("DPACTIVOS","ATV_DEPMEN",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 64,10;
                  RIGHT


    oACTIVOS:oATV_DEPMEN:cMsg    :="Depreciación Mensual Fija"
    oACTIVOS:oATV_DEPMEN:cToolTip:="Depreciación Mensual Fija"

  @ oACTIVOS:oATV_DEPMEN:nTop-08,oACTIVOS:oATV_DEPMEN:nLeft SAY "Depreciación Mensual Fija" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : ATV_CTAACU
  // Uso   : Depreciación Acumulada Activo           
  //
  @ 4.8,14.0 BMPGET oACTIVOS:oATV_CTAACU  VAR oACTIVOS:ATV_CTAACU ;
                VALID oACTIVOS:oDPCTA:SeekTable("CTA_CODIGO",oACTIVOS:oATV_CTAACU,NIL,oACTIVOS:oCTA_DESCRI);
                    NAME "BITMAPS\FIND.BMP"; 
                     ACTION (oDpLbx:=DpLbx("DPCTA"), oDpLbx:GetValue("CTA_CODIGO",oACTIVOS:oATV_CTAACU)); 
                    WHEN (AccessField("DPACTIVOS","ATV_CTAACU",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 80,10

    oACTIVOS:oATV_CTAACU:cMsg    :="Depreciación Acumulada Activo"
    oACTIVOS:oATV_CTAACU:cToolTip:="Depreciación Acumulada Activo"

  @ oACTIVOS:oATV_CTAACU:nTop-08,oACTIVOS:oATV_CTAACU:nLeft SAY GetFromVar("{oDp:xDPCTA}") PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

//GetFromVar("{oDp:xDPCTA}")
  @ oACTIVOS:oATV_CTAACU:nTop,oACTIVOS:oATV_CTAACU:nRight+5 SAY oACTIVOS:oCTA_DESCRI;
                            PROMPT oACTIVOS:oDPCTA:CTA_DESCRI PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680 BORDER 


  //
  // Campo : ATV_CTADEP
  // Uso   : Depreciación Gasto                      
  //
  @ 6.6,14.0 BMPGET oACTIVOS:oATV_CTADEP  VAR oACTIVOS:ATV_CTADEP ;
                VALID oACTIVOS:oDPCTA:SeekTable("CTA_CODIGO",oACTIVOS:oATV_CTADEP,NIL,oACTIVOS:oCTA_DESCRI);
                    NAME "BITMAPS\FIND.BMP"; 
                     ACTION (oDpLbx:=DpLbx("DPCTA"), oDpLbx:GetValue("CTA_CODIGO",oACTIVOS:oATV_CTADEP)); 
                    WHEN (AccessField("DPACTIVOS","ATV_CTADEP",oACTIVOS:nOption);
                    .AND. oACTIVOS:nOption!=0);
                    FONT oFontG;
                    SIZE 80,10

    oACTIVOS:oATV_CTADEP:cMsg    :="Depreciación Gasto"
    oACTIVOS:oATV_CTADEP:cToolTip:="Depreciación Gasto"

  @ oACTIVOS:oATV_CTADEP:nTop-08,oACTIVOS:oATV_CTADEP:nLeft SAY GetFromVar("{oDp:xDPCTA}") PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

//GetFromVar("{oDp:xDPCTA}")
  @ oACTIVOS:oATV_CTADEP:nTop,oACTIVOS:oATV_CTADEP:nRight+5 SAY oACTIVOS:oCTA_DESCRI;
                            PROMPT oACTIVOS:oDPCTA:CTA_DESCRI PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680 BORDER 



  SETFOLDER( 3)

  oACTIVOS:oScroll:=oACTIVOS:SCROLLGET("DPACTIVOS","DPACTIVOS.SCG",cExcluye)
  oACTIVOS:oScroll:SetColSize(160,250+15,180)
  oACTIVOS:oScroll:SetColorHead(CLR_BLACK ,6220027,oFont) 

// COLORPANE2:=11595007
// COLORPANE1:=14613246

  oACTIVOS:oScroll:SetColor(14613246 , CLR_BLUE  , 1 , 11595007 , oFontB) 
  oACTIVOS:oScroll:SetColor(14613246 , CLR_BLACK , 2 , 11595007 , oFont ) 
  oACTIVOS:oScroll:SetColor(14613246 , CLR_GRAY  , 3 , 11595007 , oFont ) 

  IF oACTIVOS:IsDef("oScroll")
    oACTIVOS:oScroll:SetEdit(.F.)
  ENDIF
  SETFOLDER(0)

  IF oACTIVOS:oScroll<>NIL
    oACTIVOS:oScroll:SetEdit(.F.)
  ENDIF

  oACTIVOS:SetEdit(!oACTIVOS:nOption=0)

  oACTIVOS:Activate({||oACTIVOS:INICIO()})

  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oACTIVOS

FUNCTION INICIO()

  oACTIVOS:oScroll:oBrw:SetColor(NIL , 14613246 )
  oACTIVOS:oDlg:oBar:SetColor(CLR_WHITE,oDp:nGris)
  AEVAL(oACTIVOS:oDlg:oBar:aControls,{|oBtn|oBtn:SetColor(CLR_WHITE,oDp:nGris)})

  IF oACTIVOS:nOption=1
     oACTIVOS:LOAD(1)
  ENDIF

RETURN .T.

/*
// Carga de los Datos
*/
FUNCTION LOAD()

  IF oACTIVOS:nOption=0 // Incluir en caso de ser Incremental
     oACTIVOS:SetEdit(.F.) // Inactiva la Edicion
  ELSE
     oACTIVOS:SetEdit(.T.) // Activa la Edicion
  ENDIF

  IF oACTIVOS:nOption=1 // Incluir en caso de ser Incremental
     // AutoIncremental 
  ENDIF

  IF oACTIVOS:oScroll<>NIL
    oACTIVOS:oScroll:SetEdit(oACTIVOS:nOption=1.OR.oACTIVOS:nOption=3)
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

  lResp:=oACTIVOS:ValUnique(oACTIVOS:ATV_CODIGO)
  IF !lResp
        MsgAlert("Registro "+CTOO(oACTIVOS:ATV_CODIGO),"Ya Existe")
  ENDIF

RETURN lResp

/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()
RETURN .T.

/*
<LISTA:ATV_CODIGO:Y:GET:N:N:N:Código,ATV_DESCRI:N:GET:N:N:Y:Descripción,ATV_DEPRE:N:COMBO:N:N:Y:Tipo de Activo,Pestaña01:N:GET:N:N:N:Básicos,ATV_CODGRU:N:BMPGETL:N:N:Y:Grupo,ATV_CODUBI:N:BMPGETL:N:N:Y:Ubicación,ATV_FCHADQ:N:BMPGET:N:N:Y:Fecha de Adquisición,ATV_COSADQ:N:GET:N:N:Y:Costo de Adquisición
,ATV_VALSAL:N:GET:N:N:Y:Valor de Salvamento,ATV_VIDA_A:N:GET:N:N:Y:Vida Util en Años,ATV_VIDA_M:N:GET:N:N:Y:Más Vida Util en Meses,ATV_CTAACT:N:BMPGETL:N:N:Y:Activo
,Pestaña02:N:GET:N:N:N:Depreciación,ATV_METODO:N:COMBO:N:N:Y:Método de Depreciación,ATV_FCHINC:N:BMPGET:N:N:Y:Inicio Contable,ATV_FCHDEP:N:BMPGET:N:N:Y:Primeria Depreciación
,ATV_DEPACU:N:GET:N:N:Y:Depreciación Acumulada,ATV_MESDEP:N:GET:N:N:Y:Meses Depreciados,ATV_UNIPRO:N:GET:N:N:Y:Unidades a Producir,ATV_DEPMEN:N:GET:N:N:Y:Depreciación Mensual Fija
,ATV_CTAACU:N:BMPGETL:N:N:Y:Depreciación  Activo,ATV_CTADEP:N:BMPGETL:N:N:Y:Depreciación Gasto,Pestaña03:N:GET:N:N:N:Datos Adicionales,SCROLLGET:N:GET:N:N:N:Para Diversos Campos>
*/
