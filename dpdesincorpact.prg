// Programa   : DPDESINCORPACT
// Fecha/Hora : 05/07/2006 17:22:20
// Propósito  : Documento DPDESINCORPACT
// Creado Por : DpXbase
// Llamado por: DPDESINCORPACT.LBX
// Aplicación : Activos Fijos                           
// Tabla      : DPDESINCORPACT

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION DPDESINCORPACT(nOption,cCodigo)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG,aTotal,oCol
  LOCAL cSql,cFile,cExcluye:="",cScope:=""
  LOCAL nClrText
  LOCAL oBrw,cSqlCuerpo,oCuerpo,oCol,oCursorC
  LOCAL cTitle:="Desincorporación de Activos"
  LOCAL aData:={},nDesinc:=0,nAt:=0

  AADD(aData,{"",CTOD(""),0,.F.})

  aTotal:=ATOTALES(aData)

  cExcluye:="DAC_CODIGO,;
             DAC_COMENT,;
             DAC_FECHA,;
             DAC_NUMERO"

//  DEFAULT cCodigo:=STRZERO(1,5),;
//          nOption:=0

  IF !(cCodigo=NIL)

     cScope:=" DAC_CODIGO"+GetWhere("=",cCodigo)

     nDesinc:=MYCOUNT("DPDEPRECIAACT","DEP_CODACT"+GetWhere("=",cCodigo)+" AND "+;
                                      "DEP_ESTADO='D'")

     IF nDesinc=0 .AND. MYCOUNT("DPDEPRECIAACT","DEP_CODACT"+GetWhere("=",cCodigo)+" AND "+;
                                "DEP_ESTADO='A'")=0

        MensajeErr("Activo no Posee Depreciaciones Activas")

        RETURN .F.

    ENDIF

  ELSE
     cScope:=NIL
  ENDIF

  DEFINE FONT oFont  NAME "Verdana" SIZE 0, -12 BOLD
  DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD ITALIC
  DEFINE FONT oFontG NAME "Arial"   SIZE 0, -11

  nClrText:=10485760 // Color del texto

  cTitle   :=" {oDp:DPDESINCORPACT}"

  cSql  :=[SELECT * FROM DPDESINCORPACT ]
  oTable:=OpenTable(cSql,.F.) // nOption!=1)
  oTable:cPrimary:="DAC_NUMERO" // Clave de Validación de Registro

  oDESINCORPACT:=DPEDIT():New(cTitle,"DPDESINCORPACT.edt","oDESINCORPACT" , .F. )

  oDESINCORPACT:lDlg :=.T.            // Formulario Sin Dialog
  oDESINCORPACT:nMode:=1              // Formulario Tipo de Documento
  oDESINCORPACT:nClrPane :=oDp:nGris
  oDESINCORPACT:nOption  :=nOption
  oDESINCORPACT:cScope   :=cScope     // Filtra
  oDESINCORPACT:cCodigo  :=cCodigo   // cCodigo
  oDESINCORPACT:cList    :="DPDESINCORPACT.BRW"

  oDESINCORPACT:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oDESINCORPACT
  oDESINCORPACT:SetScript()        // Asigna Funciones DpXbase como Metodos de oDESINCORPACT
  oDESINCORPACT:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY

  oDESINCORPACT:nMonto:=0          // Monto de la Desincorporacion

  //Tablas Relacionadas con los Controles del Formulario
  oDESINCORPACT:CreateWindow()        // Presenta la Ventana

  
  oDESINCORPACT:ViewTable("DPACTIVOS","ATV_DESCRI","ATV_CODIGO","DAC_CODIGO")

  
  //
  // Campo : DAC_CODIGO
  // Uso   : Código de Activo                        
  //
  @ 3.0, 1.0 BMPGET oDESINCORPACT:oDAC_CODIGO  VAR oDESINCORPACT:DAC_CODIGO ;
                    VALID oDESINCORPACT:DACCODIGO();
                    NAME "BITMAPS\FIND.BMP"; 
                     ACTION (oDpLbx:=DpLbx("DPACTIVOS"), oDpLbx:GetValue("ATV_CODIGO",oDESINCORPACT:oDAC_CODIGO)); 
                    WHEN (AccessField("DPDESINCORPACT","DAC_CODIGO",oDESINCORPACT:nOption);
                    .AND. !(oDESINCORPACT:nOption=0 .OR. oDESINCORPACT:nOption=3) .AND. Empty(oDESINCORPACT:cCodigo));
                    FONT oFontG;
                    SIZE 60,10

    oDESINCORPACT:oDAC_CODIGO:cMsg    :="Código de Activo"
    oDESINCORPACT:oDAC_CODIGO:cToolTip:="Código de Activo"

  @ oDESINCORPACT:oDAC_CODIGO:nTop-08,oDESINCORPACT:oDAC_CODIGO:nLeft SAY GetFromVar("{oDp:xDPACTIVOS}") PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris

//GetFromVar("{oDp:xDPACTIVOS}")
  @ oDESINCORPACT:oDAC_CODIGO:nTop,oDESINCORPACT:oDAC_CODIGO:nRight+5 SAY oDESINCORPACT:oATV_DESCRI;
                            PROMPT oDESINCORPACT:oDPACTIVOS:ATV_DESCRI PIXEL;
                            SIZE NIL,12 FONT oFont COLOR 16777215,16711680 BORDER 


  //
  // Campo : DAC_COMENT
  // Uso   : Comentarios                             
  //
  @ 4.8, 1.0 GET oDESINCORPACT:oDAC_COMENT  VAR oDESINCORPACT:DAC_COMENT ;
                    WHEN (AccessField("DPDESINCORPACT","DAC_COMENT",oDESINCORPACT:nOption);
                    .AND. oDESINCORPACT:nOption!=0);
                    FONT oFontG;
                    SIZE 160,10

    oDESINCORPACT:oDAC_COMENT:cMsg    :="Comentarios"
    oDESINCORPACT:oDAC_COMENT:cToolTip:="Comentarios"

  @ oDESINCORPACT:oDAC_COMENT:nTop-08,oDESINCORPACT:oDAC_COMENT:nLeft SAY "Comentarios" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : DAC_FECHA 
  // Uso   : Fecha                                   
  //
  @ 6.6, 1.0 BMPGET oDESINCORPACT:oDAC_FECHA   VAR oDESINCORPACT:DAC_FECHA   PICTURE "99/99/9999";
          NAME "BITMAPS\Calendar.bmp";
          ACTION LbxDate(oDESINCORPACT:oDAC_FECHA,oDESINCORPACT:DAC_FECHA);
                    WHEN (AccessField("DPDESINCORPACT","DAC_FECHA",oDESINCORPACT:nOption);
                    .AND. oDESINCORPACT:nOption!=0);
                    FONT oFontG;
                    SIZE 32,10

    oDESINCORPACT:oDAC_FECHA :cMsg    :="Fecha"
    oDESINCORPACT:oDAC_FECHA :cToolTip:="Fecha"

  @ oDESINCORPACT:oDAC_FECHA :nTop-08,oDESINCORPACT:oDAC_FECHA :nLeft SAY "Fecha" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : DAC_NUMERO
  // Uso   : Número                                  
  //
  @ 8.4, 1.0 GET oDESINCORPACT:oDAC_NUMERO  VAR oDESINCORPACT:DAC_NUMERO  VALID CERO(oDESINCORPACT:DAC_NUMERO) .AND.; 
                 oDESINCORPACT:ValUnique(oDESINCORPACT:DAC_NUMERO);
                   .AND. !VACIO(oDESINCORPACT:DAC_NUMERO,NIL);
                    WHEN (AccessField("DPDESINCORPACT","DAC_NUMERO",oDESINCORPACT:nOption);
                    .AND. !(oDESINCORPACT:nOption=0 .OR. oDESINCORPACT:nOption=1 .OR. oDESINCORPACT:nOption=30));
                    FONT oFontG;
                    SIZE 32,10

    oDESINCORPACT:oDAC_NUMERO:cMsg    :="Número"
    oDESINCORPACT:oDAC_NUMERO:cToolTip:="Número"

  @ oDESINCORPACT:oDAC_NUMERO:nTop-08,oDESINCORPACT:oDAC_NUMERO:nLeft SAY "Número" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


   oDESINCORPACT:oBrw:=TXBrowse():New( oDESINCORPACT:oDlg )
   oDESINCORPACT:oBrw:SetArray( aData, .F. )
   oDESINCORPACT:oBrw:SetFont(oFont)
   oDESINCORPACT:oBrw:lFooter := .T.
   oDESINCORPACT:oBrw:lHScroll:= .F.
   oDESINCORPACT:oBrw:nHeaderLines:=2

   AEVAL(oDESINCORPACT:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oDESINCORPACT:oBrw:aCols[1]:cHeader      :="Núm"+CRLF+"Registro"
   oDESINCORPACT:oBrw:aCols[1]:nWidth       :=070

   oDESINCORPACT:oBrw:aCols[2]:cHeader      :="Fecha"+CRLF+"Depreciación"
   oDESINCORPACT:oBrw:aCols[2]:nWidth       :=100

   oDESINCORPACT:oBrw:aCols[3]:cHeader      :="Monto"+CRLF+"Depreciación"
   oDESINCORPACT:oBrw:aCols[3]:nWidth       :=190
   oDESINCORPACT:oBrw:aCols[3]:nDataStrAlign:= AL_RIGHT
   oDESINCORPACT:oBrw:aCols[3]:nHeadStrAlign:= AL_RIGHT
   oDESINCORPACT:oBrw:aCols[3]:nFootStrAlign:= AL_RIGHT
   oDESINCORPACT:oBrw:aCols[3]:bStrData     :={|nMonto|nMonto:=oDESINCORPACT:oBrw:aArrayData[oDESINCORPACT:oBrw:nArrayAt,3],;
                                                  TRAN(nMonto,"99,999,999,999.99")}

   oDESINCORPACT:oBrw:aCols[3]:cFooter      :=TRAN(aTotal[3],"99,999,999,999.99")


   oCol:=oDESINCORPACT:oBrw:aCols[4]
   oCol:cHeader      := "Activos"
   oCol:nWidth       := 90
   oCol:AddBmpFile("BITMAPS\xCheckOn.bmp")
   oCol:AddBmpFile("BITMAPS\xCheckOff.bmp")
   oCol:bBmpData    := { ||oBrw:=oDESINCORPACT:oBrw,IIF(oBrw:aArrayData[oBrw:nArrayAt,4],1,2) }
   oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
   oCol:bLDClickData:={||oDESINCORPACT:DEPSELECT()}
   oCol:bLClickHeader:={|nRow,nCol,nKey,oCol|oDESINCORPACT:DEPALL(nRow,nCol,nKey,oCol,.T.)}


   oDESINCORPACT:oBrw:bLDblClick:=oCol:bLDClickData


   oDESINCORPACT:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oDESINCORPACT:oBrw,;
                                                 nClrText:=IIF(oBrw:aArrayData[oBrw:nArrayAt,4],CLR_BLACK,CLR_GRAY),;
                                               {nClrText,iif( oBrw:nArrayAt%2=0, 14217982, 9690879 ) } }

   oDESINCORPACT:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oDESINCORPACT:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oDESINCORPACT:oBrw:CreateFromCode()

   IF oDESINCORPACT:oScroll<>NIL
     oDESINCORPACT:oScroll:SetEdit(.F.)
   ENDIF
  
   oDESINCORPACT:SetEdit(!oDESINCORPACT:nOption=0)

   // Quitar el Boton de Consulta
   nAt:=ASCAN(oDESINCORPACT:aButtons,{|a,n|a[7]="VIEW"})
   ARREDUCE(oDESINCORPACT:aButtons,nAt)

   oDESINCORPACT:Activate({||oDESINCORPACT:Inicio()})

   STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oDESINCORPACT

FUNCTION INICIO()

    oDESINCORPACT:oBrw:SetColor(NIL,14217982)

    IF oDESINCORPACT:nOption=1
       oDESINCORPACT:LOAD(1)
    ELSE
       oDESINCORPACT:LOAD(0)
    ENDIF

//  oDESINCORPACT:oScroll:oBrw:SetColor(NIL , 14613246 )
    oDESINCORPACT:oDlg:oBar:SetColor(CLR_WHITE,oDp:nGris)
    AEVAL(oDESINCORPACT:oDlg:oBar:aControls,{|oBtn|oBtn:SetColor(CLR_WHITE,oDp:nGris)})

RETURN .T.


/*
// Carga de los Datos
*/
FUNCTION LOAD()
  LOCAL cSql,aData,I

  oDESINCORPACT:oFocus:=oDESINCORPACT:oDAC_CODIGO

  IF oDESINCORPACT:nOption=0 // Incluir en caso de ser Incremental

     oDESINCORPACT:SetEdit(.F.) // Inactiva la Edicion

     cSql :="SELECT DEP_NUMERO,DEP_FECHA,DEP_MONTO,DEP_ESTADO,DEP_NUMDES,DEP_MTOORG FROM DPDEPRECIAACT WHERE "+;
            "DEP_CODACT"+GetWhere("=",oDESINCORPACT:DAC_CODIGO)+" AND DEP_ESTADO<>'H'"

     aData:=ASQL(cSql)

     AEVAL(aData,{|a,n|aData[n,4]:=a[4]='D',;
                       aData[n,3]:=IIF(aData[n,6]!=0,aData[n,6],aData[n,3]) })

     // Elimina los Desincorporados en Otros Registros
     FOR I=1 TO LEN(aData)
        IF aData[I,4] .AND. aData[I,5]<>oDESINCORPACT:DAC_NUMERO
           ARREDUCE(aData,I)
           I:=1
        ENDIF
     NEXT I

     oDESINCORPACT:oBrw:aArrayData:=ACLONE(aData)
     oDESINCORPACT:CALTOTAL(.F.)
     oDESINCORPACT:oBrw:GoTop(.F.)
     oDESINCORPACT:oBrw:Refresh(.T.)

  ELSE

     oDESINCORPACT:SetEdit(.T.) // Activa la Edicion

  ENDIF

  IF oDESINCORPACT:nOption=1 // Incluir en caso de ser Incremental


     oDESINCORPACT:DAC_NUMERO:=oDESINCORPACT:Incremental("DAC_NUMERO",.T.)
     oDESINCORPACT:oDAC_NUMERO:Refresh(.T.)
     oDESINCORPACT:oDAC_FECHA:VarPut(oDp:dFecha,.T.)

     aData:={}
     AADD(aData,{"",CTOD(""),0,.F.})
     oDESINCORPACT:oBrw:aArrayData:=ACLONE(aData)
     oDESINCORPACT:oBrw:nRowSel :=1
     oDESINCORPACT:oBrw:nArrayAt:=1
     oDESINCORPACT:oBrw:Refresh(.F.)

     IF !Empty(oDESINCORPACT:cCodigo)

        oDESINCORPACT:oDAC_CODIGO:VarPut(oDESINCORPACT:cCodigo,.T.)
        oDESINCORPACT:oFocus:=oDESINCORPACT:oDAC_COMENT

        IF !oDESINCORPACT:DACCODIGO()
           RETURN .F.           
        ENDIF

     ENDIF

  ENDIF

  IF oDESINCORPACT:nOption=3
     oDESINCORPACT:oFocus:=oDESINCORPACT:oDAC_COMENT
  ENDIF

  IF oDESINCORPACT:oScroll<>NIL
    oDESINCORPACT:oScroll:SetEdit(oDESINCORPACT:nOption=1.OR.oDESINCORPACT:nOption=3)
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

  oDESINCORPACT:DAC_CONTAB:="N"

  IF oDESINCORPACT:nOption=1 // Incluir en caso de ser Incremental
     oDESINCORPACT:DAC_NUMERO:=oDESINCORPACT:Incremental("DAC_NUMERO",.T.)
     oDESINCORPACT:oDAC_NUMERO:Refresh(.T.)
  ENDIF

  lResp:=oDESINCORPACT:ValUnique(oDESINCORPACT:DAC_NUMERO)

  IF !lResp
     MsgAlert("Registro "+CTOO(oDESINCORPACT:DAC_NUMERO),"Ya Existe")
  ENDIF

  IF oDESINCORPACT:nMonto=0 .AND. oDESINCORPACT:nOption=1
     MensajeErr("Es necesario Seleccionar Depreciaciones")
     RETURN .F.
  ENDIF

RETURN lResp

/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()
  LOCAL I,aData:=ACLONE(oDESINCORPACT:oBrw:aArrayData),nTotal:=0,cMsg:="",oOdbc,cSql

  // Desactiva las Desincorporaciones

  SQLUPDATE("DPDEPRECIAACT",{"DEP_ESTADO","DEP_NUMDES"},{"A",""},;
            "DEP_CODACT"+GetWhere("=",oDESINCORPACT:DAC_CODIGO)+" AND "+;
            "DEP_NUMDES"+GetWhere("=",oDESINCORPACT:DAC_NUMERO))

  oOdbc:=GetOdbc("DPDEPRECIAACT")
  
  cSql:=" UPDATE DPDEPRECIAACT SET DEP_MONTO=DEP_MTOORG WHERE "+;
        " DEP_MONTO=0 AND "+;
        " DEP_CODACT"+GetWhere("=",oDESINCORPACT:DAC_CODIGO)

  oOdbc:Execute(cSql)

  SQLUPDATE("DPACTIVOS","ATV_ESTADO","A",;
            "ATV_CODIGO"+GetWhere("=",oDESINCORPACT:DAC_CODIGO))

  FOR I=1 TO LEN(aData)

     IF aData[I,4]

       nTotal:=nTotal+aData[i,3]

       SQLUPDATE("DPDEPRECIAACT",{"DEP_ESTADO","DEP_NUMDES"            ,"DEP_MONTO"},;
                                 {"D"         ,oDESINCORPACT:DAC_NUMERO,0          },;
                                 "DEP_CODACT"+GetWhere("=",oDESINCORPACT:DAC_CODIGO)+" AND "+;
                                 "DEP_NUMERO"+GetWhere("=",aData[I,1]))

     ENDIF

  NEXT I

  // Si el total de Desincorporaciones = total Depreciacion Pendiente, El activo está totalmente 
  // desincorporado

  IF MYCOUNT("DPDEPRECIAACT","DEP_CODACT"+GetWhere("=",oDESINCORPACT:DAC_CODIGO)+" AND DEP_ESTADO='A'")=0

     oDESINCORPACT:DAC_TIPO:="T"

     SQLUPDATE("DPACTIVOS","ATV_ESTADO","D",;
              "ATV_CODIGO"+GetWhere("=",oDESINCORPACT:DAC_CODIGO))

     cMsg:="Activo Desincorporado Totalmente"

  ELSE

     oDESINCORPACT:DAC_TIPO:="P"

     cMsg:="Activo Desincorporado Parcialmente"

  ENDIF

  EJECUTAR("DPDEPRECIAREC",oDESINCORPACT:DAC_NUMERO)

  SQLUPDATE("DPDESINCORPACT","DAC_TIPO",oDESINCORPACT:DAC_TIPO,;
                             "DAC_NUMERO"+GetWhere("=",oDESINCORPACT:DAC_NUMERO))

// IF !oDESINCORPACT:nMonto=0
//   MensajeErr(cMsg)
// ENDIF

  IF !Empty(oDESINCORPACT:cCodigo)
     oDESINCORPACT:CANCEL()
  ENDIF

//  ? nTotal,"TOTAL DEPRECIACION"
//  IF oDESINCORPACT:nMonto=nTotal
//  ENDIF

RETURN .T.

FUNCTION DACCODIGO()
   LOCAL aData,cSql

   IF Empty(oDESINCORPACT:DAC_CODIGO) .AND.  !ISMYSQLGET("DPACTIVOS","ATV_CODIGO",oDESINCORPACT:DAC_CODIGO)
      oDESINCORPACT:oDAC_CODIGO:KeyBoard(VK_F6)
      RETURN .T.
   ENDIF

   IF !oDESINCORPACT:oDPACTIVOS:SeekTable("ATV_CODIGO",oDESINCORPACT:oDAC_CODIGO,NIL,oDESINCORPACT:oATV_DESCRI)
       RETURN .F.
   ENDIF

   IF oDESINCORPACT:nOption<>1
      RETURN .F.
   ENDIF

   // Busca las Depreciaciones Activas
   cSql :="SELECT DEP_NUMERO,DEP_FECHA,DEP_MONTO,0 FROM DPDEPRECIAACT WHERE "+;
          "DEP_CODACT"+GetWhere("=",oDESINCORPACT:DAC_CODIGO)+" AND "+;
          "DEP_ESTADO='A'"

   aData:=ASQL(cSql)

   AEVAL(aData,{|a,n|aData[n,4]:=.F.})

   IF Empty(aData)
      MensajeErr("Activo no Posee Depreciaciones Activas")
      RETURN .F.
   ENDIF

   oDESINCORPACT:oBrw:aArrayData:=ACLONE(aData)
   oDESINCORPACT:oBrw:GoTop(.F.)
   oDESINCORPACT:oBrw:Refresh(.T.)
  

RETURN .T.

FUNCTION DEPSELECT()

   IF oDESINCORPACT:nOption=0 .OR. Empty(oDESINCORPACT:oBrw:aArrayData[1,1])
      RETURN .T.
   ENDIF

   oDESINCORPACT:oBrw:aArrayData[oDESINCORPACT:oBrw:nArrayAt,4]:=!oDESINCORPACT:oBrw:aArrayData[oDESINCORPACT:oBrw:nArrayAt,4]
   oDESINCORPACT:oBrw:DrawLine(.T.)
   oDESINCORPACT:CalTotal()

RETURN .T.

FUNCTION CALTOTAL(lRefresh)
  LOCAL I,aData:=ACLONE(oDESINCORPACT:oBrw:aArrayData)
  LOCAL nTotal:=0
  LOCAL nRowSel:=oDESINCORPACT:oBrw:nRowSel
  LOCAL nAt:=oDESINCORPACT:oBrw:nArrayAt

  DEFAULT lRefresh:=.T.

  FOR I=1 TO LEN(aData)
     IF aData[I,4]
       nTotal:=nTotal+aData[I,3]
     ENDIF
  NEXT I

  oDESINCORPACT:oBrw:aCols[3]:cFooter      :=TRAN(nTotal,"99,999,999,999.99")

  IF lRefresh
     oDESINCORPACT:oBrw:Refresh(.F.)
     oDESINCORPACT:oBrw:nRowSel :=nRowSel
     oDESINCORPACT:oBrw:nArrayAt:=nAt
  ENDIF

  oDESINCORPACT:nMonto:=nTotal       // Monto de la Desincorporacion

RETURN .T.

FUNCTION DEPALL(nRow,nCol,nKey,oCol,lOk)
   LOCAL lOk:=oDESINCORPACT:oBrw:aArrayData[1,4]

   IF oDESINCORPACT:nOption=0 .OR. Empty(oDESINCORPACT:oBrw:aArrayData[1,1])
     RETURN .T.
   ENDIF

   AEVAL(oDESINCORPACT:oBrw:aArrayData,{|a,n|oDESINCORPACT:oBrw:aArrayData[n,4]:=!lOk })

   oDESINCORPACT:oBrw:aArrayData[1,4]:=!lOk

   oDESINCORPACT:CALTOTAL()

RETURN .T.

FUNCTION PRINT()
  LOCAL oRep:=REPORTE("DPDESINC")

  oRep:SetRango(1,oDESINCORPACT:DAC_CODIGO,oDESINCORPACT:DAC_CODIGO)
  oRep:SetRango(2,oDESINCORPACT:DAC_NUMERO,oDESINCORPACT:DAC_NUMERO)

RETURN .T.


/*
// Ejecución para el Borrado 
*/
FUNCTION DELETE()

  IF MsgNoYes("Desincorporación: "+oDESINCORPACT:DAC_NUMERO,;
                        "Anular Registro")

     AEVAL(oDESINCORPACT:oBrw:aArrayData,{|a,n|oDESINCORPACT:oBrw:aArrayData[n,4]:=.F.})

     oDESINCORPACT:oBrw:Refresh(.T.)

     oDESINCORPACT:POSTSAVE()

     MensajeErr("Desincorporación: "+oDESINCORPACT:DAC_NUMERO+" Anulada")

     RETURN .F.

  ENDIF

RETURN .T.


/*
<LISTA:DAC_CODIGO:N:BMPGETL:N:N:Y:Código de Activo,DAC_COMENT:N:GET:N:N:Y:Comentarios,DAC_FECHA:N:BMPGET:N:N:Y:Fecha,DAC_NUMERO:Y:GET:Y:N:N:Número
>
*/
